import SwiftUI
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private let websiteBaseURL = "https://jitterbug80s.web.app"

private func jbCopyStringToPasteboard(_ string: String) {
    #if os(iOS)
    UIPasteboard.general.string = string
    #elseif os(macOS)
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(string, forType: .string)
    #endif
}

struct AdminBookingsView: View {
    private enum QueueFilter: String, CaseIterable {
        case all = "All"
        case actionRequired = "Action required"
        case needsContract = "Needs contract"
        case needsPhotoRelease = "Needs photo release"
        case unpaid = "Unpaid"
    }

    private enum ContractSignFilter: String, CaseIterable {
        case all = "All"
        case signedOnly = "Signed only"
        case unsignedOnly = "Unsigned only"
    }

    private enum PhotoReleaseSignFilter: String, CaseIterable {
        case all = "All"
        case signedOnly = "Signed only"
        case unsignedOnly = "Unsigned only"
    }

    @State private var bookings: [Booking] = []
    @State private var loading = true
    @State private var error: String?
    @State private var filterStatus: BookingStatus?
    @State private var contractSignFilter: ContractSignFilter = .all
    @State private var photoReleaseSignFilter: PhotoReleaseSignFilter = .all
    @State private var queueFilter: QueueFilter = .all
    @State private var searchText = ""
    @State private var selectedBooking: Booking?
    @State private var exportItem: ExportableURL?
    @State private var showAddBooking = false

    private var filtered: [Booking] {
        var list = bookings
        if let status = filterStatus {
            list = list.filter { $0.status == status }
        }
        switch contractSignFilter {
        case .all:
            break
        case .signedOnly:
            list = list.filter { ($0.customerContractSignedAt?.isEmpty == false) }
        case .unsignedOnly:
            list = list.filter { ($0.customerContractSignedAt?.isEmpty != false) }
        }
        switch photoReleaseSignFilter {
        case .all:
            break
        case .signedOnly:
            list = list.filter { ($0.customerPhotoReleaseSignedAt?.isEmpty == false) }
        case .unsignedOnly:
            list = list.filter { ($0.customerPhotoReleaseSignedAt?.isEmpty != false) }
        }
        switch queueFilter {
        case .all:
            break
        case .actionRequired:
            list = list.filter {
                ($0.customerContractSignedAt?.isEmpty != false)
                    || ($0.customerPhotoReleaseSignedAt?.isEmpty != false)
                    || (($0.depositPaid ?? false) == false)
                    || (($0.balancePaid ?? false) == false)
            }
        case .needsContract:
            list = list.filter { ($0.customerContractSignedAt?.isEmpty != false) }
        case .needsPhotoRelease:
            list = list.filter { ($0.customerPhotoReleaseSignedAt?.isEmpty != false) }
        case .unpaid:
            list = list.filter { (($0.depositPaid ?? false) == false) || (($0.balancePaid ?? false) == false) }
        }
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
            list = list.filter {
                $0.name.lowercased().contains(q)
                    || $0.email.lowercased().contains(q)
                    || $0.phone.contains(q)
                    || $0.bookingRef.uppercased().contains(q.uppercased())
                    || $0.eventLocation.lowercased().contains(q)
            }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            bookingStatsView
                        }

