import Foundation
import FirebaseAuth
import FirebaseFirestore

final class BookingService {
    private let db = FirebaseManager.shared.db
    private let collectionId = "bookings"

    private static func isoString(from value: Any?) -> String {
        if let t = value as? Timestamp { return ISO8601DateFormatter().string(from: t.dateValue()) }
        if let s = value as? String { return s }
        return ""
    }

    private static func parseBooking(id: String, data d: [String: Any]) -> Booking {
        return Booking(
            id: id,
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
            balancePaid: d["balancePaid"] as? Bool,
            customerContractSignedAt: Self.isoString(from: d["customerContractSignedAt"]),
            customerContractSignedName: (d["customerContractSignedName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
            customerPhotoReleaseSignedAt: Self.isoString(from: d["customerPhotoReleaseSignedAt"]),
            customerPhotoReleaseSignedName: (d["customerPhotoReleaseSignedName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    func generateBookingRef() -> String {
        "JB-\(1000 + Int.random(in: 0..<9000))"
    }

    func submitBooking(_ form: BookingFormData) async throws -> (ref: String, id: String) {
        let ref = generateBookingRef()
        let data: [String: Any] = [
            "name": form.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": form.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
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
        try? await appendBookingEvent(
            bookingId: docRef.documentID,
            type: "booking_created",
            message: "Booking created by customer form.",
            actorEmail: form.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
        await Self.notifyNewBookingPushIfConfigured(
            bookingId: docRef.documentID,
            bookingRef: ref,
            name: form.name
        )
        return (ref, docRef.documentID)
    }

    /// When APIs run on Vercel (no Firestore `onBookingCreatedPush`), ping the secured notify endpoint if configured.
    private static func notifyNewBookingPushIfConfigured(bookingId: String, bookingRef: String, name: String) async {
        guard let secret = Bundle.main.object(forInfoDictionaryKey: "InternalNewBookingNotifySecret") as? String,
              !secret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        let settings = await SettingsService().getSiteSettings()
        let base = settings.stripePublicBaseUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "\(base)/api/push/notify-new-booking") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(secret, forHTTPHeaderField: "x-internal-notify-secret")
        let payload: [String: Any] = [
            "bookingId": bookingId,
            "bookingRef": bookingRef,
            "name": name
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (_, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return }
        } catch {
            // Non-fatal: booking is already in Firestore
        }
    }

    func listBookings() async throws -> [Booking] {
        let snap = try await db.collection(collectionId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snap.documents.map { Self.parseBooking(id: $0.documentID, data: $0.data()) }
    }

    @discardableResult
    func observeBookingsForCustomer(email: String, onChange: @escaping ([Booking]) -> Void) -> ListenerRegistration {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return db.collection(collectionId)
            .whereField("email", isEqualTo: normalized)
            .addSnapshotListener { snap, _ in
                let list = (snap?.documents ?? [])
                    .map { Self.parseBooking(id: $0.documentID, data: $0.data()) }
                    .sorted { $0.eventDate > $1.eventDate }
                onChange(list)
            }
    }

    @discardableResult
    func observeBooking(id: String, onChange: @escaping (Booking?) -> Void) -> ListenerRegistration {
        db.collection(collectionId).document(id).addSnapshotListener { snap, _ in
            guard let snap, snap.exists, let data = snap.data() else {
                onChange(nil)
                return
            }
            onChange(Self.parseBooking(id: snap.documentID, data: data))
        }
    }

    func signCustomerContract(
        bookingId: String,
        signerName: String,
        signerEmail: String,
        signerUid: String,
        signatureStrokes: [[[Double]]]
    ) async throws {
        let cleanedName = signerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return }
        var update: [String: Any] = [
            "customerContractSignedAt": FieldValue.serverTimestamp(),
            "customerContractSignedName": cleanedName,
            "customerContractSignedByEmail": signerEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "customerContractSignedByUid": signerUid
        ]
        if !signatureStrokes.isEmpty {
            update["customerContractSignatureStrokes"] = signatureStrokes
        }
        try await updateBooking(id: bookingId, data: update)
        try? await appendBookingEvent(
            bookingId: bookingId,
            type: "contract_signed",
            message: "Customer signed contract.",
            actorEmail: signerEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
    }

    func signCustomerPhotoRelease(
        bookingId: String,
        signerName: String,
        signerEmail: String,
        signerUid: String,
        signatureStrokes: [[[Double]]]
    ) async throws {
        let cleanedName = signerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return }
        var update: [String: Any] = [
            "customerPhotoReleaseSignedAt": FieldValue.serverTimestamp(),
            "customerPhotoReleaseSignedName": cleanedName,
            "customerPhotoReleaseSignedByEmail": signerEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "customerPhotoReleaseSignedByUid": signerUid
        ]
        if !signatureStrokes.isEmpty {
            update["customerPhotoReleaseSignatureStrokes"] = signatureStrokes
        }
        try await updateBooking(id: bookingId, data: update)
        try? await appendBookingEvent(
            bookingId: bookingId,
            type: "photo_release_signed",
            message: "Customer signed photo release.",
            actorEmail: signerEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
    }

    func addCustomerChangeRequest(bookingId: String, requestText: String, requesterEmail: String) async throws {
        let text = requestText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let data: [String: Any] = [
            "requestText": text,
            "status": "pending",
            "requesterEmail": requesterEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "createdAt": FieldValue.serverTimestamp()
        ]
        _ = try await db.collection(collectionId).document(bookingId).collection("changeRequests").addDocument(data: data)
        try? await appendBookingEvent(
            bookingId: bookingId,
            type: "change_request_submitted",
            message: "Customer submitted a change request.",
            actorEmail: requesterEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
    }

    func listBookingEvents(bookingId: String) async -> [BookingEvent] {
        do {
            let snap = try await db.collection(collectionId).document(bookingId).collection("events")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            return snap.documents.map { d in
                let data = d.data()
                return BookingEvent(
                    id: d.documentID,
                    type: data["type"] as? String ?? "",
                    message: data["message"] as? String ?? "",
                    actorEmail: data["actorEmail"] as? String ?? "",
                    createdAt: Self.isoString(from: data["createdAt"])
                )
            }
        } catch {
            return []
        }
    }

    func listChangeRequests(bookingId: String) async -> [BookingChangeRequest] {
        do {
            let snap = try await db.collection(collectionId).document(bookingId).collection("changeRequests")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            return snap.documents.map { d in
                let data = d.data()
                return BookingChangeRequest(
                    id: d.documentID,
                    requestText: data["requestText"] as? String ?? "",
                    status: data["status"] as? String ?? "pending",
                    requesterEmail: data["requesterEmail"] as? String ?? "",
                    createdAt: Self.isoString(from: data["createdAt"])
                )
            }
        } catch {
            return []
        }
    }

    func resolveChangeRequest(bookingId: String, requestId: String, status: String) async throws {
        guard status == "approved" || status == "rejected" else { return }
        try await db.collection(collectionId)
            .document(bookingId)
            .collection("changeRequests")
            .document(requestId)
            .updateData([
                "status": status,
                "updatedAt": FieldValue.serverTimestamp()
            ])
        let adminEmail = FirebaseManager.shared.auth.currentUser?.email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? "admin"
        try? await appendBookingEvent(
            bookingId: bookingId,
            type: "change_request_\(status)",
            message: "Admin marked a change request as \(status).",
            actorEmail: adminEmail
        )
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

    private func appendBookingEvent(bookingId: String, type: String, message: String, actorEmail: String) async throws {
        let payload: [String: Any] = [
            "type": type,
            "message": message,
            "actorEmail": actorEmail,
            "createdAt": FieldValue.serverTimestamp()
        ]
        _ = try await db.collection(collectionId).document(bookingId).collection("events").addDocument(data: payload)
    }
}
