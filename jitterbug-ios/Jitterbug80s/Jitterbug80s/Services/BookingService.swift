import Foundation
import FirebaseAuth
import FirebaseFirestore

final class BookingService {
    private let db = FirebaseManager.shared.db
    private let collectionId = "bookings"

    struct BookingSignaturesSnapshot {
        var contractSignedName: String?
        var contractSignedAt: String?
        var contractSignatureStrokes: [[String: Any]]
        var photoReleaseSignedName: String?
        var photoReleaseSignedAt: String?
        var photoReleaseSignatureStrokes: [[String: Any]]

        static let empty = BookingSignaturesSnapshot(
            contractSignedName: nil,
            contractSignedAt: nil,
            contractSignatureStrokes: [],
            photoReleaseSignedName: nil,
            photoReleaseSignedAt: nil,
            photoReleaseSignatureStrokes: []
        )
    }

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

    private static func normalizePublicSiteBase(_ raw: String) -> String {
        var base = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        while base.hasSuffix("/") { base.removeLast() }
        return base
    }

    func generateBookingRef() -> String {
        "JB-\(1000 + Int.random(in: 0..<9000))"
    }

    func submitBooking(_ form: BookingFormData) async throws -> (ref: String, id: String) {
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
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        // Primary path: website API (Neon). Mirror into Firestore so iOS admin + customer flows stay in sync.
        if let websiteResult = await submitBookingToPublicAPI(form) {
            var mirrorData = data
            mirrorData["bookingRef"] = websiteResult.ref
            do {
                try await db.collection(collectionId).document(websiteResult.id).setData(mirrorData, merge: true)
            } catch {
                // If mirroring to the same ID fails (rules/network), create a fallback Firestore record
                // so admin screens still show the newly created customer booking.
                var fallbackMirror = mirrorData
                fallbackMirror["sourceBookingId"] = websiteResult.id
                _ = try await db.collection(collectionId).addDocument(data: fallbackMirror)
            }
            try? await appendBookingEvent(
                bookingId: websiteResult.id,
                type: "booking_created",
                message: "Booking created by customer form.",
                actorEmail: form.email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            )
            return websiteResult
        }

        // Fallback: direct Firestore write (legacy/offline path).
        let ref = generateBookingRef()
        var fallbackData = data
        fallbackData["bookingRef"] = ref
        let docRef = try await db.collection(collectionId).addDocument(data: fallbackData)
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

    private func submitBookingToPublicAPI(_ form: BookingFormData) async -> (ref: String, id: String)? {
        let settings = await SettingsService().getSiteSettings()
        let base = Self.normalizePublicSiteBase(settings.stripePublicBaseUrl)
        guard let url = URL(string: "\(base)/api/bookings/submit") else { return nil }

        let payload: [String: Any] = [
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
            "photoReleaseIncludesMinors": form.photoReleaseIncludesMinors
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return nil }
            guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
            let ref = String(obj["bookingRef"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let id = String(obj["id"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !ref.isEmpty, !id.isEmpty else { return nil }
            return (ref, id)
        } catch {
            return nil
        }
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
        booking: Booking,
        signerName: String,
        signerEmail: String,
        signerUid: String,
        signatureStrokes: [[String: Any]]
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
        try await updateBooking(id: booking.id, data: update)
        try? await createSignedDocumentSnapshot(
            booking: booking,
            type: "contract",
            signedName: cleanedName,
            signatureStrokes: signatureStrokes
        )
        try? await appendBookingEvent(
            bookingId: booking.id,
            type: "contract_signed",
            message: "Customer signed contract.",
            actorEmail: signerEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
    }

    func signCustomerPhotoRelease(
        booking: Booking,
        signerName: String,
        signerEmail: String,
        signerUid: String,
        signatureStrokes: [[String: Any]]
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
        try await updateBooking(id: booking.id, data: update)
        try? await createSignedDocumentSnapshot(
            booking: booking,
            type: "photo_release",
            signedName: cleanedName,
            signatureStrokes: signatureStrokes
        )
        try? await appendBookingEvent(
            bookingId: booking.id,
            type: "photo_release_signed",
            message: "Customer signed photo release.",
            actorEmail: signerEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
    }

    func listSignedDocumentSnapshots(bookingId: String) async -> [SignedDocumentSnapshot] {
        do {
            let snap = try await db.collection(collectionId).document(bookingId).collection("documents")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            return snap.documents.compactMap { d in
                let data = d.data()
                let html = data["html"] as? String ?? ""
                guard !html.isEmpty else { return nil }
                return SignedDocumentSnapshot(
                    id: d.documentID,
                    type: data["type"] as? String ?? "document",
                    fileName: data["fileName"] as? String ?? "signed-document",
                    html: html,
                    signedName: data["signedName"] as? String ?? "",
                    createdAt: Self.isoString(from: data["createdAt"])
                )
            }
        } catch {
            return []
        }
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

    @discardableResult
    func observeBookingMessages(bookingId: String, onChange: @escaping ([BookingMessage]) -> Void) -> ListenerRegistration {
        db.collection(collectionId)
            .document(bookingId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snap, _ in
                let list = (snap?.documents ?? []).map { d in
                    let data = d.data()
                    return BookingMessage(
                        id: d.documentID,
                        text: data["text"] as? String ?? "",
                        senderEmail: data["senderEmail"] as? String ?? "",
                        senderRole: data["senderRole"] as? String ?? "customer",
                        createdAt: Self.isoString(from: data["createdAt"])
                    )
                }
                onChange(list)
            }
    }

    func sendCustomerMessage(booking: Booking, text: String, senderEmail: String) async throws {
        try await sendMessage(
            booking: booking,
            text: text,
            senderEmail: senderEmail,
            senderRole: "customer",
            targetRole: "admin"
        )
    }

    func sendAdminMessage(booking: Booking, text: String, senderEmail: String) async throws {
        try await sendMessage(
            booking: booking,
            text: text,
            senderEmail: senderEmail,
            senderRole: "admin",
            targetRole: "customer"
        )
    }

    private func sendMessage(
        booking: Booking,
        text: String,
        senderEmail: String,
        senderRole: String,
        targetRole: String
    ) async throws {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = senderEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanText.isEmpty, !cleanEmail.isEmpty else { return }
        let payload: [String: Any] = [
            "text": cleanText,
            "senderEmail": cleanEmail,
            "senderRole": senderRole,
            "createdAt": FieldValue.serverTimestamp()
        ]
        _ = try await db.collection(collectionId)
            .document(booking.id)
            .collection("messages")
            .addDocument(data: payload)

        let notification: [String: Any] = [
            "bookingId": booking.id,
            "bookingRef": booking.bookingRef,
            "targetEmail": targetRole == "customer" ? booking.email.lowercased() : "",
            "targetRole": targetRole,
            "senderEmail": cleanEmail,
            "message": cleanText,
            "isRead": false,
            "createdAt": FieldValue.serverTimestamp()
        ]
        _ = try await db.collection("notifications").addDocument(data: notification)
    }

    @discardableResult
    func observeCustomerNotifications(
        email: String,
        onChange: @escaping ([CustomerNotification]) -> Void
    ) -> ListenerRegistration {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return db.collection("notifications")
            .whereField("targetRole", isEqualTo: "customer")
            .whereField("targetEmail", isEqualTo: normalized)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, _ in
                let list = (snap?.documents ?? []).map { d in
                    let data = d.data()
                    return CustomerNotification(
                        id: d.documentID,
                        bookingId: data["bookingId"] as? String ?? "",
                        bookingRef: data["bookingRef"] as? String ?? "",
                        message: data["message"] as? String ?? "",
                        senderEmail: data["senderEmail"] as? String ?? "",
                        createdAt: Self.isoString(from: data["createdAt"]),
                        isRead: data["isRead"] as? Bool ?? false
                    )
                }
                onChange(list)
            }
    }

    func markNotificationRead(notificationId: String) async {
        guard !notificationId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        try? await db.collection("notifications").document(notificationId).updateData(["isRead": true])
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
        if let fromApi = await getBookingStatusByRefFromPublicAPI(trimmed) {
            return fromApi
        }
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

    private func getBookingStatusByRefFromPublicAPI(_ normalizedRef: String) async -> BookingStatusPublic? {
        let settings = await SettingsService().getSiteSettings()
        let base = Self.normalizePublicSiteBase(settings.stripePublicBaseUrl)
        guard let url = URL(string: "\(base)/api/bookingLookup") else { return nil }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["bookingRef": normalizedRef])

        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse else { return nil }
            if http.statusCode == 404 { return nil }
            guard (200...299).contains(http.statusCode) else { return nil }
            guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let booking = obj["booking"] as? [String: Any]
            else { return nil }

            let statusRaw = (booking["status"] as? String ?? "pending").lowercased()
            return BookingStatusPublic(
                status: BookingStatus(rawValue: statusRaw) ?? .pending,
                eventDate: booking["eventDate"] as? String ?? "",
                eventType: booking["eventType"] as? String ?? "",
                eventLocation: booking["eventLocation"] as? String ?? "",
                depositPaid: (booking["depositPaid"] as? Bool) ?? false
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

    func getBookingSignaturesSnapshot(bookingId: String) async -> BookingSignaturesSnapshot {
        do {
            let doc = try await db.collection(collectionId).document(bookingId).getDocument()
            guard let data = doc.data() else { return .empty }
            let contractStrokes = (data["customerContractSignatureStrokes"] as? [[String: Any]]) ?? []
            let photoStrokes = (data["customerPhotoReleaseSignatureStrokes"] as? [[String: Any]]) ?? []
            return BookingSignaturesSnapshot(
                contractSignedName: (data["customerContractSignedName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
                contractSignedAt: Self.isoString(from: data["customerContractSignedAt"]),
                contractSignatureStrokes: contractStrokes,
                photoReleaseSignedName: (data["customerPhotoReleaseSignedName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
                photoReleaseSignedAt: Self.isoString(from: data["customerPhotoReleaseSignedAt"]),
                photoReleaseSignatureStrokes: photoStrokes
            )
        } catch {
            return .empty
        }
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

    private func createSignedDocumentSnapshot(
        booking: Booking,
        type: String,
        signedName: String,
        signatureStrokes: [[String: Any]]
    ) async throws {
        let settings = await SettingsService().getSiteSettings()
        let signedAtIso = ISO8601DateFormatter().string(from: Date())
        let html: String
        let fileName: String
        if type == "photo_release" {
            html = PrintService.htmlForPhotoRelease(
                booking: booking,
                contactEmail: settings.contactEmail,
                contactPhone: settings.contactPhone,
                signedName: signedName,
                signedAt: signedAtIso,
                signatureStrokes: signatureStrokes
            )
            fileName = "signed-photo-release-\(booking.bookingRef)"
        } else {
            html = PrintService.htmlForContract(
                booking: booking,
                ownerName: settings.ownerName,
                contactEmail: settings.contactEmail,
                contactPhone: settings.contactPhone,
                signedName: signedName,
                signedAt: signedAtIso,
                signatureStrokes: signatureStrokes
            )
            fileName = "signed-contract-\(booking.bookingRef)"
        }
        let payload: [String: Any] = [
            "type": type,
            "fileName": fileName,
            "html": html,
            "signedName": signedName,
            "createdAt": FieldValue.serverTimestamp()
        ]
        _ = try await db.collection(collectionId).document(booking.id).collection("documents").addDocument(data: payload)
    }
}
