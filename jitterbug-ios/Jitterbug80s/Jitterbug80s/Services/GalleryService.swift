import Foundation
import FirebaseFirestore

final class GalleryService {
    private let db = FirebaseManager.shared.db
    private let collectionId = "gallery"

    func listPhotos() async -> [GalleryPhoto] {
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
