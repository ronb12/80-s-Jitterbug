import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthService: ObservableObject {
    private var authStateListener: AuthStateDidChangeListenerHandle?
    @Published var currentUser: User?
    @Published var isAdmin: Bool = false

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
        isAdmin = currentUser != nil
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.isAdmin = user != nil
            if user != nil {
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
        guard FirebaseManager.isConfigured else { return }
        _ = try await FirebaseManager.shared.auth.signIn(
            withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
        await MainActor.run { self.isAdmin = true }
        // Auth listener also triggers admin FCM registration; explicit call covers edge cases.
        await PushNotificationService.shared.registerAdminDeviceIfPossible()
    }

    func signOut() async throws {
        guard FirebaseManager.isConfigured else { return }
        if let uid = FirebaseManager.shared.auth.currentUser?.uid {
            try? await FirebaseManager.shared.db.collection("adminFCM").document(uid).delete()
        }
        try FirebaseManager.shared.auth.signOut()
        await MainActor.run {
            self.currentUser = nil
            self.isAdmin = false
        }
    }
}
