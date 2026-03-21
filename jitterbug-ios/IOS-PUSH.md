# iOS push notifications (FCM)

The app uses **Firebase Cloud Messaging** for:

| Audience | When |
|----------|------|
| **Admin** | New booking created; deposit marked paid (`depositPaid`) |
| **Customer** (opt-in on Book form) | Deposit marked paid |

## Firebase / Apple setup

1. **Firebase Console → Project settings → Cloud Messaging**
   - Upload your **APNs Authentication Key** (.p8) or certificates for your Apple Team + bundle id **`com.bradleyvirtualsolutions.Jitterbug80s`** (iPhone/iPad).
   - If you ship **Mac Catalyst** (`Jitterbug80sMac`), Apple’s Mac binary id is **`maccatalyst.com.bradleyvirtualsolutions.Jitterbug80s`** — it’s the **same App Store app** as iOS. If Firebase asks you to register an Apple app for Mac push, add that **maccatalyst…** id under the same Firebase iOS app (or follow the Console’s “add app” flow for the Catalyst bundle).

2. **Xcode → Signing & Capabilities**
   - Add **Push Notifications** (updates entitlements; for App Store builds use **production** `aps-environment` — Xcode often sets this when archiving).

3. **Deploy backend**

   **Option A — Vercel (Next.js APIs)**  
   - Deploy `jitterbug-site` per **`jitterbug-site/VERCEL.md`**.  
   - Endpoints: `/api/registerBookingPushToken`, `/api/stripeWebhook`, etc.  
   - **New booking** admin push: Firestore `onDocumentCreated` is **not** on Vercel. After iOS creates a booking, the app calls **`POST {base}/api/push/notify-new-booking`** with header **`x-internal-notify-secret`** when you set the same secret in Vercel (`INTERNAL_NEW_BOOKING_NOTIFY_SECRET`) and in Xcode → Target → **Info** → key **`InternalNewBookingNotifySecret`** (string). If the plist key is empty, the app skips the call (no duplicate if you still use Cloud Function triggers — avoid running both).  
   - **Deposit paid** push: sent from the **Stripe webhook** handler on Vercel after `depositPaid` is written (replaces `onBookingUpdatedPush` for that path).

   **Option B — Firebase only**  
   - `firebase deploy --only functions,firestore:rules,hosting` from `jitterbug-site/` so these are live:
     - `onBookingCreatedPush`, `onBookingUpdatedPush`, `registerBookingPushToken`
     - Hosting rewrite: `/api/registerBookingPushToken`
     - Firestore rules for `adminFCM` and locked `bookings/.../notifyTokens`

4. **Site URL**
   - `settings/site` → `stripePublicBaseUrl` must match the deployed site (APIs: `{base}/api/registerBookingPushToken`, `{base}/api/push/notify-new-booking`, Stripe routes, etc.).

## Data model (Firestore)

- `adminFCM/{uid}` — `{ fcmToken, updatedAt }` — written only by the signed-in admin app.
- `bookings/{id}/notifyTokens/{hash}` — `{ token, createdAt }` — written only by the **`registerBookingPushToken`** HTTPS function (verifies `bookingRef`).

## Simulator

Push delivery is unreliable on Simulator; test on a **physical device** when possible.
