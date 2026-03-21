# Stripe checkout (deposit)

Bookings are still created in Firestore as before. When **Enable "Pay deposit"** is on in **Admin → Settings**:

- **Website:** **Pay deposit with card** opens **Stripe Checkout** in the browser (hosted by Stripe).
- **iOS app:** **Pay deposit with card** opens **Stripe Payment Sheet** inside the app. The card is still charged by **Stripe**; the app never sees your secret key.

**Vercel (recommended):** Stripe and webhooks run as **Next.js Route Handlers** in this repo (`/api/stripeCheckout`, `/api/stripePaymentIntent`, `/api/stripeWebhook`). Configure env vars on Vercel — see **`VERCEL.md`**.

**Firebase Cloud Functions (legacy):** Same paths can be served via Hosting rewrites to Functions; secrets are set with `firebase functions:secrets:set`. See sections 2–3 below.

## 1. Stripe Dashboard

1. Create a [Stripe](https://stripe.com) account.

### Finding publishable keys (`pk_test_…` and `pk_live_…`) for Admin → Settings

These are the keys you paste into **Admin → Settings** in the iOS app (or into Firestore `settings/site` if you edit there). They are safe to store in Firestore; they are **not** your secret keys.

| What you need | Where in Stripe |
|----------------|-----------------|
| **Test publishable key** (`pk_test_…`) | [Dashboard → Developers → API keys (test)](https://dashboard.stripe.com/test/apikeys) — ensure **Test mode** is **ON** (toggle at top of the dashboard). Under **Standard keys**, copy **Publishable key**. |
| **Live publishable key** (`pk_live_…`) | Turn **Test mode** **OFF**, then open [Developers → API keys](https://dashboard.stripe.com/apikeys). Copy the **Publishable key** (starts with `pk_live_`). |

**Do not** paste **Secret key** (`sk_test_…` / `sk_live_…`) or **webhook signing secret** (`whsec_…`) into Admin Settings or Firestore—those go only into **Vercel env** (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`) or Firebase Functions secrets (section 2 below).

**Quick check:** Test keys always start with `pk_test_`; live publishable keys start with `pk_live_`. If the wrong one appears, toggle **Test mode** in Stripe and open **API keys** again.

3. **Developers → Webhooks → Add endpoint**  
   - URL: **`https://<your-vercel-domain>/api/stripeWebhook`** (Vercel)  
     or `https://YOUR_PROJECT.web.app/api/stripeWebhook` (Firebase Hosting + Functions)  
   - Events: enable **both**  
     - `checkout.session.completed` (website hosted Checkout)  
     - `payment_intent.succeeded` (iOS Payment Sheet)  
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

- `/api/stripeCheckout` → `stripeCheckout` function (browser Checkout session + `url`)  
- `/api/stripePaymentIntent` → `stripePaymentIntent` function (iOS Payment Sheet + `clientSecret`)  
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
- Paste **publishable keys** (`pk_test_…` / `pk_live_…`) for the iOS Payment Sheet (must match test vs live mode).
- **Deposit amount** is in **USD cents** (default 5000 = $50). It will not exceed the selected package price when the price can be parsed from `settings/packages`.

## Security

- **Never** put `sk_` or `whsec_` values in Firestore. `settings/site` is readable by anyone with your Firebase config.
- Firestore rules block clients from setting `depositPaid` / `stripeCheckoutSessionId` on create; only Functions (Admin SDK) and authenticated admin updates apply those fields.

## iOS app

The app uses **`POST …/api/stripePaymentIntent`** with `{"bookingId":"…"}` and receives a **PaymentIntent** `clientSecret`, then presents **Stripe Payment Sheet** in-app (not Safari).

- After **Book Your Booth**, **Booking success** shows **Pay deposit with card** when checkout is enabled.
- **Admin → Bookings → Customer: pay deposit (Stripe)** uses the same flow.

Ensure **Public site URL** matches hosting where `stripePaymentIntent` is deployed, and **publishable key** in Admin → Settings matches your Stripe mode (`STRIPE_SECRET_KEY` test vs live). See **`jitterbug-ios/STRIPE-CHECKOUT-TEST-IOS.md`** and **`jitterbug-ios/IOS-STRIPE-NATIVE.md`**.

## Going live

- Replace test `STRIPE_SECRET_KEY` with `sk_live_…` (new secret version / redeploy).
- Add a **live** webhook endpoint pointing to the same `/api/stripeWebhook` path on your production domain.
- Use **live** publishable key in Admin → Settings for live iOS Payment Sheet; website Checkout uses the same secret key via Functions.
