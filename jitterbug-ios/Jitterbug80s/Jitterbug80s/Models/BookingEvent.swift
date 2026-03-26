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

struct BookingMessage: Identifiable, Hashable {
    let id: String
    var text: String
    var senderEmail: String
    /// "customer" or "admin"
    var senderRole: String
    var createdAt: String
}

struct CustomerNotification: Identifiable, Hashable {
    let id: String
    var bookingId: String
    var bookingRef: String
    var message: String
    var senderEmail: String
    var createdAt: String
    var isRead: Bool
}
