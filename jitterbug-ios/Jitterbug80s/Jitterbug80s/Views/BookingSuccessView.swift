import SwiftUI
import UIKit

struct BookingSuccessView: View {
    let bookingRef: String
    let bookingId: String
    @State private var copied = false
    @State private var stripeCheckoutEnabled = false
    @State private var publicSiteURL = SiteSettings.default.stripePublicBaseUrl
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
                        Text("Secure checkout with Stripe. You can skip this and pay later—we'll follow up by email.")
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
                                Text(payLoading ? "Opening checkout…" : "Pay deposit with card")
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
        }
    }

    private func startCheckout() {
        payError = nil
        payLoading = true
        Task {
            do {
                let url = try await StripeCheckoutService().createCheckoutURL(
                    bookingId: bookingId,
                    publicSiteBaseURL: publicSiteURL
                )
                await MainActor.run {
                    payLoading = false
                    UIApplication.shared.open(url)
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
