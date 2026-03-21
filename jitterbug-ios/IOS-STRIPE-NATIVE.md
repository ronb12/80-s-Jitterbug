# iOS Stripe Payment Sheet vs “Firebase processing”

**Stripe** always captures card payments—not Firebase. Firebase Cloud Functions in this repo only:

1. Create a **PaymentIntent** (`stripePaymentIntent`) and return `clientSecret` to the app (secret key stays on the server).
2. Run the **webhook** to mark `depositPaid` in Firestore when Stripe confirms payment.

So: **money movement = Stripe**. **Booking updates** can still use Firebase (webhook → Firestore).

## If you want zero Firebase in the payment path

You still need **some HTTPS server** to create PaymentIntents (never put `sk_…` in the app). Options:

- Deploy the same logic (`POST` body `{ "bookingId": "…" }`, response `{ "clientSecret": "…" }`) on **Vercel, Cloud Run, your own API**, etc.
- Change the iOS code to call your base URL instead of `{publicSiteURL}/api/stripePaymentIntent` (today that path is a Firebase Hosting rewrite).

The webhook can also move to **Stripe → your server** that updates Firestore with the Admin SDK, or updates any database you use.

## Default (this repo)

- iOS: `POST https://<your-site>/api/stripePaymentIntent` → Payment Sheet.
- Web: `POST …/api/stripeCheckout` → hosted Checkout URL (unchanged).
- Webhook: `payment_intent.succeeded` **and** `checkout.session.completed` on the same endpoint.
