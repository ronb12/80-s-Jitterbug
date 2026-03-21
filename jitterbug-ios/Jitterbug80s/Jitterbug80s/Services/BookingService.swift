import Foundation
import FirebaseFirestore

final class BookingService {
    private let db = FirebaseManager.shared.db
    private let collectionId = "bookings"

    private static func isoString(from value: Any?) -> String {
        if let t = value as? Timestamp { return ISO8601DateFormatter().string(from: t.dateValue()) }
        if let s = value as? String { return s }
        return ""
    }

    func generateBookingRef() -> String {
        "JB-\(1000 + Int.random(in: 0..<9000))"
    }

    func submitBooking(_ form: BookingFormData) async throws -> (ref: String, id: String) {
        let ref = generateBookingRef()
        let data: [String: Any] = [
            "name": form.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": form.email.trimmingCharacters(in: .whitespacesAndNewlines),
            "phone": form.phone.trimmingCharacters(in: .whitespacesAndNewlines),
            "eventType": form.eventType,
            "eventDate": form.eventDate,
            "eventLocation": form.eventLocation.trimmingCharacters(in: .whitespacesAndNewlines),
            "eventAddress": form.eventAddress.trimmingCharacters(in: .whitespacesAndNewlines),
            "package": form.package,
            "message": form.message.trimmingCharacters(in: .whitespacesAndNewlines),
            "photoReleaseConsent": form.photoReleaseConsent,
            "photoReleaseIncludesMinors": form.photoReleaseIncludesMinors,
            "status": BookingStatus.pending.rawValue,
            "bookingRef": ref,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        let docRef = try await db.collection(collectionId).addDocument(data: data)
        return (ref, docRef.documentID)
    }

    func listBookings() async throws -> [Booking] {
        let snap = try await db.collection(collectionId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap.documents.map { doc in
            let d = doc.data()
            return Booking(
                id: doc.documentID,
                name: d["name"] as? String ?? "",
                email: d["email"] as? String ?? "",
                phone: d["phone"] as? String ?? "",
                eventType: d["eventType"] as? String ?? "",
                eventDate: d["eventDate"] as? String ?? "",
                eventLocation: d["eventLocation"] as? String ?? "",
                eventAddress: d["eventAddress"] as? String ?? "",
                package: d["package"] as? String ?? "",
                message: d["message"] as? String ?? "",
                photoReleaseConsent: (d["photoReleaseConsent"] as? Bool) ?? false,
                photoReleaseIncludesMinors: (d["photoReleaseIncludesMinors"] as? Bool) ?? false,
                status: BookingStatus(rawValue: d["status"] as? String ?? "pending") ?? .pending,
                bookingRef: d["bookingRef"] as? String ?? "",
                createdAt: Self.isoString(from: d["createdAt"]),
                updatedAt: Self.isoString(from: d["updatedAt"]),
                depositPaid: d["depositPaid"] as? Bool,
                balancePaid: d["balancePaid"] as? Bool
            )
        }
    }

    func getBookingStatusByRef(_ ref: String) async -> BookingStatusPublic? {
        let trimmed = ref.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return nil }
        do {
            let snap = try await db.collection(collectionId)
                .whereField("bookingRef", isEqualTo: trimmed)
                .limit(to: 1)
                .getDocuments()
            guard let doc = snap.documents.first else { return nil }
            let d = doc.data()
            let statusRaw = d["status"] as? String ?? "pending"
            return BookingStatusPublic(
                status: BookingStatus(rawValue: statusRaw) ?? .pending,
                eventDate: d["eventDate"] as? String ?? "",
                eventType: d["eventType"] as? String ?? "",
                eventLocation: d["eventLocation"] as? String ?? "",
                depositPaid: (d["depositPaid"] as? Bool) ?? false
            )
        } catch {
            return nil
        }
    }

    func updateBooking(id: String, data: [String: Any]) async throws {
        var update = data
        update["updatedAt"] = FieldValue.serverTimestamp()
        try await db.collection(collectionId).document(id).updateData(update)
    }

    func deleteBooking(id: String) async throws {
        try await db.collection(collectionId).document(id).delete()
    }
}
