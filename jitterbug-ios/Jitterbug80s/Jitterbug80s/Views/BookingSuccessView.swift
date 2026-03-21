import SwiftUI
import UIKit

struct BookingSuccessView: View {
    let bookingRef: String
    let bookingId: String
    @State private var copied = false
    @State private var stripeCheckoutEnabled = false
    @State private var publicSiteURL = SiteSettings.default.stripePublicBaseUrl
    /// Publishable key for Stripe Payment Sheet (must match test/live mode).
    @State private var stripePublishableKey = ""
    @State private var payLoading = false
    @State private var payError: String?

    private let accent = Color(red: 0.93, green: 0.28, blue: 0.6)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(accent)
                Text("Request Received!")
                    .font(.title2.bold())
                Text("Your booking reference is:")
                    .foregroundStyle(.secondary)
                Text(bookingRef)
                    .font(.title.monospaced().bold())
                Button {
                    UIPasteboard.general.string = bookingRef
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                } label: {
                    Label(copied ? "Copied!" : "Copy reference", systemImage: copied ? "checkmark.circle" : "doc.on.doc")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(accent)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(copied)

                Text("Please save this reference. We'll get back to you with a quote soon.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if stripeCheckoutEnabled {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pay your deposit")
                            .font(.subheadline.weight(.semibold))
                        Text("Pay in the app with Stripe (Apple Pay or card). You can skip this and pay later—we'll follow up by email.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let payError {
                            Text(payError)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        Button {
                            startCheckout()
                        } label: {
                            HStack {
                                if payLoading { ProgressView().tint(.white) }
                                Text(payLoading ? "Preparing payment…" : "Pay deposit with card")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(payLoading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 4)
                }

                NavigationLink {
                    BookingLookupView()
                } label: {
                    Text("Check booking status anytime")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(accent)
                }
                .padding(.top, 4)
            }
            .padding()
        }
        .task {
            let s = await SettingsService().getSiteSettings()
            stripeCheckoutEnabled = s.stripeCheckoutEnabled
            publicSiteURL = s.stripePublicBaseUrl
            stripePublishableKey = s.stripeMode == "live" ? s.stripePublishableKeyLive : s.stripePublishableKeyTest
        }
    }

    private func startCheckout() {
        payError = nil
        payLoading = true
        Task {
            do {
                let completed = try await StripeNativePayment.presentDepositSheet(
                    bookingId: bookingId,
                    publicSiteBaseURL: publicSiteURL,
                    publishableKey: stripePublishableKey
                )
                await MainActor.run {
                    payLoading = false
                    if completed {
                        payError = nil
                    }
                }
            } catch {
                await MainActor.run {
                    payLoading = false
                    payError = error.localizedDescription
                }
            }
        }
    }
}
