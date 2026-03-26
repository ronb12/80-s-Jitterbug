import Foundation

/// In-app Stripe **Payment Sheet** for deposits (iOS / iPadOS / Mac Catalyst only).
/// The native **macOS** target does not link the Stripe iOS SDK (UIKit-based); use website checkout there.
enum StripeNativePaymentError: LocalizedError {
    case invalidBaseURL
    case invalidResponse
    case server(message: String)
    case missingPublishableKey
    case missingClientSecret
    case noPresenter
    case unavailableOnNativeMac

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL: return "Invalid site URL for payments."
        case .invalidResponse: return "Could not start payment. Try again later."
        case .server(let message): return message
        case .missingPublishableKey:
            return "Add your Stripe publishable key in Admin → Settings (pk_test_ or pk_live_ matching your Stripe mode)."
        case .missingClientSecret: return "Server did not return a payment session."
        case .noPresenter: return "Could not show payment screen. Try again."
        case .unavailableOnNativeMac:
            return "In-app Stripe isn’t available in the Mac app. Use iPhone/iPad or pay via your website."
        }
    }
}

enum StripeNativePayment {
    enum PaymentKind: String {
        case deposit
        case balance
    }

    /// - Parameters:
    ///   - publishableKey: `pk_test_…` or `pk_live_…` from Admin → Settings (must match your Stripe secret key mode on the server).
    /// - Returns: `true` if the customer completed payment, `false` if they cancelled.
    @MainActor
    static func presentDepositSheet(
        bookingId: String,
        publicSiteBaseURL: String,
        publishableKey: String
    ) async throws -> Bool {
        try await presentPaymentSheet(
            bookingId: bookingId,
            publicSiteBaseURL: publicSiteBaseURL,
            publishableKey: publishableKey,
            paymentKind: .deposit
        )
    }

    @MainActor
    static func presentBalanceSheet(
        bookingId: String,
        publicSiteBaseURL: String,
        publishableKey: String
    ) async throws -> Bool {
        try await presentPaymentSheet(
            bookingId: bookingId,
            publicSiteBaseURL: publicSiteBaseURL,
            publishableKey: publishableKey,
            paymentKind: .balance
        )
    }

    @MainActor
    private static func presentPaymentSheet(
        bookingId: String,
        publicSiteBaseURL: String,
        publishableKey: String,
        paymentKind: PaymentKind
    ) async throws -> Bool {
#if os(iOS)
        return try await presentDepositSheetIOS(
            bookingId: bookingId,
            publicSiteBaseURL: publicSiteBaseURL,
            publishableKey: publishableKey,
            paymentKind: paymentKind
        )
#else
        throw StripeNativePaymentError.unavailableOnNativeMac
#endif
    }
}

#if os(iOS)
import Stripe
import StripePaymentSheet
import UIKit

extension StripeNativePayment {
    @MainActor
    fileprivate static func presentDepositSheetIOS(
        bookingId: String,
        publicSiteBaseURL: String,
        publishableKey: String,
        paymentKind: PaymentKind
    ) async throws -> Bool {
        let pk = publishableKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !pk.isEmpty else { throw StripeNativePaymentError.missingPublishableKey }

        let base = normalizedBase(publicSiteBaseURL)
        guard let endpoint = URL(string: "\(base)/api/stripePaymentIntent") else {
            throw StripeNativePaymentError.invalidBaseURL
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "bookingId": bookingId,
            "paymentKind": paymentKind.rawValue
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw StripeNativePaymentError.invalidResponse }

        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        if http.statusCode != 200 {
            let msg = (json?["error"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            throw StripeNativePaymentError.server(
                message: (msg?.isEmpty == false) ? msg! : "Payment failed (\(http.statusCode))"
            )
        }
        guard let clientSecret = json?["clientSecret"] as? String, !clientSecret.isEmpty else {
            throw StripeNativePaymentError.missingClientSecret
        }

        StripeAPI.defaultPublishableKey = pk

        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "80's Jitterbug"

        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )

        guard let presenter = topPresenter() else { throw StripeNativePaymentError.noPresenter }

        return try await withCheckedThrowingContinuation { continuation in
            paymentSheet.present(from: presenter) { result in
                switch result {
                case .completed:
                    continuation.resume(returning: true)
                case .canceled:
                    continuation.resume(returning: false)
                case .failed(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func normalizedBase(_ url: String) -> String {
        let t = url.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.hasSuffix("/") ? String(t.dropLast()) : t
    }

    private static func topPresenter() -> UIViewController? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            guard let window = windowScene.windows.first(where: \.isKeyWindow) ?? windowScene.windows.first else { continue }
            var top: UIViewController? = window.rootViewController
            while let presented = top?.presentedViewController { top = presented }
            return top
        }
        return nil
    }
}
#endif
