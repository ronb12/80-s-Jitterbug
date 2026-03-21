# Test Stripe checkout from the iOS app

The app starts checkout the same way as the website: **`POST https://<your-site>/api/stripeCheckout`** with JSON `{"bookingId":"<Firestore doc id>"}`, then opens the returned Stripe URL in Safari.

## Before you test

1. **Deploy** Firebase Hosting + Functions (`jitterbug-site/deploy.sh` or `firebase deploy --only hosting,functions`).
2. **Secrets** (one-time):
   ```bash
   firebase functions:secrets:set STRIPE_SECRET_KEY    # sk_test_… while testing
   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
   ```
3. **Stripe Dashboard → Webhooks**: endpoint `https://YOUR_SITE/api/stripeWebhook`, event `checkout.session.completed`.
4. **Firestore → `settings/site`**: set **`stripeCheckoutEnabled`** = `true` and **`stripePublicBaseUrl`** = your live URL (e.g. `https://jitterbug80s.web.app`, no trailing slash).

See **`jitterbug-site/STRIPE-SETUP.md`** for full detail.

## In the iOS app (Simulator or device)

1. Build and run **Jitterbug80s** in Xcode.
2. Go to **Book** tab → fill the form → **Submit request**.
3. On the success screen, if checkout is enabled you should see **Pay deposit with card**.
4. Tap it → **Safari** opens Stripe Checkout.
5. Use Stripe test card: **`4242 4242 4242 4242`**, any future expiry, any CVC, any ZIP.
6. After paying, you should land on **`/booking/success/`** on the site; Firestore booking should get **`depositPaid: true`** (via webhook).

### Admin path (optional)

**Admin → Bookings →** open a booking → **Customer: pay deposit (Stripe)** (when deposit not paid and checkout enabled).

## If the button doesn’t appear

- `stripeCheckoutEnabled` is false in Firestore, or settings failed to load (offline / Firebase config).
- App reads the same `settings/site` document as the website.

## If checkout fails with an error message

| Message | What to check |
|--------|----------------|
| Stripe checkout is disabled | `stripeCheckoutEnabled` in `settings/site` |
| Booking not found | Wrong `bookingId` or booking deleted |
| Deposit already recorded | Already paid; webhook or admin set `depositPaid` |
| Checkout failed (403/500) | Functions not deployed, missing `STRIPE_SECRET_KEY`, or Stripe API error |

## Test the API without Xcode (same as the app)

From **`jitterbug-site`**:

```bash
chmod +x scripts/test-stripe-checkout.sh
# Create a booking from the site or app, then copy its Firestore document ID:
export BOOKING_ID="paste_document_id_here"
./scripts/test-stripe-checkout.sh
```

If you get HTTP **200** and a JSON `url`, paste that URL into Safari to finish the payment.

## Workspace note (Cursor / disk)

If **`BookView.swift`** / **`BookingSuccessView.swift`** are missing from `jitterbug-ios`, the app won’t build—restore those files from Time Machine or another copy of the project, then wire success screen to pass **`bookingId`** into **`BookingSuccessView`** and call **`StripeCheckoutService`**. The service implementation lives in **`StripeCheckoutService.swift`**.
