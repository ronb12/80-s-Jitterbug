import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CustomerPortalView: View {
    @State private var user: User?
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isCreatingAccount = false
    @State private var loading = false
    @State private var error: String?
    @State private var bookings: [Booking] = []
    @State private var bookingsListener: ListenerRegistration?
    @State private var authListener: AuthStateDidChangeListenerHandle?

    var body: some View {
        NavigationStack {
            Group {
                if !FirebaseManager.isConfigured {
                    VStack(spacing: 12) {
                        Image(systemName: "icloud.slash")
                            .font(.title)
                            .symbolRenderingMode(.multicolor)
                        Text("Customer portal unavailable")
                            .font(.headline)
                        Text("Firebase is not configured in this app build.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else if user == nil {
                    authForm
                } else {
                    accountHome
                }
            }
            .navigationTitle("My Account")
        }
        .jitterbugMacNavigationRootFill()
        .onAppear {
            startAuthListener()
        }
        .onDisappear {
            stopAuthListener()
            stopBookingsListener()
        }
    }

    private var authForm: some View {
        Form {
            Section(isCreatingAccount ? "Create account" : "Sign in") {
                TextField("Email", text: $email)
                    #if os(iOS)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    #endif
                SecureField("Password", text: $password)
                if isCreatingAccount {
                    SecureField("Confirm password", text: $confirmPassword)
                }
            }
            if let error {
                Section { Text(error).foregroundStyle(.red) }
            }
            Section {
                Button(isCreatingAccount ? "Create account" : "Sign in") {
                    submitAuth()
                }
                .disabled(loading || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)
            }
            Section {
                Button(isCreatingAccount ? "Have an account? Sign in" : "Need an account? Create one") {
                    isCreatingAccount.toggle()
                    error = nil
                }
            }
            Section("Portal benefits") {
                Text("Track all your bookings in one place, check payment status, and review booking details anytime.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        #if os(macOS)
        .controlSize(.small)
        #endif
        .jitterbugMacInsetLeadingScrollableForm()
    }

    private var accountHome: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user?.email ?? "")
                        .font(.subheadline.weight(.semibold))
                    Text("Signed in")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("My bookings") {
                if bookings.isEmpty {
                    Text("No bookings found for this account yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(bookings) { booking in
                        NavigationLink {
                            CustomerBookingDetailView(booking: booking)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(booking.eventType.isEmpty ? "Booking" : booking.eventType)
                                    .font(.headline)
                                Text(booking.eventDate)
                                    .font(.subheadline)
                                Text(booking.bookingRef)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 10) {
                                    Text(booking.status.rawValue.capitalized)
                                    Text((booking.depositPaid ?? false) ? "Deposit paid" : "Deposit pending")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section {
                Button("Sign out", role: .destructive) {
                    signOut()
                }
            }
        }
        .jitterbugMacListTightUnderNavigationTitle()
    }

    private func startAuthListener() {
        guard FirebaseManager.isConfigured else { return }
        stopAuthListener()
        authListener = FirebaseManager.shared.auth.addStateDidChangeListener { _, current in
            DispatchQueue.main.async {
                user = current
                error = nil
                if let email = current?.email {
                    startBookingsListener(email: email)
                } else {
                    stopBookingsListener()
                    bookings = []
                }
            }
        }
    }

    private func stopAuthListener() {
        guard let handle = authListener, FirebaseManager.isConfigured else { return }
        FirebaseManager.shared.auth.removeStateDidChangeListener(handle)
        authListener = nil
    }

    private func startBookingsListener(email: String) {
        stopBookingsListener()
        bookingsListener = BookingService().observeBookingsForCustomer(email: email) { next in
            DispatchQueue.main.async {
                bookings = next
            }
        }
    }

    private func stopBookingsListener() {
        bookingsListener?.remove()
        bookingsListener = nil
    }

    private func submitAuth() {
        error = nil
        loading = true
        Task {
            do {
                let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if isCreatingAccount {
                    guard password == confirmPassword else {
                        throw NSError(domain: "CustomerPortal", code: 1, userInfo: [NSLocalizedDescriptionKey: "Passwords do not match."])
                    }
                    _ = try await FirebaseManager.shared.auth.createUser(withEmail: normalizedEmail, password: password)
                } else {
                    _ = try await FirebaseManager.shared.auth.signIn(withEmail: normalizedEmail, password: password)
                }
                await MainActor.run {
                    loading = false
                    password = ""
                    confirmPassword = ""
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.loading = false
                }
            }
        }
    }

    private func signOut() {
        do {
            try FirebaseManager.shared.auth.signOut()
        } catch {
            self.error = error.localizedDescription
        }
    }
}

private struct CustomerBookingDetailView: View {
    let booking: Booking

    var body: some View {
        Form {
            Section("Status") {
                LabeledContent("Booking ref", value: booking.bookingRef)
                LabeledContent("Status", value: booking.status.rawValue.capitalized)
                LabeledContent("Deposit", value: (booking.depositPaid ?? false) ? "Paid" : "Pending")
                LabeledContent("Balance", value: (booking.balancePaid ?? false) ? "Paid" : "Pending")
            }
            Section("Event") {
                LabeledContent("Type", value: booking.eventType)
                LabeledContent("Date", value: booking.eventDate)
                LabeledContent("Location", value: booking.eventLocation)
                LabeledContent("Address", value: booking.eventAddress)
                LabeledContent("Package", value: booking.package)
            }
            if !booking.message.isEmpty {
                Section("Message") {
                    Text(booking.message)
                }
            }
        }
        #if os(macOS)
        .controlSize(.small)
        #endif
        .jitterbugMacInsetLeadingScrollableForm()
        .navigationTitle("Booking")
    }
}
