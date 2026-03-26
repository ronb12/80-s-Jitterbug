import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private enum JBDocumentsColors {
    static var systemGray6: Color {
        #if os(iOS)
        Color(uiColor: .systemGray6)
        #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.gray.opacity(0.15)
        #endif
    }
    static var systemBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.white
        #endif
    }
    static var separatorStroke: Color {
        #if os(iOS)
        Color(uiColor: .separator)
        #elseif os(macOS)
        Color(nsColor: .separatorColor)
        #else
        Color.gray.opacity(0.35)
        #endif
    }
}

private let websiteBaseURL = "https://jitterbug80s.web.app"

private let sampleBooking = Booking(
    id: "sample",
    name: "Sample Client Name",
    email: "client@example.com",
    phone: "646-673-1956",
    eventType: "Wedding",
    eventDate: "2025-08-15",
    eventLocation: "Riverside Venue",
    eventAddress: "123 Main St, Austin, TX 78701",
    package: "Standard",
    message: "Looking forward to the photo booth!",
    photoReleaseConsent: true,
    photoReleaseIncludesMinors: false,
    status: .pending,
    bookingRef: "JB-SAMPLE",
    createdAt: ISO8601DateFormatter().string(from: Date()),
    updatedAt: ISO8601DateFormatter().string(from: Date()),
    depositPaid: nil,
    balancePaid: nil
)

