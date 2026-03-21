# macOS (Mac Catalyst) — `Jitterbug80sMac`

The **native macOS SDK** cannot build this app as-is because **Stripe’s iOS SDK** (Payment Sheet) is **UIKit-only**. The Mac build uses **Mac Catalyst** (iOS APIs on Mac) so **Stripe, Firebase, push, and admin tools** match the iOS app.

## Same App Store Connect app as iOS (not a new listing)

Mac Catalyst is tied to your **existing** iOS app:

| Platform | Bundle identifier (signing) |
|----------|-----------------------------|
| **iPhone / iPad** | `com.bradleyvirtualsolutions.Jitterbug80s` |
| **Mac (Catalyst)** | `maccatalyst.com.bradleyvirtualsolutions.Jitterbug80s` |

Apple uses the **`maccatalyst.`** prefix for the Mac binary. It still appears under the **same** app in [App Store Connect](https://appstoreconnect.apple.com) as your iPhone/iPad app — you are **not** creating a separate Mac-only app record.

### What to do in Apple Developer

1. Open **Certificates, Identifiers & Profiles** → **Identifiers**.
2. Select **`com.bradleyvirtualsolutions.Jitterbug80s`** (your existing App ID).
3. Enable **Mac Catalyst** (if not already) and save.

### What to do in Xcode

- **Team:** same as iOS (`Jitterbug80s` target).
- **Signing:** target **Jitterbug80sMac** uses **`Jitterbug80s/Jitterbug80s.entitlements`** (same entitlements file as iOS) so capabilities stay aligned.
- **Scheme:** **`Jitterbug80sMac`** → destination **My Mac (Mac Catalyst)** for local runs.
- **Archive for Mac:** archive **Jitterbug80sMac** (or the main **Jitterbug80s** target if you distribute iOS + Mac from one target). In Organizer, distribute; App Store Connect will attach the Mac build to your **existing** app when Catalyst is enabled on the App ID.

### Alternative: main `Jitterbug80s` target only

Target **Jitterbug80s** also has **Mac Catalyst** enabled. You can run/archive **Jitterbug80s** with destination **My Mac (Mac Catalyst)** and still ship under the same App Store app — useful if you prefer a single target.

## Firebase & push

- **`GoogleService-Info.plist`** is usually still correct for Firestore/Auth: the iOS app id in Firebase matches **`com.bradleyvirtualsolutions.Jitterbug80s`**.
- For **FCM / APNs** on Mac, add the **Mac Catalyst** variant in Firebase / Apple push setup if Console asks for the **`maccatalyst.…`** bundle id. See **`IOS-PUSH.md`**.

## Targets

| Target | Use |
|--------|-----|
| **Jitterbug80s** | iPhone, iPad, Vision; **My Mac (Mac Catalyst)** supported. |
| **Jitterbug80sMac** | iPad-style Catalyst (`TARGETED_DEVICE_FAMILY = 2`); same sources; explicit Mac scheme. |
