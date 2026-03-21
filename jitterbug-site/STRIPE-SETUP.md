# Stripe checkout (deposit)

Bookings are still created in Firestore as before. When **Enable "Pay deposit"** is on in **Admin → Settings**, customers see **Pay deposit with card** after submitting the booking form. That opens **Stripe Checkout** (hosted by Stripe).

Checkout and webhooks run in **Firebase Cloud Functions** (this project uses static hosting, so there is no Next.js API route).

## 1. Stripe Dashboard

1. Create a [Stripe](https://stripe.com) account.

### Finding publishable keys (`pk_test_…` and `pk_live_…`) for Admin → Settings

These are the keys you paste into **Admin → Settings** in the iOS app (or into Firestore `settings/site` if you edit there). They are safe to store in Firestore; they are **not** your secret keys.

| What you need | Where in Stripe |
|----------------|-----------------|
| **Test publishable key** (`pk_test_…`) | [Dashboard → Developers → API keys (test)](https://dashboard.stripe.com/test/apikeys) — ensure **Test mode** is **ON** (toggle at top of the dashboard). Under **Standard keys**, copy **Publishable key**. |
| **Live publishable key** (`pk_live_…`) | Turn **Test mode** **OFF**, then open [Developers → API keys](https://dashboard.stripe.com/apikeys). Copy the **Publishable key** (starts with `pk_live_`). |

**Do not** paste **Secret key** (`sk_test_…` / `sk_live_…`) or **webhook signing secret** (`whsec_…`) into Admin Settings or Firestore—those go only into Firebase Functions secrets (section 2 below).

**Quick check:** Test keys always start with `pk_test_`; live publishable keys start with `pk_live_`. If the wrong one appears, toggle **Test mode** in Stripe and open **API keys** again.

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