struct AdminDocumentsView: View {
    @State private var bookings: [Booking] = []
    @State private var selectedBookingId: String?
    @State private var loading = true
    @State private var contactInfo = ""
    @State private var ownerName = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Print contracts and photo releases from the app (or save as PDF). You can also open the website in Safari.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Preview with sample data (same contract wording as real)
                Section {
                    Text("Preview the contract layout with sample client data. The wording is the same as the real contract; use \"Print real contract\" for a specific booking below to generate the real contract.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        let (email, phone) = contactInfoSplit(contactInfo)
                        PrintService.printContract(booking: sampleBooking, ownerName: ownerName, contactEmail: email, contactPhone: phone)
                    } label: {
                        Label {
                            Text("Print preview (sample data)")
                        } icon: {
                            Image(systemName: "doc.richtext")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    .disabled(contactInfo.isEmpty)
                    Button {
                        let (email, phone) = contactInfoSplit(contactInfo)
                        PrintService.printPhotoRelease(booking: nil, contactEmail: email, contactPhone: phone)
                    } label: {
                        Label {
                            Text("Print photo release (blank)")
                        } icon: {
                            Image(systemName: "doc")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    .disabled(contactInfo.isEmpty)
                    Link(destination: URL(string: "\(websiteBaseURL)/admin/documents")!) {
                        Label {
                            Text("Open in Safari (alternative)")
                        } icon: {
                            Image(systemName: "safari")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    .font(.caption)
                    sampleContractPreview
                } header: {
                    Text("Contract preview")
                }

                // Real contract for a booking
                Section {
                    Text("Print the real booking contract for a client. It includes the full contract terms, client and event details, photo release, and a signature line. Use Print or Save as PDF to give or file the signed contract.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if loading {
                        Text("Loading bookings…")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if bookings.isEmpty {
                        Text("No bookings yet. Go to Bookings to add one.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Booking", selection: $selectedBookingId) {
                            Text("Select…").tag(nil as String?)
                            ForEach(bookings) { b in
                                Text("\(b.bookingRef) — \(b.name) — \(b.eventDate)").tag(b.id as String?)
                            }
                        }
                        if let id = selectedBookingId, let b = bookings.first(where: { $0.id == id }) {
                            Button {
                                let (email, phone) = contactInfoSplit(contactInfo)
                                PrintService.printContract(booking: b, ownerName: ownerName, contactEmail: email, contactPhone: phone)
                            } label: {
                                Label {
                                    Text("Print real contract")
                                } icon: {
                                    Image(systemName: "doc.richtext")
                                        .symbolRenderingMode(.multicolor)
                                }
                            }
                            .disabled(contactInfo.isEmpty)
                            Button {
                                let (email, phone) = contactInfoSplit(contactInfo)
                                PrintService.printPhotoRelease(booking: b, contactEmail: email, contactPhone: phone)
                            } label: {
                                Label {
                                    Text("Print photo release")
                                } icon: {
                                    Image(systemName: "doc")
                                        .symbolRenderingMode(.multicolor)
                                }
                            }
                            .disabled(contactInfo.isEmpty)
                        }
                    }
                } header: {
                    Text("Contract & photo release")
                }

                // Policies & terms (same as web)
                Section {
                    Text("Open these pages to view or print. Use your browser's Print or \"Save as PDF\" to create a copy.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Link(destination: URL(string: "\(websiteBaseURL)/booking-terms")!) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Booking terms").fontWeight(.medium)
                                Text("Deposit, balance, cancellation, liability, photo release")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    Link(destination: URL(string: "\(websiteBaseURL)/terms")!) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Terms of service").fontWeight(.medium)
                                Text("General website and service terms")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                    Link(destination: URL(string: "\(websiteBaseURL)/privacy")!) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Privacy policy").fontWeight(.medium)
                                Text("How we collect and use information")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .symbolRenderingMode(.multicolor)
                        }
                    }
                } header: {
                    Text("Policies & terms")
                }
            }
            .jitterbugMacListTightUnderNavigationTitle()
            .navigationTitle("Documents")
            .task { load() }
        }
        .jitterbugMacNavigationRootFill()
    }

    private var sampleContractPreview: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {
                Text("80's Jitterbug Photo Booth")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.93, green: 0.28, blue: 0.6))
                Text("Booking Contract")
                    .font(.caption.weight(.semibold))
                Text("This document is the booking contract between 80's Jitterbug Photo Booth and the client named below. By signing below, the client agrees to the terms in this contract.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                contractTable(rows: [
                    ("Booking reference", sampleBooking.bookingRef),
                    ("Status", sampleBooking.status.rawValue),
                    ("Requested", formatDate(sampleBooking.createdAt)),
                ])
                Text("Client").font(.subheadline.weight(.semibold))
                contractTable(rows: [
                    ("Name", sampleBooking.name),
                    ("Email", sampleBooking.email),
                    ("Phone", sampleBooking.phone),
                ])
                Text("Event").font(.subheadline.weight(.semibold))
                contractTable(rows: [
                    ("Type", sampleBooking.eventType),
                    ("Date", sampleBooking.eventDate),
                    ("Location", sampleBooking.eventLocation),
                    ("Full address", sampleBooking.eventAddress),
                    ("Package", sampleBooking.package),
                ])
                Text("Message").font(.subheadline.weight(.semibold))
                Text(sampleBooking.message).font(.caption)
                Text("Photo release").font(.subheadline.weight(.semibold))
                contractTable(rows: [
                    ("Use photos for marketing", sampleBooking.photoReleaseConsent ? "Yes" : "No"),
                    ("Includes minors permission", sampleBooking.photoReleaseIncludesMinors ? "Yes" : "No"),
                ])
                Text("Terms of This Contract").font(.subheadline.weight(.semibold))
                Text("The following terms form part of this contract. By signing below, the client agrees to these terms.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(Array(BookingContractTerms.all.enumerated()), id: \.offset) { _, term in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(term.title).font(.subheadline.weight(.semibold))
                        Text(term.body).font(.caption).fixedSize(horizontal: false, vertical: true)
                    }
                }
                if !contactInfo.isEmpty {
                    Text(ownerName.isEmpty ? "Questions? Contact us: \(contactInfo)" : "Questions? Contact \(ownerName): \(contactInfo)")
                        .font(.caption)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(JBDocumentsColors.systemGray6)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Text("Client signature: _________________________  Date: _______________")
                    .font(.caption)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 400)
        .background(JBDocumentsColors.systemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(JBDocumentsColors.separatorStroke, lineWidth: 1)
        )
    }

    private func contractTable(rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .top) {
                    Text(row.0)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 100, alignment: .leading)
                    Text(row.1)
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func formatDate(_ iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return iso }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    /// Split "email · phone" into (email, phone). Uses defaults if not loaded.
    private func contactInfoSplit(_ s: String) -> (String, String) {
        let parts = s.split(separator: "·", maxSplits: 1, omittingEmptySubsequences: false).map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count >= 2 { return (parts[0], parts[1]) }
        if parts.count == 1, !parts[0].isEmpty { return (parts[0], "") }
        return (SiteSettings.default.contactEmail, SiteSettings.default.contactPhone)
    }

    private func load() {
        loading = true
        Task {
            do {
                let list = try await BookingService().listBookings()
                await MainActor.run {
                    bookings = list
                    if selectedBookingId == nil, let first = list.first { selectedBookingId = first.id }
                    loading = false
                }
            } catch {
                await MainActor.run { loading = false }
            }
            let settings = await SettingsService().getSiteSettings()
            await MainActor.run {
                ownerName = settings.ownerName
                contactInfo = "\(settings.contactEmail) · \(settings.contactPhone)"
            }
        }
    }
}
