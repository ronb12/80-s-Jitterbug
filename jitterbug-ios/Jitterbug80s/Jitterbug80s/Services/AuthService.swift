import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthServiceError: LocalizedError {
    case firebaseNotConfigured
    case unauthorizedAdmin

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase isn’t configured. Add a valid GoogleService-Info.plist (with a real API key) to the app target."
        case .unauthorizedAdmin:
            return "This account is not authorized for admin access."
        }
    }
}

final class AuthService: ObservableObject {
    private var authStateListener: AuthStateDidChangeListenerHandle?
    @Published var currentUser: User?
    @Published var isAdmin: Bool = false
    private let adminEmailAllowlist: Set<String> = [
        "sbowie207@gmail.com",
        "ronellbradley@hotmail.com"
    ]

    /// "Apple" when logged-in email contains "apple" (e.g. apple@123.com); nil otherwise. Use for admin welcome.
    var adminGreetingName: String? {
        guard let email = currentUser?.email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              !email.isEmpty else { return nil }
        return email.contains("apple") ? "Apple" : nil
    }

    init() {
        guard FirebaseManager.isConfigured else {
            currentUser = nil
            isAdmin = false
            return
        }
        let auth = FirebaseManager.shared.auth
        currentUser = auth.currentUser
        isAdmin = isAdminUser(currentUser)
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            let admin = self?.isAdminUser(user) ?? false
            self?.isAdmin = admin
            if admin {
                Task {
                    await PushNotificationService.shared.registerAdminDeviceIfPossible()
                }
            }
        }
    }

    deinit {
        if FirebaseManager.isConfigured, let handle = authStateListener {
            FirebaseManager.shared.auth.removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws {
        guard FirebaseManager.isConfigured else {
            throw AuthServiceError.firebaseNotConfigured
        }
        let result = try await FirebaseManager.shared.auth.signIn(
            withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
        let allowed = isAdminUser(result.user)
        if !allowed {
            // Prevent non-admin authenticated users from opening admin UI.
            try? FirebaseManager.shared.auth.signOut()
            await MainActor.run {
                self.currentUser = nil
                self.isAdmin = false
            }
            throw AuthServiceError.unauthorizedAdmin
        }
        await MainActor.run {
            self.currentUser = result.user
            self.isAdmin = true
        }
        if isAdmin {
            // Auth listener also triggers admin FCM registration; explicit call covers edge cases.
            await PushNotificationService.shared.registerAdminDeviceIfPossible()
        }
    }

    func signOut() async throws {
        guard FirebaseManager.isConfigured else {
            await MainActor.run {
                self.currentUser = nil
                self.isAdmin = false
            }
            return
        }
        if let uid = FirebaseManager.shared.auth.currentUser?.uid {
            try? await FirebaseManager.shared.db.collection("adminFCM").document(uid).delete()
        }
        try FirebaseManager.shared.auth.signOut()
        await MainActor.run {
            self.currentUser = nil
            self.isAdmin = false
        }
    }

    private func isAdminUser(_ user: User?) -> Bool {
        guard let email = user?.email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              !email.isEmpty else { return false }
        return adminEmailAllowlist.contains(email)
    }
}
