import Foundation
import FirebaseFirestore

final class PackagesService {
    private let db = FirebaseManager.shared.db
    private let docPath = "settings/packages"

    static let defaultPackages: [PackagePrice] = [
        .init(id: "basic", name: "Basic", price: "$299", features: []),
        .init(id: "standard", name: "Standard", price: "$449", features: []),
        .init(id: "vip", name: "VIP", price: "$649", features: [])
    ]

    func getPackages() async -> [PackagePrice] {
        do {
            let snap = try await db.document(docPath).getDocument()
            guard snap.exists, let data = snap.data(),
                  let list = data["packages"] as? [[String: Any]] else {
                return Self.defaultPackages
            }
            return list.compactMap { p in
                let id = (p["id"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !id.isEmpty else { return nil }
                let features = (p["features"] as? [String])?.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
                return PackagePrice(
                    id: id,
                    name: (p["name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Package",
                    price: (p["price"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                    features: features
                )
            }
        } catch {
            return Self.defaultPackages
        }
    }

    func savePackages(_ packages: [PackagePrice]) async throws {
        let data: [[String: Any]] = packages.map { ["id": $0.id, "name": $0.name, "price": $0.price, "features": $0.features] }
        try await db.document(docPath).setData(["packages": data])
    }
}
