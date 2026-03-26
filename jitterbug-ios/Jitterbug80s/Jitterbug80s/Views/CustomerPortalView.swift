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
                            CustomerBookingDetailView(booking: booking, user: user)
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
    let user: User?
    @State private var liveBooking: Booking
    @State private var bookingListener: ListenerRegistration?
    @State private var showSignSheet = false
    @State private var showPhotoReleaseSignSheet = false
    @State private var stripeCheckoutEnabled = false
    @State private var publicSiteURL = SiteSettings.default.stripePublicBaseUrl
    @State private var stripePublishableKey = ""
    @State private var payLoading = false
    @State private var payError: String?
    @State private var changeRequestText = ""
    @State private var changeRequestSaving = false
    @State private var bookingEvents: [BookingEvent] = []
    @State private var signedDocuments: [SignedDocumentSnapshot] = []

    init(booking: Booking, user: User?) {
        self.booking = booking
        self.user = user
        _liveBooking = State(initialValue: booking)
    }

    var body: some View {
        Form {
            Section("Status") {
                LabeledContent("Booking ref", value: liveBooking.bookingRef)
                LabeledContent("Status", value: liveBooking.status.rawValue.capitalized)
                LabeledContent("Deposit", value: (liveBooking.depositPaid ?? false) ? "Paid" : "Pending")
                LabeledContent("Balance", value: (liveBooking.balancePaid ?? false) ? "Paid" : "Pending")
            }
            Section("Payment") {
                if stripeCheckoutEnabled {
                    if let payError {
                        Text(payError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    if !(liveBooking.depositPaid ?? false) {
                        Button {
                            startDepositCheckout()
                        } label: {
                            HStack {
                                if payLoading { ProgressView() }
                                Text(payLoading ? "Preparing payment…" : "Pay deposit")
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(payLoading)
                    } else {
                        Label {
                            Text("Deposit is already paid.")
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                        }
                        .foregroundStyle(.green)
                    }
                    if (liveBooking.depositPaid ?? false) && !(liveBooking.balancePaid ?? false) {
                        Button {
                            startBalanceCheckout()
                        } label: {
                            HStack {
                                if payLoading { ProgressView() }
                                Text(payLoading ? "Preparing payment…" : "Pay remaining balance")
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(payLoading)
                    }
                    if (liveBooking.balancePaid ?? false) {
                        Label {
                            Text("Balance is already paid.")
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                        }
                        .foregroundStyle(.green)
                    }
                } else {
                    Text("Deposit payment is not enabled right now.")
                        .foregroundStyle(.secondary)
                }
            }
            Section("Event") {
                LabeledContent("Type", value: liveBooking.eventType)
                LabeledContent("Date", value: liveBooking.eventDate)
                LabeledContent("Location", value: liveBooking.eventLocation)
                LabeledContent("Address", value: liveBooking.eventAddress)
                LabeledContent("Package", value: liveBooking.package)
            }
            if !liveBooking.message.isEmpty {
                Section("Message") {
                    Text(liveBooking.message)
                }
            }
            Section("Contract") {
                if let signedAt = liveBooking.customerContractSignedAt, !signedAt.isEmpty {
                    LabeledContent("Status", value: "Signed")
                    if let signedName = liveBooking.customerContractSignedName, !signedName.isEmpty {
                        LabeledContent("Signed by", value: signedName)
                    }
                    LabeledContent("Signed at", value: signedAt)
                } else {
                    Text("Not signed yet.")
                        .foregroundStyle(.secondary)
                    Button("Sign contract now") {
                        showSignSheet = true
                    }
                }
            }
            Section("Photo release") {
                if let signedAt = liveBooking.customerPhotoReleaseSignedAt, !signedAt.isEmpty {
                    LabeledContent("Status", value: "Signed")
                    if let signedName = liveBooking.customerPhotoReleaseSignedName, !signedName.isEmpty {
                        LabeledContent("Signed by", value: signedName)
                    }
                    LabeledContent("Signed at", value: signedAt)
                } else {
                    Text("Not signed yet.")
                        .foregroundStyle(.secondary)
                    Button("Sign photo release") {
                        showPhotoReleaseSignSheet = true
                    }
                }
            }
            Section("Request changes") {
                TextField("Request date, package, or detail changes", text: $changeRequestText, axis: .vertical)
                    .lineLimit(2...5)
                Button(changeRequestSaving ? "Submitting…" : "Submit change request") {
                    submitChangeRequest()
                }
                .disabled(changeRequestSaving || changeRequestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Text("Your request appears for the admin team to review and approve.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !bookingEvents.isEmpty {
                Section("Timeline") {
                    ForEach(bookingEvents) { event in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.message)
                                .font(.subheadline)
                            Text("\(event.type) · \(event.createdAt)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            if !signedDocuments.isEmpty {
                Section("Signed documents") {
                    ForEach(signedDocuments) { doc in
                        Button {
                            PrintService.printHtml(doc.html)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(doc.fileName)
                                    .font(.subheadline.weight(.semibold))
                                Text("\(doc.type) · \(doc.createdAt)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    Text("Opening a signed document uses system print. Choose Save as PDF to download.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        #if os(macOS)
        .controlSize(.small)
        #endif
        .jitterbugMacInsetLeadingScrollableForm()
        .navigationTitle("Booking")
        .onAppear {
            bookingListener?.remove()
            bookingListener = BookingService().observeBooking(id: booking.id) { updated in
                guard let updated else { return }
                DispatchQueue.main.async {
                    liveBooking = updated
                }
            }
            Task {
                let events = await BookingService().listBookingEvents(bookingId: booking.id)
                let docs = await BookingService().listSignedDocumentSnapshots(bookingId: booking.id)
                await MainActor.run {
                    bookingEvents = events
                    signedDocuments = docs
                }
            }
            Task {
                let s = await SettingsService().getSiteSettings()
                await MainActor.run {
                    stripeCheckoutEnabled = s.stripeCheckoutEnabled
                    publicSiteURL = s.stripePublicBaseUrl
                    stripePublishableKey = s.stripeMode == "live" ? s.stripePublishableKeyLive : s.stripePublishableKeyTest
                }
            }
        }
        .onDisappear {
            bookingListener?.remove()
            bookingListener = nil
        }
        .sheet(isPresented: $showSignSheet) {
            CustomerContractSignSheet(booking: liveBooking, user: user) {
                showSignSheet = false
            }
        }
        .sheet(isPresented: $showPhotoReleaseSignSheet) {
            CustomerPhotoReleaseSignSheet(booking: liveBooking, user: user) {
                showPhotoReleaseSignSheet = false
            }
        }
    }

    private func startDepositCheckout() {
        payError = nil
        payLoading = true
        Task {
            do {
                _ = try await StripeNativePayment.presentDepositSheet(
                    bookingId: liveBooking.id,
                    publicSiteBaseURL: publicSiteURL,
                    publishableKey: stripePublishableKey
                )
                await MainActor.run {
                    payLoading = false
                }
            } catch {
                await MainActor.run {
                    payLoading = false
                    payError = error.localizedDescription
                }
            }
        }
    }

    private func startBalanceCheckout() {
        payError = nil
        payLoading = true
        Task {
            do {
                _ = try await StripeNativePayment.presentBalanceSheet(
                    bookingId: liveBooking.id,
                    publicSiteBaseURL: publicSiteURL,
                    publishableKey: stripePublishableKey
                )
                await MainActor.run {
                    payLoading = false
                }
            } catch {
                await MainActor.run {
                    payLoading = false
                    payError = error.localizedDescription
                }
            }
        }
    }

    private func submitChangeRequest() {
        guard let email = user?.email else { return }
        changeRequestSaving = true
        Task {
            do {
                try await BookingService().addCustomerChangeRequest(
                    bookingId: liveBooking.id,
                    requestText: changeRequestText,
                    requesterEmail: email
                )
                let events = await BookingService().listBookingEvents(bookingId: booking.id)
                let docs = await BookingService().listSignedDocumentSnapshots(bookingId: booking.id)
                await MainActor.run {
                    changeRequestSaving = false
                    changeRequestText = ""
                    bookingEvents = events
                    signedDocuments = docs
                }
            } catch {
                await MainActor.run {
                    changeRequestSaving = false
                    payError = error.localizedDescription
                }
            }
        }
    }
}

private struct CustomerPhotoReleaseSignSheet: View {
    let booking: Booking
    let user: User?
    var onDone: () -> Void

    @State private var signerName = ""
    @State private var saving = false
    @State private var error: String?
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []

    private var hasSignature: Bool {
        !strokes.isEmpty || !currentStroke.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo release summary") {
                    Text("By signing, you acknowledge and approve the photo release form for booking \(booking.bookingRef).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Signer") {
                    TextField("Full legal name", text: $signerName)
                }
                Section("Draw signature") {
                    SignaturePad(strokes: $strokes, currentStroke: $currentStroke)
                        .frame(height: 180)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.35), lineWidth: 1))
                    Button("Clear signature") {
                        strokes = []
                        currentStroke = []
                    }
                    .disabled(!hasSignature)
                }
                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Sign Photo Release")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDone)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save signature") {
                        saveSignature()
                    }
                    .disabled(saving)
                }
            }
        }
    }

    private func saveSignature() {
        error = nil
        let cleanedName = signerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else {
            error = "Enter your full legal name."
            return
        }
        let allStrokes = strokes + (currentStroke.isEmpty ? [] : [currentStroke])
        guard allStrokes.contains(where: { !$0.isEmpty }) else {
            error = "Please draw your signature."
            return
        }
        guard let user else {
            error = "You must be signed in."
            return
        }

        saving = true
        let firestoreStrokes: [[[Double]]] = allStrokes.map { stroke in
            stroke.map { [Double($0.x), Double($0.y)] }
        }

        Task {
            do {
                try await BookingService().signCustomerPhotoRelease(
                    booking: booking,
                    signerName: cleanedName,
                    signerEmail: user.email ?? "",
                    signerUid: user.uid,
                    signatureStrokes: firestoreStrokes
                )
                await MainActor.run {
                    saving = false
                    onDone()
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    saving = false
                }
            }
        }
    }
}

private struct CustomerContractSignSheet: View {
    let booking: Booking
    let user: User?
    var onDone: () -> Void

    @State private var signerName = ""
    @State private var saving = false
    @State private var error: String?
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []

    private var hasSignature: Bool {
        !strokes.isEmpty || !currentStroke.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Contract summary") {
                    Text("By signing, you accept the booking contract terms for reference \(booking.bookingRef).")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Signer") {
                    TextField("Full legal name", text: $signerName)
                }
                Section("Draw signature") {
                    SignaturePad(strokes: $strokes, currentStroke: $currentStroke)
                        .frame(height: 180)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.35), lineWidth: 1))
                    Button("Clear signature") {
                        strokes = []
                        currentStroke = []
                    }
                    .disabled(!hasSignature)
                }
                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Sign Contract")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDone)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save signature") {
                        saveSignature()
                    }
                    .disabled(saving)
                }
            }
        }
    }

    private func saveSignature() {
        error = nil
        let cleanedName = signerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else {
            error = "Enter your full legal name."
            return
        }
        let allStrokes = strokes + (currentStroke.isEmpty ? [] : [currentStroke])
        guard allStrokes.contains(where: { !$0.isEmpty }) else {
            error = "Please draw your signature."
            return
        }
        guard let user else {
            error = "You must be signed in."
            return
        }

        saving = true
        let firestoreStrokes: [[[Double]]] = allStrokes.map { stroke in
            stroke.map { [Double($0.x), Double($0.y)] }
        }

        Task {
            do {
                try await BookingService().signCustomerContract(
                    booking: booking,
                    signerName: cleanedName,
                    signerEmail: user.email ?? "",
                    signerUid: user.uid,
                    signatureStrokes: firestoreStrokes
                )
                await MainActor.run {
                    saving = false
                    onDone()
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    saving = false
                }
            }
        }
    }
}

private struct SignaturePad: View {
    @Binding var strokes: [[CGPoint]]
    @Binding var currentStroke: [CGPoint]

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color.clear
                Path { path in
                    for stroke in strokes {
                        guard let first = stroke.first else { continue }
                        path.move(to: first)
                        for point in stroke.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                    if let first = currentStroke.first {
                        path.move(to: first)
                        for point in currentStroke.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.primary, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        currentStroke.append(value.location)
                    }
                    .onEnded { _ in
                        if !currentStroke.isEmpty {
                            strokes.append(currentStroke)
                            currentStroke = []
                        }
                    }
            )
        }
    }
}
