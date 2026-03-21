import Foundation

struct GalleryPhoto: Identifiable, Codable {
    var id: String
    var url: String
    var caption: String
    var order: Int
    var createdAt: String
}
