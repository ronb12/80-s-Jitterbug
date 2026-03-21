# Stripe checkout (deposit)

Bookings are still created in Firestore as before. When **Enable "Pay deposit"** is on in **Admin → Settings**, customers see **Pay deposit with card** after submitting the booking form. That opens **Stripe Checkout** (hosted by Stripe).

Checkout and webhooks run in **Firebase Cloud Functions** (this project uses static hosting, so there is no Next.js API route).

## 1. Stripe Dashboard

1. Create a [Stripe](https://stripe.com) account.
2. **Developers → API keys**: copy **Publishable** test/live keys (`pk_test_…`, `pk_live_…`) into **Admin → Settings** (optional reference; Checkout uses the secret key on the server).
3. **Developers → Webhooks → Add endpoint**  
   - URL: `https://YOUR_PROJECT.web.app/api/stripeWebhook`  
     (or your custom domain + `/api/stripeWebhook`)  
   - Events: `checkout.session.completed`  
   - Copy the **Signing secret** (`whsec_…`) — this is `STRIPE_WEBHOOK_SECRET`, not a Firestore field.

## 2. Firebase secrets (secret keys only here)

From `jitterbug-site/`:

```bash
cd functions
npm install
npm run build
cd ..
firebase functions:secrets:set STRIPE_SECRET_KEY
# paste sk_test_... or sk_live_... (use test while developing)

firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
# paste whsec_... from the webhook endpoint
```

Redeploy functions after changing secrets:

```bash
firebase deploy --only functions
```

## 3. Hosting rewrites

`firebase.json` already maps:

- `/api/stripeCheckout` → `stripeCheckout` function  
- `/api/stripeWebhook` → `stripeWebhook` function  

Deploy hosting **and** functions:

```bash
npm run build
firebase deploy --only hosting,functions
```

## 4. Firestore admin settings

In **Admin → Settings** (web or iOS):

- Turn on **Enable "Pay deposit"** after secrets are set and functions are deployed.
- Set **Public site URL** to your real URL (e.g. `https://jitterbug80s.web.app`).
- **Deposit amount** is in **USD cents** (default 5000 = $50). It will not exceed the selected package price when the price can be parsed from `settings/packages`.

## Security

- **Never** put `sk_` or `whsec_` values in Firestore. `settings/site` is readable by anyone with your Firebase config.
- Firestore rules block clients from setting `depositPaid` / `stripeCheckoutSessionId` on create; only Functions (Admin SDK) and authenticated admin updates apply those fields.

## iOS app

The app uses the same `POST …/api/stripeCheckout` endpoint as the website:

- After a customer submits **Book Your Booth**, **Booking success** shows **Pay deposit with card** when **Enable "Pay deposit"** is on in **Admin → Settings** (synced from Firestore).
- In **Admin → Bookings →** a booking, **Customer: pay deposit (Stripe)** opens Safari to Checkout for that Firestore `bookingId`.

Ensure **Public site URL** in settings matches the Firebase Hosting domain where functions are deployed (e.g. `https://jitterbug80s.web.app`).

## Going live

- Replace test `STRIPE_SECRET_KEY` with `sk_live_…` (new secret version / redeploy).
- Add a **live** webhook endpoint pointing to the same `/api/stripeWebhook` path on your production domain.
- Use **live** publishable key in admin if you add client-side Stripe later.
