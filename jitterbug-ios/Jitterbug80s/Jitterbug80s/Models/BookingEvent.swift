import Foundation

struct BookingEvent: Identifiable, Hashable {
    let id: String
    var type: String
    var message: String
    var actorEmail: String
    var createdAt: String
}

struct BookingChangeRequest: Identifiable, Hashable {
    let id: String
    var requestText: String
    var status: String
    var requesterEmail: String
    var createdAt: String
}
