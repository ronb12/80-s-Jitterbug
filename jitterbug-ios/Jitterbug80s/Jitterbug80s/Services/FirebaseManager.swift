import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

final class FirebaseManager {
    static let shared = FirebaseManager()

    /// True only after a valid GoogleService-Info.plist was used to configure Firebase.
    static var isConfigured: Bool { _isConfigured }
    private static var _isConfigured = false

    var auth: Auth { Auth.auth() }
    var db: Firestore { Firestore.firestore() }

    private init() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiKey = plist["API_KEY"] as? String,
              !apiKey.contains("REPLACE") else {
            return
        }
        FirebaseApp.configure()
        Self._isConfigured = true
    }
}