                        Section {
                            Button {
                                showAddBooking = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .symbolRenderingMode(.multicolor)
                                    Text("Add booking")
                                        .font(.headline)
                                        .foregroundStyle(Color(red: 0.93, green: 0.28, blue: 0.6))
                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                        } header: {
                            Text("Manual booking")
                        } footer: {
                            Text("Create a new booking as the owner (e.g. from a phone call or in-person request).")
                        }

                        Section("Bookings") {
                            ForEach(filtered) { b in
                                Button {
                                    selectedBooking = b
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(b.name).font(.headline)
                                        Text(b.bookingRef).font(.caption.monospaced())
                                        Text(b.eventDate).font(.caption2).foregroundStyle(.secondary)
                                        Text(b.status.rawValue.capitalized)
                                            .font(.caption2)
                                            .foregroundStyle(statusColor(b.status))
                                        if let signedAt = b.customerContractSignedAt, !signedAt.isEmpty {
                                            Label {
                                                Text("Contract signed")
                                            } icon: {
                                                Image(systemName: "signature")
                                                    .symbolRenderingMode(.multicolor)
                                            }
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(.green)
                                            .accessibilityLabel("Contract signed at \(signedAt)")
                                        }
                                        if let signedAt = b.customerPhotoReleaseSignedAt, !signedAt.isEmpty {
                                            Label {
                                                Text("Photo release signed")
                                            } icon: {
                                                Image(systemName: "photo.on.rectangle.angled")
                                                    .symbolRenderingMode(.multicolor)
                                            }
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(.green)
                                            .accessibilityLabel("Photo release signed at \(signedAt)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Name, email, phone, ref, location")
                    .jitterbugMacListTightUnderNavigationTitle()
                }
            }
            .navigationTitle("Bookings")
            .toolbar {
                Menu {
                    Button("All") { filterStatus = nil }
                    ForEach(BookingStatus.allCases, id: \.self) { s in
                        Button(s.rawValue.capitalized) { filterStatus = s }
                    }
                } label: { Text("Filter") }
                Menu {
                    ForEach(ContractSignFilter.allCases, id: \.self) { option in
                        Button(option.rawValue) { contractSignFilter = option }
                    }
                } label: { Text("Contract") }
                Menu {
                    ForEach(PhotoReleaseSignFilter.allCases, id: \.self) { option in
                        Button(option.rawValue) { photoReleaseSignFilter = option }
                    }
                } label: { Text("Photo release") }
                Menu {
                    ForEach(QueueFilter.allCases, id: \.self) { option in
                        Button(option.rawValue) { queueFilter = option }
                    }
                } label: { Text("Queue") }
                Button("Export CSV") { exportCSV() }
                    .disabled(filtered.isEmpty)
                Button("Add booking") { showAddBooking = true }
            }
            .sheet(item: $selectedBooking) { b in
                AdminBookingDetailView(booking: b, onDismiss: { selectedBooking = nil }, onUpdated: { load() })
            }
            .sheet(isPresented: $showAddBooking) {
                AdminAddBookingSheet(onDismiss: { showAddBooking = false }, onAdded: { load(); showAddBooking = false })
            }
            .sheet(item: $exportItem) { item in
                ExportedFileShareSheet(exportURL: item.url, onDismiss: { exportItem = nil })
            }
            .task { load() }
        }
        .jitterbugMacNavigationRootFill()
    }

    private var bookingStatsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            let pending = bookings.filter { $0.status == .pending }.count
            let confirmed = bookings.filter { $0.status == .confirmed }.count
            let completed = bookings.filter { $0.status == .completed }.count
            let declined = bookings.filter { $0.status == .declined }.count
            let cancelled = bookings.filter { $0.status == .cancelled }.count
            Text("\(pending) Pending · \(confirmed) Confirmed · \(completed) Completed · \(declined) Declined · \(cancelled) Cancelled")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let next = nextUpcomingBooking {
                Text("Next: \(next.eventDate) — \(next.eventType) — \(next.name)")
                    .font(.subheadline.weight(.medium))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var nextUpcomingBooking: Booking? {
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        return bookings
            .filter { $0.status == .confirmed && $0.eventDate >= today }
            .sorted { $0.eventDate < $1.eventDate }
            .first
    }

    private func statusColor(_ s: BookingStatus) -> Color {
        switch s {
        case .confirmed, .completed: return .green
        case .declined, .cancelled: return .red
        case .pending: return .orange
        }
    }

    private func load() {
        loading = true
        Task {
            do {
                bookings = try await BookingService().listBookings()
                await MainActor.run { loading = false }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    loading = false
                }
            }
        }
    }

    private func exportCSV() {
        let header = "Ref,Name,Email,Phone,Event Type,Date,Location,Address,Package,Status,Message,Created\n"
        let rows = filtered.map { b in
            [b.bookingRef, b.name, b.email, b.phone, b.eventType, b.eventDate, b.eventLocation, b.eventAddress, b.package, b.status.rawValue, b.message.replacingOccurrences(of: "\"", with: "\"\""), b.createdAt]
                .map { "\"\(String(describing: $0).replacingOccurrences(of: "\"", with: "\"\""))\"" }
                .joined(separator: ",")
        }
        let csv = header + rows.joined(separator: "\n")
        let fileName = "bookings-\(ISO8601DateFormatter().string(from: Date()).prefix(10)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        exportItem = ExportableURL(url: url)
    }
}

