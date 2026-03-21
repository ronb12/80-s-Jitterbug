import SwiftUI

struct BookView: View {
    @State private var form = BookingFormData()
    @State private var eventTypes: [String] = []
    @State private var packages: [PackagePrice] = []
    @State private var loading = true
    @State private var submitting = false
    @State private var error: String?
    @State private var successRef: String?
    @State private var successId: String?

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
            && form.photoReleaseConsent
    }

    var body: some View {
        NavigationStack {
            Group {
                if let ref = successRef, let bid = successId {
                    BookingSuccessView(bookingRef: ref, bookingId: bid)
                } else {
                    Form {
                        Section("Your details") {
                            TextField("Name", text: $form.name)
                            TextField("Email", text: $form.email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                            TextField("Phone", text: $form.phone)
                                .keyboardType(.phonePad)
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
                            TextField("Event location (city/venue)", text: $form.eventLocation)
                            TextField("Full address", text: $form.eventAddress)
                        }
                        Section("Package") {
                            Picker("Package", selection: $form.package) {
                                Text("Select…").tag("")
                                ForEach(packages, id: \.id) { Text($0.name).tag($0.id) }
                            }
                        }
                        Section("Message") {
                            TextField("Additional details", text: $form.message, axis: .vertical)
                                .lineLimit(3...6)
                        }
                        Section {
                            Toggle("I agree to the booking terms and photo release", isOn: $form.photoReleaseConsent)
                            if form.photoReleaseConsent {
                                Toggle("Photo release includes minors", isOn: $form.photoReleaseIncludesMinors)
                            }
                        }

                        if let err = error {
                            Section {
                                Text(err)
                                    .foregroundStyle(.red)
                            }
                        }

                        Section {
                            Button("Submit request") {
                                submit()
                            }
                            .disabled(!isValid || submitting)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Book Your Booth")
            .task {
                async let types: () = loadEventTypes()
                async let pkgs: () = loadPackages()
                _ = await (types, pkgs)
            }
        }
    }

    private func loadEventTypes() async {
        eventTypes = await EventTypesService().getEventTypes()
        if form.eventType.isEmpty, let first = eventTypes.first { form.eventType = first }
    }

    private func loadPackages() async {
        packages = await PackagesService().getPackages()
        loading = false
        if form.package.isEmpty, let first = packages.first { form.package = first.id }
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
    private static func stringFromDate(_ d: Date) -> String {
        dateFormatter.string(from: d)
    }

    private func submit() {
        error = nil
        submitting = true
        Task {
            do {
                let (ref, id) = try await BookingService().submitBooking(form)
                await MainActor.run {
                    successRef = ref
                    successId = id
                    submitting = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    submitting = false
                }
            }
        }
    }
}
