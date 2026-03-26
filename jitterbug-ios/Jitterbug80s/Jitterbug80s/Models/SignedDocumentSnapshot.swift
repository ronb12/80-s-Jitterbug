import Foundation

struct SignedDocumentSnapshot: Identifiable, Hashable {
    let id: String
    var type: String
    var fileName: String
    var html: String
    var signedName: String
    var createdAt: String
}
