import SwiftUI

struct AdminLoginView: View {
    var onDismiss: () -> Void
    var onSuccess: () -> Void
    @EnvironmentObject var auth: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var loading = false

    var body: some View {
        NavigationStack {
            loginForm
                .jitterbugMacInsetLeadingScrollableForm()
                .navigationTitle("Admin")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", action: onDismiss)
                    }
                }
        }
        .jitterbugMacNavigationRootFill()
        .jitterbugMacSheetChromeIfNeeded()
    }

    private var loginForm: some View {
        Form {
            Section("Admin login") {
                TextField("Email", text: $email)
                    #if os(iOS)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    #endif
                SecureField("Password", text: $password)
            }
            if let err = error {
                Section { Text(err).foregroundStyle(.red) }
            }
            Section {
                Button("Sign in") {
                    signIn()
                }
                .disabled(email.isEmpty || password.isEmpty || loading)
            }
        }
        #if os(macOS)
        .controlSize(.small)
        #endif
    }

    private func signIn() {
        error = nil
        loading = true
        Task {
            do {
                try await auth.signIn(email: email, password: password)
                await MainActor.run {
                    loading = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    loading = false
                }
            }
        }
    }
}
