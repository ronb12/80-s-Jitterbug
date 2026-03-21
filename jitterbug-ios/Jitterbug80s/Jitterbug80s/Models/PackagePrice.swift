import Foundation

struct PackagePrice: Identifiable, Codable {
    var id: String
    var name: String
    var price: String
    /// What's included in this package (e.g. "3 hours of booth time"). Editable in Admin. Empty = use app defaults by name.
    var features: [String]

    init(id: String, name: String, price: String, features: [String] = []) {
        self.id = id
        self.name = name
        self.price = price
        self.features = features
    }

    enum CodingKeys: String, CodingKey {
        case id, name, price, features
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        price = try c.decode(String.self, forKey: .price)
        features = (try? c.decode([String].self, forKey: .features)) ?? []
    }
}
