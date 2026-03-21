#if canImport(UIKit)
import UIKit
import UserNotifications
import FirebaseMessaging

/// Bridges APNs device token → FCM and forwards refreshed tokens for admin device registration.
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        _ = FirebaseManager.shared
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        Task {
            await PushNotificationService.shared.persistAdminTokenIfSignedIn(fcmToken: fcmToken)
        }
    }
}
#endif
