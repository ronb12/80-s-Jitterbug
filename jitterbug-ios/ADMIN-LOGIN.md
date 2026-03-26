# Admin login (Firebase)

## Mac app (`Jitterbug80sMac`)

- **App Sandbox** requires **Outgoing network** for Firebase Auth. The Mac target uses `Jitterbug80sMac-Debug.entitlements` / `Jitterbug80sMac-Release.entitlements` with `com.apple.security.network.client` enabled.
- Rebuild and run after entitlement changes.

## iOS / Mac — checklist

1. **Email / password sign-in** is enabled in [Firebase Console](https://console.firebase.google.com) → *Authentication* → *Sign-in method* → Email/Password.
2. The admin account exists under *Authentication* → *Users* (or create it there).
3. **`GoogleService-Info.plist`** is in the app target with a real `API_KEY` (not a placeholder).
4. If sign-in still fails, read the **red error text** on the Admin login screen — wrong password, disabled user, and network errors all show different messages.

## Optional: register a macOS app in Firebase

Your plist uses an `GOOGLE_APP_ID` ending in `:ios:`. That usually still works for a native Mac app with the **same bundle ID**. If Firebase support asks for it, add a macOS app under the same Firebase project and replace the plist if needed.
