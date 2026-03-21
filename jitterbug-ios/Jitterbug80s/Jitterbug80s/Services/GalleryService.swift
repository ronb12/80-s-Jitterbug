import Foundation
import FirebaseFirestore

// MARK: - Public site API (Neon gallery on Vercel / Next.js)

private struct GalleryListJSON: Decodable {
    let photos: [GalleryPhotoJSON]
}

private struct GalleryPhotoJSON: Decodable {
    let id: String
    let url: String
    let caption: String?
    let order: Int
    let createdAt: String?
}

private extension GalleryPhoto {
    init(from json: GalleryPhotoJSON) {
        self.init(
            id: json.id,
            url: json.url.trimmingCharacters(in: .whitespacesAndNewlines),
            caption: json.caption?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            order: json.order,
            createdAt: json.createdAt ?? ""
        )
    }
}

final class GalleryService {
    private let db = FirebaseManager.shared.db
    private let collectionId = "gallery"

    /// Loads gallery from the **public** Next.js API (`GET /api/data/gallery` → Neon). Falls back to Firestore if the request fails (offline, wrong base URL, etc.).
    func listPhotos() async -> [GalleryPhoto] {
        if let apiPhotos = await fetchPhotosFromPublicAPI() {
            return apiPhotos
        }
        return await fetchPhotosFromFirestore()
    }

    private func fetchPhotosFromPublicAPI() async -> [GalleryPhoto]? {
        let settings = await SettingsService().getSiteSettings()
        let base = Self.normalizeBaseURL(settings.stripePublicBaseUrl)
        guard let url = URL(string: "\(base)/api/data/gallery") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 25
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { return nil }
            guard (200...299).contains(http.statusCode) else { return nil }
            let decoded = try JSONDecoder().decode(GalleryListJSON.self, from: data)
            return decoded.photos
                .map { GalleryPhoto(from: $0) }
                .filter { !$0.url.isEmpty }
                .sorted { $0.order < $1.order }
        } catch {
            return nil
        }
    }

    private func fetchPhotosFromFirestore() async -> [GalleryPhoto] {
        do {
            let snap = try await db.collection(collectionId)
                .order(by: "order")
                .getDocuments()
            return snap.documents.map { doc in
                let d = doc.data()
                return GalleryPhoto(
                    id: doc.documentID,
                    url: d["url"] as? String ?? "",
                    caption: d["caption"] as? String ?? "",
                    order: d["order"] as? Int ?? 0,
                    createdAt: Self.isoString(from: d["createdAt"])
                )
            }
        } catch {
            return []
        }
    }

    private static func normalizeBaseURL(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        while s.hasSuffix("/") { s.removeLast() }
        if s.isEmpty {
            var d = SiteSettings.default.stripePublicBaseUrl.trimmingCharacters(in: .whitespacesAndNewlines)
            while d.hasSuffix("/") { d.removeLast() }
            return d
        }
        return s
    }

    func addPhoto(url: String, caption: String, order: Int) async throws -> GalleryPhoto {
        let data: [String: Any] = [
            "url": url.trimmingCharacters(in: .whitespacesAndNewlines),
            "caption": caption.trimmingCharacters(in: .whitespacesAndNewlines),
            "order": order,
            "createdAt": FieldValue.serverTimestamp()
        ]
        let ref = try await db.collection(collectionId).addDocument(data: data)
        return GalleryPhoto(
            id: ref.documentID,
            url: url.trimmingCharacters(in: .whitespacesAndNewlines),
            caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
            order: order,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    private static func isoString(from value: Any?) -> String {
        if let t = value as? Timestamp { return ISO8601DateFormatter().string(from: t.dateValue()) }
        if let s = value as? String { return s }
        return ""
    }

    func updatePhoto(id: String, caption: String? = nil, order: Int? = nil, url: String? = nil) async throws {
        var update: [String: Any] = [:]
        if let c = caption { update["caption"] = c }
        if let o = order { update["order"] = o }
        if let u = url { update["url"] = u }
        guard !update.isEmpty else { return }
        try await db.collection(collectionId).document(id).updateData(update)
    }

    func deletePhoto(id: String) async throws {
        try await db.collection(collectionId).document(id).delete()
    }
}
