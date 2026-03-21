import Foundation

enum StripeCheckoutError: LocalizedError {
    case invalidBaseURL
    case invalidResponse
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL: return "Invalid site URL for checkout."
        case .invalidResponse: return "Could not start checkout. Try again later."
        case .server(let message): return message
        }
    }
}

/// Calls the same Firebase Hosting rewrite as the website: `POST /api/stripeCheckout`.
final class StripeCheckoutService {
    /// - Parameters:
    ///   - bookingId: Firestore document ID of the booking.
    ///   - publicSiteBaseURL: `SiteSettings.stripePublicBaseUrl` (e.g. https://jitterbug80s.web.app)
    func createCheckoutURL(bookingId: String, publicSiteBaseURL: String) async throws -> URL {
        let trimmed = publicSiteBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.hasSuffix("/") ? String(trimmed.dropLast()) : trimmed
        guard let endpoint = URL(string: "\(base)/api/stripeCheckout") else {
            throw StripeCheckoutError.invalidBaseURL
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["bookingId": bookingId])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw StripeCheckoutError.invalidResponse }

        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        if http.statusCode != 200 {
            let msg = (json?["error"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            throw StripeCheckoutError.server(message: msg?.isEmpty == false ? msg! : "Checkout failed (\(http.statusCode))")
        }
        guard let urlString = json?["url"] as? String, let url = URL(string: urlString) else {
            throw StripeCheckoutError.invalidResponse
        }
        return url
    }
}
