import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)

struct BookingLookupView: View {
    @State private var ref = ""
    @State private var status: BookingStatusPublic?
    @State private var loading = false
    @State private var notFound = false
    @FocusState private var isFieldFocused: Bool

    private var searchFieldBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemGray6)
        #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.gray.opacity(0.15)
        #endif
    }

    private var cardBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.white
        #endif
    }

    private var groupedScrollBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemGroupedBackground)
        #elseif os(macOS)
        Color(nsColor: .underPageBackgroundColor)
        #else
        Color.gray.opacity(0.08)
        #endif
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 44))
                        .symbolRenderingMode(.multicolor)
                    Text("Find your booking")
                        .font(.title2.weight(.semibold))
                    Text("Enter the reference number from your confirmation (e.g. JB-1234)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 8)

                // Search card
                VStack(spacing: 20) {
                    TextField("Booking reference", text: $ref)
                        .textFieldStyle(.plain)
                        #if os(iOS)
                        .textInputAutocapitalization(.characters)
                        #endif
                        .autocorrectionDisabled()
                        .focused($isFieldFocused)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(searchFieldBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onChange(of: ref) { _, _ in
                            status = nil
                            notFound = false
                        }

                    Button(action: lookup) {
                        HStack(spacing: 8) {
                            if loading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                Text("Check status")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canSubmit ? accentPink : Color.gray.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!canSubmit)
                    .animation(.easeInOut(duration: 0.2), value: canSubmit)
                }
                .padding(24)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)

                // Not found
                if notFound {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.multicolor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("No booking found")
                                .font(.subheadline.weight(.medium))
                            Text("Check the reference and try again, or contact us if you need help.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Result card
                if let s = status {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Booking details")
                                .font(.headline)
                            Spacer()
                            statusBadge(s.status)
                        }

                        Divider()

                        detailRow(icon: "calendar", title: "Event date", value: s.eventDate)
                        detailRow(icon: "tag.fill", title: "Event type", value: s.eventType)
                        detailRow(icon: "mappin.circle.fill", title: "Location", value: s.eventLocation)
                        detailRow(
                            icon: "creditcard.fill",
                            title: "Deposit",
                            value: s.depositPaid ? "Received" : "Not recorded yet"
                        )
                    }
                    .padding(24)
                    .background(cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(groupedScrollBackground)
        .navigationTitle("Booking Lookup")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var canSubmit: Bool {
        !ref.trimmingCharacters(in: .whitespaces).isEmpty && !loading
    }

    @ViewBuilder
    private func statusBadge(_ status: BookingStatus) -> some View {
        Text(status.rawValue.capitalized)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(statusColor(status).opacity(0.2))
            .foregroundStyle(statusColor(status))
            .clipShape(Capsule())
    }

    private func statusColor(_ status: BookingStatus) -> Color {
        switch status {
        case .confirmed, .completed: return .green
        case .pending: return .orange
        case .declined: return .gray
        case .cancelled: return .red
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .symbolRenderingMode(.multicolor)
                .frame(width: 24, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value.isEmpty ? "—" : value)
                    .font(.subheadline.weight(.medium))
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func lookup() {
        isFieldFocused = false
        status = nil
        notFound = false
        loading = true
        Task {
            let result = await BookingService().getBookingStatusByRef(ref)
            await MainActor.run {
                loading = false
                if let r = result {
                    status = r
                } else {
                    notFound = true
                }
            }
        }
    }
}