private struct ExportableURL: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Add booking sheet
struct AdminAddBookingSheet: View {
    var onDismiss: () -> Void
    var onAdded: () -> Void
    @State private var form = BookingFormData()
    @State private var eventTypes: [String] = []
    @State private var packages: [PackagePrice] = []
    @State private var adding = false
    @State private var error: String?

    private var isValid: Bool {
        !form.name.trimmingCharacters(in: .whitespaces).isEmpty
            && !form.email.trimmingCharacters(in: .whitespaces).isEmpty
            && form.email.contains("@")
            && !form.phone.trimmingCharacters(in: .whitespaces).isEmpty
            && !form.eventType.isEmpty
            && !form.eventDate.isEmpty
            && !form.eventLocation.trimmingCharacters(in: .whitespaces).isEmpty
            && !form.eventAddress.trimmingCharacters(in: .whitespaces).isEmpty
            && !form.package.isEmpty
    }

    var body: some View {
        NavigationStack {
            addBookingForm
                .jitterbugMacInsetLeadingScrollableForm()
                .navigationTitle("Add booking")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel", action: onDismiss) }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") { add() }
                            .disabled(!isValid || adding)
                    }
                }
                .task {
                    eventTypes = await EventTypesService().getEventTypes()
                    packages = await PackagesService().getPackages()
                    if form.eventType.isEmpty, let f = eventTypes.first { form.eventType = f }
                    if form.package.isEmpty, let p = packages.first { form.package = p.id }
                }
        }
        .jitterbugMacNavigationRootFill()
        .jitterbugMacSheetChromeIfNeeded()
    }

    private var addBookingForm: some View {
        Form {
            Section("Client") {
                TextField("Name", text: $form.name)
                TextField("Email", text: $form.email)
                    #if os(iOS)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    #endif
                TextField("Phone", text: $form.phone)
                    #if os(iOS)
                    .keyboardType(.phonePad)
                    #endif
            }
            Section("Event") {
                Picker("Event type", selection: $form.eventType) {
                    Text("Select…").tag("")
                    ForEach(eventTypes, id: \.self) { Text($0).tag($0) }
                }
                DatePicker("Event date", selection: Binding(
                    get: { Self.dateFromString(form.eventDate) ?? Date() },
                    set: { form.eventDate = Self.stringFromDate($0) }
                ), displayedComponents: .date)
                #if os(macOS)
                .datePickerStyle(.compact)
                #endif
                TextField("Event location", text: $form.eventLocation)
                TextField("Full address", text: $form.eventAddress)
            }
            Section("Package") {
                Picker("Package", selection: $form.package) {
                    Text("Select…").tag("")
                    ForEach(packages, id: \.id) { Text($0.name).tag($0.id) }
                }
            }
            Section("Message") {
                #if os(iOS)
                TextField("Additional details", text: $form.message, axis: .vertical)
                    .lineLimit(2...4)
                #elseif os(macOS)
                TextField("Additional details", text: $form.message)
                    .lineLimit(2...4)
                #else
                TextField("Additional details", text: $form.message)
                    .lineLimit(4)
                #endif
            }
            Section {
                Toggle("Photo release consent", isOn: $form.photoReleaseConsent)
                if form.photoReleaseConsent {
                    Toggle("Includes minors", isOn: $form.photoReleaseIncludesMinors)
                }
            }
            if let err = error {
                Section { Text(err).foregroundStyle(.red) }
            }
        }
        #if os(macOS)
        .controlSize(.small)
        #endif
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    private static func dateFromString(_ s: String) -> Date? {
        guard !s.isEmpty else { return nil }
        return dateFormatter.date(from: s) ?? ISO8601DateFormatter().date(from: s)
    }
    private static func stringFromDate(_ d: Date) -> String { dateFormatter.string(from: d) }

    private func add() {
        error = nil
        adding = true
        Task {
            do {
                _ = try await BookingService().submitBooking(form)
                await MainActor.run { onAdded() }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    adding = false
                }
            }
        }
    }
}

