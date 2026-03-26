import Foundation
import FirebaseFirestore

private struct PublicSiteSettingsJSON: Decodable {
    let ownerName: String?
    let contactEmail: String?
    let contactPhone: String?
    let serviceArea: String?
    let stripePublicBaseUrl: String?
    let stripeCheckoutEnabled: Bool?
    let stripeDepositCents: Int?
    let stripePublishableKeyTest: String?
    let stripePublishableKeyLive: String?
    let stripeMode: String?
}

struct SiteSettings {
    var ownerName: String
    var contactEmail: String
    var contactPhone: String
    var serviceArea: String
    /// Base URL for Stripe redirects (no trailing slash).
    var stripePublicBaseUrl: String
    var stripeCheckoutEnabled: Bool
    /// Deposit in USD cents (e.g. 5000 = $50).
    var stripeDepositCents: Int
    /// Publishable keys only — never store sk_ secrets here (Firestore is public-read).
    var stripePublishableKeyTest: String
    var stripePublishableKeyLive: String
    /// "test" or "live" for display / future client Stripe use.
    var stripeMode: String
}

extension SiteSettings {
    static let `default` = SiteSettings(
        ownerName: "Shequanna Bowie",
        contactEmail: "sbowie207@gmail.com",
        contactPhone: "646-673-1956",
        serviceArea: "Augusta, GA and surrounding areas.",
        stripePublicBaseUrl: "https://jitterbug80s.web.app",
        stripeCheckoutEnabled: false,
        stripeDepositCents: 5000,
        stripePublishableKeyTest: "",
        stripePublishableKeyLive: "",
        stripeMode: "test"
    )
}

final class SettingsService {
    private let db = FirebaseManager.shared.db
    private let docPath = "settings/site"

    func getSiteSettings() async -> SiteSettings {
        let firestoreSettings = await readFirestoreSettings()
        if let apiSettings = await fetchPublicSiteSettings(baseURL: firestoreSettings.stripePublicBaseUrl) {
            return apiSettings
        }
        return firestoreSettings
    }

    private func readFirestoreSettings() async -> SiteSettings {
        do {
            let snap = try await db.document(docPath).getDocument()
            guard snap.exists, let data = snap.data() else { return .default }
            let modeStr = (data["stripeMode"] as? String)?.lowercased()
            let stripeMode = (modeStr == "live") ? "live" : "test"
            let dep: Int = {
                if let i = data["stripeDepositCents"] as? Int { return i }
                if let i64 = data["stripeDepositCents"] as? Int64 { return Int(i64) }
                return (data["stripeDepositCents"] as? NSNumber)?.intValue ?? SiteSettings.default.stripeDepositCents
            }()
            let baseRaw = (data["stripePublicBaseUrl"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? SiteSettings.default.stripePublicBaseUrl
            let baseUrl = baseRaw.hasSuffix("/") ? String(baseRaw.dropLast()) : baseRaw
            return SiteSettings(
                ownerName: (data["ownerName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? SiteSettings.default.ownerName,
                contactEmail: (data["contactEmail"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? SiteSettings.default.contactEmail,
                contactPhone: (data["contactPhone"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? SiteSettings.default.contactPhone,
                serviceArea: (data["serviceArea"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? SiteSettings.default.serviceArea,
                stripePublicBaseUrl: baseUrl,
                stripeCheckoutEnabled: data["stripeCheckoutEnabled"] as? Bool ?? false,
                stripeDepositCents: max(50, dep),
                stripePublishableKeyTest: (data["stripePublishableKeyTest"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                stripePublishableKeyLive: (data["stripePublishableKeyLive"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                stripeMode: stripeMode
            )
        } catch {
            return .default
        }
    }

    private func fetchPublicSiteSettings(baseURL: String) async -> SiteSettings? {
        var base = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        while base.hasSuffix("/") { base.removeLast() }
        if base.isEmpty {
            base = SiteSettings.default.stripePublicBaseUrl
        }
        guard let url = URL(string: "\(base)/api/data/site-settings") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                return nil
            }
            let decoded = try JSONDecoder().decode(PublicSiteSettingsJSON.self, from: data)
            let mode = (decoded.stripeMode ?? "test").lowercased() == "live" ? "live" : "test"
            let resolvedBaseRaw = decoded.stripePublicBaseUrl?.trimmingCharacters(in: .whitespacesAndNewlines) ?? base
            let resolvedBase = resolvedBaseRaw.hasSuffix("/") ? String(resolvedBaseRaw.dropLast()) : resolvedBaseRaw
            return SiteSettings(
                ownerName: decoded.ownerName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? SiteSettings.default.ownerName,
                contactEmail: decoded.contactEmail?.trimmingCharacters(in: .whitespacesAndNewlines) ?? SiteSettings.default.contactEmail,
                contactPhone: decoded.contactPhone?.trimmingCharacters(in: .whitespacesAndNewlines) ?? SiteSettings.default.contactPhone,
                serviceArea: decoded.serviceArea?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? SiteSettings.default.serviceArea,
                stripePublicBaseUrl: resolvedBase,
                stripeCheckoutEnabled: decoded.stripeCheckoutEnabled ?? false,
                stripeDepositCents: max(50, decoded.stripeDepositCents ?? SiteSettings.default.stripeDepositCents),
                stripePublishableKeyTest: decoded.stripePublishableKeyTest?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                stripePublishableKeyLive: decoded.stripePublishableKeyLive?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                stripeMode: mode
            )
        } catch {
            return nil
        }
    }

    func updateSiteSettings(_ settings: SiteSettings) async throws {
        let stripeUrl: String = {
            let u = settings.stripePublicBaseUrl.trimmingCharacters(in: .whitespacesAndNewlines)
            if u.isEmpty { return SiteSettings.default.stripePublicBaseUrl }
            return u.hasSuffix("/") ? String(u.dropLast()) : u
        }()
        let data: [String: Any] = [
            "ownerName": settings.ownerName.isEmpty ? SiteSettings.default.ownerName : settings.ownerName,
            "contactEmail": settings.contactEmail,
            "contactPhone": settings.contactPhone,
            "serviceArea": settings.serviceArea.isEmpty ? SiteSettings.default.serviceArea : settings.serviceArea,
            "stripePublicBaseUrl": stripeUrl,
            "stripeCheckoutEnabled": settings.stripeCheckoutEnabled,
            "stripeDepositCents": max(50, settings.stripeDepositCents),
            "stripePublishableKeyTest": settings.stripePublishableKeyTest,
            "stripePublishableKeyLive": settings.stripePublishableKeyLive,
            "stripeMode": settings.stripeMode == "live" ? "live" : "test"
        ]
        try await db.document(docPath).setData(data)
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
