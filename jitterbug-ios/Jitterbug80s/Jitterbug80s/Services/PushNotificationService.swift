import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

#if canImport(UIKit)
import UIKit
#endif

/// Registers FCM tokens: **admin** → `adminFCM/{uid}`; **customer** (opt-in) → HTTPS `registerBookingPushToken`.
final class PushNotificationService {
    static let shared = PushNotificationService()

    private init() {}

    /// After admin signs in: request notification permission, register for remote notifications, persist FCM token.
    func registerAdminDeviceIfPossible() async {
        guard FirebaseManager.isConfigured else { return }
        guard FirebaseManager.shared.auth.currentUser != nil else { return }

        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings().authorizationStatus
        if status == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        } else if status != .authorized, status != .provisional {
            return
        }

        #if canImport(UIKit)
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
        #endif

        // Token often arrives via MessagingDelegate; also try immediately after APNs registration.
        for _ in 0 ..< 24 {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if let token = try? await Messaging.messaging().token(), token.count > 20 {
                await persistAdminTokenIfSignedIn(fcmToken: token)
                return
            }
        }
    }

    /// Called from `AppDelegate` when FCM rotates the token.
    func persistAdminTokenIfSignedIn(fcmToken: String) async {
        guard FirebaseManager.isConfigured else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard fcmToken.count > 20 else { return }
        do {
            try await FirebaseManager.shared.db.collection("adminFCM").document(uid).setData(
                [
                    "fcmToken": fcmToken,
                    "updatedAt": FieldValue.serverTimestamp(),
                ],
                merge: true
            )
        } catch {
            // Non-fatal: rules or network; admin can re-open app after login.
        }
    }

    /// Customer opt-in after booking: notify when deposit is paid (verified by `bookingRef` on the server).
    func registerCustomerForDepositNotifications(
        bookingId: String,
        bookingRef: String,
        publicSiteBaseURL: String
    ) async {
        guard FirebaseManager.isConfigured else { return }
        let center = UNUserNotificationCenter.current()
        let status = await center.notificationSettings().authorizationStatus
        let ok: Bool
        if status == .notDetermined {
            ok = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        } else {
            ok = status == .authorized || status == .provisional
        }
        guard ok else { return }

        #if canImport(UIKit)
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
        #endif

        var fcm: String?
        for _ in 0 ..< 24 {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if let t = try? await Messaging.messaging().token(), t.count > 20 {
                fcm = t
                break
            }
        }
        guard let token = fcm else { return }

        var base = publicSiteBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        while base.hasSuffix("/") { base.removeLast() }
        guard let url = URL(string: "\(base)/api/registerBookingPushToken") else { return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "bookingId": bookingId,
            "bookingRef": bookingRef,
            "fcmToken": token,
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else { return }
        } catch {
            return
        }
    }
}
