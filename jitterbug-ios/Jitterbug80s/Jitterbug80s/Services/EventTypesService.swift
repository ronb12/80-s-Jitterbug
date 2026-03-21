import Foundation
import FirebaseFirestore

final class EventTypesService {
    private let db = FirebaseManager.shared.db
    private let docPath = "settings/eventTypes"

    static let defaultTypes = ["Wedding", "Birthday", "Corporate", "Party", "Other"]

    func getEventTypes() async -> [String] {
        do {
            let snap = try await db.document(docPath).getDocument()
            guard snap.exists, let data = snap.data(),
                  let list = data["eventTypes"] as? [String] else {
                return Self.defaultTypes
            }
            return list.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        } catch {
            return Self.defaultTypes
        }
    }

    func saveEventTypes(_ types: [String]) async throws {
        try await db.document(docPath).setData(["eventTypes": types])
    }
}
