# Test Stripe deposit from the iOS app (Payment Sheet)

The app uses **Stripe Payment Sheet** in-app: it calls **`POST https://<your-site>/api/stripePaymentIntent`** with JSON `{"bookingId":"<Firestore doc id>"}`, receives `clientSecret`, then Stripe’s SDK collects the card (or Apple Pay). **Stripe** charges the card; a **webhook** updates Firestore.

The **website** still uses hosted Checkout via **`/api/stripeCheckout`** (Safari/browser).

## Before you test

1. **Deploy** Firebase Hosting + Functions (`jitterbug-site/deploy.sh` or `firebase deploy --only hosting,functions`) so **`stripePaymentIntent`** is live.
2. **Secrets** (one-time):
   ```bash
   firebase functions:secrets:set STRIPE_SECRET_KEY    # sk_test_… while testing
   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
   ```
3. **Stripe Dashboard → Webhooks**: endpoint `https://YOUR_SITE/api/stripeWebhook` with events:
   - `payment_intent.succeeded` **(required for iOS)**
   - `checkout.session.completed` (for website Checkout)
4. **Firestore → `settings/site`** (or **Admin → Settings** in the app):
   - **`stripeCheckoutEnabled`** = `true`
   - **`stripePublicBaseUrl`** = your site URL (e.g. `https://jitterbug80s.web.app`, no trailing slash)
   - **`stripePublishableKeyTest`** or **`stripePublishableKeyLive`** + **`stripeMode`** matching your secret key (test vs live)

See **`jitterbug-site/STRIPE-SETUP.md`** and **`IOS-STRIPE-NATIVE.md`**.

## Swift Package Manager

The app links **`Stripe`** and **`StripePaymentSheet`** from `https://github.com/stripe/stripe-ios`. Resolve packages in Xcode if needed (**File → Packages → Resolve Package Versions**).

## In the iOS app (Simulator or device)

1. Build and run **Jitterbug80s** in Xcode.
2. **Book** tab → fill the form → **Submit request**.
3. On the success screen, tap **Pay deposit with card** (if enabled).
4. Complete **Payment Sheet** in the app (test card **`4242 4242 4242 4242`**, future expiry, any CVC).
5. After success, Stripe sends **`payment_intent.succeeded`** → webhook should set **`depositPaid: true`** on the booking (may take a few seconds).

### Admin path

**Admin → Bookings →** open a booking → **Customer: pay deposit (Stripe)** (same Payment Sheet).

## If the button doesn’t appear

- `stripeCheckoutEnabled` is false, or settings failed to load.
- **Publishable key** empty for the current mode (`stripeMode` vs `pk_test_` / `pk_live_`).

## If payment fails

| Message | What to check |
|--------|----------------|
| Stripe checkout is disabled | `stripeCheckoutEnabled` in `settings/site` |
| Add your Stripe publishable key | Fill **pk_test_** / **pk_live_** in Admin → Settings |
| Booking not found | Wrong `bookingId` |
| Deposit already recorded | `depositPaid` already true |
| HTTP 403/500 | Deploy `stripePaymentIntent`, secrets, Stripe API errors |
| Paid but Firestore not updated | Webhook missing **`payment_intent.succeeded`** or wrong signing secret |

## Test the PaymentIntent API (curl)

From **`jitterbug-site`**:

```bash
chmod +x scripts/test-stripe-payment-intent.sh
export BOOKING_ID="paste_firestore_booking_document_id_here"
./scripts/test-stripe-payment-intent.sh
```

You should see HTTP **200** and a JSON **`clientSecret`** (starts with `pi_…_secret_…`).

Hosted Checkout for the web is still tested with **`scripts/test-stripe-checkout.sh`**.
