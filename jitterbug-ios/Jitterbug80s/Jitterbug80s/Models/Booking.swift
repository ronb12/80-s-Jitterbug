import Foundation

enum BookingStatus: String, CaseIterable, Codable, Identifiable {
    case pending
    case confirmed
    case completed
    case declined
    case cancelled

    var id: String { rawValue }
}

struct BookingFormData {
    var name = ""
    var email = ""
    var phone = ""
    var eventType = ""
    var eventDate = ""
    var eventLocation = ""
    var eventAddress = ""
    var package = ""
    var message = ""
    var photoReleaseConsent = false
    var photoReleaseIncludesMinors = false
}

/// Public-safe payload for booking lookup by reference.
struct BookingStatusPublic: Hashable {
    var status: BookingStatus
    var eventDate: String
    var eventType: String
    var eventLocation: String
    /// Whether a Stripe deposit has been recorded (via webhook or admin).
    var depositPaid: Bool
}

struct Booking: Identifiable, Hashable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var eventType: String
    var eventDate: String
    var eventLocation: String
    var eventAddress: String
    var package: String
    var message: String
    var photoReleaseConsent: Bool
    var photoReleaseIncludesMinors: Bool
    var status: BookingStatus
    var bookingRef: String
    var createdAt: String
    var updatedAt: String
    var depositPaid: Bool?
    var balancePaid: Bool?
}