struct AdminBookingDetailView: View {
    let booking: Booking
    var onDismiss: () -> Void
    var onUpdated: () -> Void
    @State private var status: BookingStatus
    @State private var depositPaid: Bool
    @State private var balancePaid: Bool
    @State private var saving = false
    @State private var isEditing = false
    @State private var editForm: BookingFormData
    @State private var showDeleteConfirm = false
    @State private var copied = false
    @State private var eventTypes: [String] = []
    @State private var packages: [PackagePrice] = []
    @State private var contactOwnerName = ""
    @State private var contactEmail = ""
    @State private var contactPhone = ""
    @State private var stripeCheckoutEnabled = false
    @State private var stripePublicSiteURL = SiteSettings.default.stripePublicBaseUrl
    @State private var stripePublishableKey = ""
    @State private var stripePayLoading = false
    @State private var stripePayError: String?
    @State private var changeRequests: [BookingChangeRequest] = []
    @State private var bookingEvents: [BookingEvent] = []

    init(booking: Booking, onDismiss: @escaping () -> Void, onUpdated: @escaping () -> Void) {
        self.booking = booking
        self.onDismiss = onDismiss
        self.onUpdated = onUpdated
        _status = State(initialValue: booking.status)
        _depositPaid = State(initialValue: booking.depositPaid ?? false)
        _balancePaid = State(initialValue: booking.balancePaid ?? false)
        var f = BookingFormData()
        f.name = booking.name
        f.email = booking.email
        f.phone = booking.phone
        f.eventType = booking.eventType
        f.eventDate = booking.eventDate
        f.eventLocation = booking.eventLocation
        f.eventAddress = booking.eventAddress
        f.package = booking.package
        f.message = booking.message
        f.photoReleaseConsent = booking.photoReleaseConsent
        f.photoReleaseIncludesMinors = booking.photoReleaseIncludesMinors
        _editForm = State(initialValue: f)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Reference") {
                    HStack {
                        Text(booking.bookingRef).font(.headline.monospaced())
                        Spacer()
                        Button(copied ? "Copied" : "Copy ref") {
                            jbCopyStringToPasteboard(booking.bookingRef)
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                        }
                        .disabled(copied)
                    }
                }
                if isEditing {
                    Section("Client") {
                        TextField("Name", text: $editForm.name)
                        TextField("Email", text: $editForm.email)
                            #if os(iOS)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            #endif
                        TextField("Phone", text: $editForm.phone)
                            #if os(iOS)
                            .keyboardType(.phonePad)
                            #endif
                    }
                    Section("Event") {
                        Picker("Event type", selection: $editForm.eventType) {
                            ForEach(eventTypes, id: \.self) { Text($0).tag($0) }
                        }
                        DatePicker("Event date", selection: Binding(
                            get: { DetailView.dateFromString(editForm.eventDate) ?? Date() },
                            set: { editForm.eventDate = DetailView.stringFromDate($0) }
                        ), displayedComponents: .date)
                        #if os(macOS)
                        .datePickerStyle(.compact)
                        #endif
                        TextField("Event location", text: $editForm.eventLocation)
                        TextField("Full address", text: $editForm.eventAddress)
                    }
                    Section("Package") {
                        Picker("Package", selection: $editForm.package) {
                            ForEach(packages, id: \.id) { Text($0.name).tag($0.id) }
                        }
                    }
                    Section("Message") {
                        #if os(iOS)
                        TextField("Details", text: $editForm.message, axis: .vertical)
                            .lineLimit(2...4)
                        #elseif os(macOS)
                        TextField("Details", text: $editForm.message)
                            .lineLimit(2...4)
                        #else
                        TextField("Details", text: $editForm.message)
                            .lineLimit(4)
                        #endif
                    }
                    Section {
                        Toggle("Photo release consent", isOn: $editForm.photoReleaseConsent)
                        if editForm.photoReleaseConsent {
                            Toggle("Includes minors", isOn: $editForm.photoReleaseIncludesMinors)
                        }
                    }
                    Section("Status") {
                        Picker("Status", selection: $status) {
                            ForEach(BookingStatus.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                        }
                    }
                } else {
                    Section("Details") {
                        LabeledContent("Name", value: booking.name)
                        LabeledContent("Email", value: booking.email)
                        LabeledContent("Phone", value: booking.phone)
                        LabeledContent("Event type", value: booking.eventType)
                        LabeledContent("Date", value: booking.eventDate)
                        LabeledContent("Location", value: booking.eventLocation)
                        LabeledContent("Address", value: booking.eventAddress)
                        LabeledContent("Package", value: booking.package)
                        if !booking.message.isEmpty {
                            LabeledContent("Message", value: booking.message)
                        }
                    }
                    Section("Status") {
                        Picker("Status", selection: $status) {
                            ForEach(BookingStatus.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                        }
                        .onChange(of: status) { _, new in saveStatus(new) }
                    }
                    Section("Payment") {
                        if stripeCheckoutEnabled && !depositPaid {
                            Button {
                                openStripeDepositCheckout()
                            } label: {
                                Label {
                                    Text(stripePayLoading ? "Preparing payment…" : "Customer: pay deposit (Stripe)")
                                } icon: {
                                    Image(systemName: "creditcard")
                                        .symbolRenderingMode(.multicolor)
                                }
                            }
                            .disabled(stripePayLoading)
                            if let stripePayError {
                                Text(stripePayError)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            Text("Opens Stripe Payment Sheet in the app. Requires deploy of stripePaymentIntent function, webhook event payment_intent.succeeded, and publishable key in Admin → Settings.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Toggle("Deposit paid", isOn: $depositPaid)
                            .onChange(of: depositPaid) { _, _ in savePaymentFlags() }
                        Toggle("Balance paid", isOn: $balancePaid)
                            .onChange(of: balancePaid) { _, _ in savePaymentFlags() }
                    }
                    Section("Contract") {
                        if let signedAt = booking.customerContractSignedAt, !signedAt.isEmpty {
                            LabeledContent("Status", value: "Signed")
                            if let signedName = booking.customerContractSignedName, !signedName.isEmpty {
                                LabeledContent("Signed by", value: signedName)
                            }
                            LabeledContent("Signed at", value: signedAt)
                        } else {
                            LabeledContent("Status", value: "Not signed")
                        }
                    }
                    Section("Photo release") {
                        if let signedAt = booking.customerPhotoReleaseSignedAt, !signedAt.isEmpty {
                            LabeledContent("Status", value: "Signed")
                            if let signedName = booking.customerPhotoReleaseSignedName, !signedName.isEmpty {
                                LabeledContent("Signed by", value: signedName)
                            }
                            LabeledContent("Signed at", value: signedAt)
                        } else {
                            LabeledContent("Status", value: "Not signed")
                        }
                    }
                    if !changeRequests.isEmpty {
                        Section("Customer change requests") {
                            ForEach(changeRequests) { req in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(req.requestText)
                                        .font(.subheadline)
                                    Text("\(req.requesterEmail) · \(req.createdAt)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                    if req.status == "pending" {
                                        HStack {
                                            Button("Approve") { resolveChangeRequest(req.id, status: "approved") }
                                            Button("Reject", role: .destructive) { resolveChangeRequest(req.id, status: "rejected") }
                                        }
                                        .font(.caption)
                                    } else {
                                        Text("Status: \(req.status.capitalized)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
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
                }
                Section {
                    Link("Email client", destination: URL(string: "mailto:\(booking.email)")!)
                }
                Section("Print") {
                    Button {
                        PrintService.printContract(booking: booking, ownerName: contactOwnerName, contactEmail: contactEmail, contactPhone: contactPhone)
                    } label: {
                        Label {
                            Text("Print contract")
                        } icon: {
                            Image(systemName: "doc.richtext")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    .disabled(contactEmail.isEmpty)
                    Button {
                        PrintService.printPhotoRelease(booking: booking, contactEmail: contactEmail, contactPhone: contactPhone)
                    } label: {
                        Label {
                            Text("Print photo release")
                        } icon: {
                            Image(systemName: "doc")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    .disabled(contactEmail.isEmpty)
                }
                Section {
                    Button(role: .destructive, action: { showDeleteConfirm = true }) {
                        Label {
                            Text("Delete booking")
                        } icon: {
                            Image(systemName: "trash")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                }
            }
            #if os(macOS)
            .controlSize(.small)
            #endif
            .jitterbugMacInsetLeadingScrollableForm()
            .navigationTitle(booking.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if isEditing {
                        Button("Cancel") { isEditing = false }
                    } else {
                        Button("Done", action: onDismiss)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("Save") { saveEdit() }
                            .disabled(saving)
                    } else {
                        Button("Edit") { isEditing = true }
                    }
                }
            }
            .onChange(of: isEditing) { _, editing in
                if editing {
                    Task {
                        eventTypes = await EventTypesService().getEventTypes()
                        packages = await PackagesService().getPackages()
                    }
                }
            }
            .alert("Delete booking?", isPresented: $showDeleteConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { deleteBooking() }
            } message: {
                Text("This cannot be undone.")
            }
            .task {
                let s = await SettingsService().getSiteSettings()
                contactOwnerName = s.ownerName
                contactEmail = s.contactEmail
                contactPhone = s.contactPhone
                stripeCheckoutEnabled = s.stripeCheckoutEnabled
                stripePublicSiteURL = s.stripePublicBaseUrl
                stripePublishableKey = s.stripeMode == "live" ? s.stripePublishableKeyLive : s.stripePublishableKeyTest
                changeRequests = await BookingService().listChangeRequests(bookingId: booking.id)
                bookingEvents = await BookingService().listBookingEvents(bookingId: booking.id)
            }
        }
        .jitterbugMacNavigationRootFill()
        .jitterbugMacSheetChromeIfNeeded()
    }

    private func openStripeDepositCheckout() {
        stripePayError = nil
        stripePayLoading = true
        Task {
            do {
                _ = try await StripeNativePayment.presentDepositSheet(
                    bookingId: booking.id,
                    publicSiteBaseURL: stripePublicSiteURL,
                    publishableKey: stripePublishableKey
                )
                await MainActor.run {
                    stripePayLoading = false
                }
            } catch {
                await MainActor.run {
                    stripePayLoading = false
                    stripePayError = error.localizedDescription
                }
            }
        }
    }

    private func savePaymentFlags() {
        Task {
            try? await BookingService().updateBooking(id: booking.id, data: [
                "depositPaid": depositPaid,
                "balancePaid": balancePaid
            ])
            await MainActor.run { onUpdated() }
        }
    }

    private enum DetailView {
        static let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f
        }()
        static func dateFromString(_ s: String) -> Date? {
            guard !s.isEmpty else { return nil }
            return dateFormatter.date(from: s) ?? ISO8601DateFormatter().date(from: s)
        }
        static func stringFromDate(_ d: Date) -> String { dateFormatter.string(from: d) }
    }

    private func saveStatus(_ s: BookingStatus) {
        saving = true
        Task {
            try? await BookingService().updateBooking(id: booking.id, data: ["status": s.rawValue])
            await MainActor.run { saving = false; onUpdated() }
        }
    }

    private func saveEdit() {
        saving = true
        Task {
            do {
                try await BookingService().updateBooking(id: booking.id, data: [
                    "name": editForm.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    "email": editForm.email.trimmingCharacters(in: .whitespacesAndNewlines),
                    "phone": editForm.phone.trimmingCharacters(in: .whitespacesAndNewlines),
                    "eventType": editForm.eventType,
                    "eventDate": editForm.eventDate,
                    "eventLocation": editForm.eventLocation.trimmingCharacters(in: .whitespacesAndNewlines),
                    "eventAddress": editForm.eventAddress.trimmingCharacters(in: .whitespacesAndNewlines),
                    "package": editForm.package,
                    "message": editForm.message.trimmingCharacters(in: .whitespacesAndNewlines),
                    "photoReleaseConsent": editForm.photoReleaseConsent,
                    "photoReleaseIncludesMinors": editForm.photoReleaseIncludesMinors,
                    "status": status.rawValue,
                    "depositPaid": depositPaid,
                    "balancePaid": balancePaid
                ])
                await MainActor.run { saving = false; isEditing = false; onUpdated() }
            } catch {
                await MainActor.run { saving = false }
            }
        }
    }

    private func deleteBooking() {
        Task {
            try? await BookingService().deleteBooking(id: booking.id)
            await MainActor.run { onDismiss(); onUpdated() }
        }
    }

    private func resolveChangeRequest(_ requestId: String, status: String) {
        Task {
            try? await BookingService().resolveChangeRequest(bookingId: booking.id, requestId: requestId, status: status)
            let nextRequests = await BookingService().listChangeRequests(bookingId: booking.id)
            let nextEvents = await BookingService().listBookingEvents(bookingId: booking.id)
            await MainActor.run {
                changeRequests = nextRequests
                bookingEvents = nextEvents
                onUpdated()
            }
        }
    }
}
