# iOS push notifications (FCM)

The app uses **Firebase Cloud Messaging** for:

| Audience | When |
|----------|------|
| **Admin** | New booking created; deposit marked paid (`depositPaid`) |
| **Customer** (opt-in on Book form) | Deposit marked paid |

## Firebase / Apple setup

1. **Firebase Console → Project settings → Cloud Messaging**
   - Upload your **APNs Authentication Key** (.p8) or certificates for your Apple Team + bundle id (`com.bradleyvirtualsolutions.Jitterbug80s`).

2. **Xcode → Signing & Capabilities**
   - Add **Push Notifications** (updates entitlements; for App Store builds use **production** `aps-environment` — Xcode often sets this when archiving).

3. **Deploy backend**
   - `firebase deploy --only functions,firestore:rules,hosting` from `jitterbug-site/` so these are live:
     - `onBookingCreatedPush`, `onBookingUpdatedPush`, `registerBookingPushToken`
     - Hosting rewrite: `/api/registerBookingPushToken`
     - Firestore rules for `adminFCM` and locked `bookings/.../notifyTokens`

4. **Site URL**
   - `settings/site` → `stripePublicBaseUrl` must match the deployed site (customer registration calls `{base}/api/registerBookingPushToken`).

## Data model (Firestore)

- `adminFCM/{uid}` — `{ fcmToken, updatedAt }` — written only by the signed-in admin app.
- `bookings/{id}/notifyTokens/{hash}` — `{ token, createdAt }` — written only by the **`registerBookingPushToken`** HTTPS function (verifies `bookingRef`).

## Simulator

Push delivery is unreliable on Simulator; test on a **physical device** when possible.
