# Deploy on Vercel (Stripe + booking API + FCM)

The Next.js app includes **Route Handlers** that replace Firebase Cloud Functions for:

- `POST /api/stripeCheckout` — hosted Checkout session
- `POST /api/stripePaymentIntent` — Payment Sheet (`clientSecret`)
- `POST /api/stripeWebhook` — Stripe events (raw body; **must** be this URL in Stripe Dashboard)
- `POST /api/registerBookingPushToken` — customer opt-in for deposit-paid push
- `POST /api/bookings/submit` — web booking form (creates Firestore doc + admin **new booking** FCM)
- `POST /api/push/notify-new-booking` — iOS: after client `addDocument`, triggers admin **new booking** FCM (secured secret)

`next.config.ts` **does not** use `output: "export"` so the app runs as a **Node** deployment on Vercel.

## 1. Connect the project

### Dashboard

1. Import **`jitterbug-site`** (or monorepo root with **Root Directory** = `jitterbug-site`) in Vercel.
2. Framework: **Next.js** (auto).

### Vercel CLI (from `jitterbug-site/`)

```bash
npx vercel@latest login              # once per machine
npx vercel@latest link --yes         # link this folder to a Vercel project (first time)
npx vercel@latest --prod --yes      # production deploy
```

Preview deploy (no `--prod`): `npx vercel@latest --yes`

The repo includes **`.vercelignore`** so the `functions/` folder (Firebase-only) is not uploaded — it was breaking `next build` typecheck on Vercel.

## 2. Environment variables

Add these in **Vercel → Project → Settings → Environment Variables** (Production + Preview as needed):

| Variable | Description |
|----------|-------------|
| `STRIPE_SECRET_KEY` | Stripe secret key (`sk_…`) |
| `STRIPE_WEBHOOK_SECRET` | Signing secret from Stripe Dashboard → Webhooks |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | **Single-line** JSON of a Firebase **service account** key (Project settings → Service accounts → Generate new private key). Paste the full JSON as one line or use Vercel’s multiline secret. |
| `INTERNAL_NEW_BOOKING_NOTIFY_SECRET` | Long random string. Same value must be set in the **iOS** target as **Info.plist** key `InternalNewBookingNotifySecret` (Xcode → Target → Info). If unset, `/api/push/notify-new-booking` returns 503 (optional if you only create bookings from the **website**, which uses `/api/bookings/submit`). |

**Firestore:** The service account needs permission to read/write `bookings`, `settings/site`, `settings/packages`, `adminFCM`, and subcollections used by push.

## 3. Stripe webhook

In **Stripe Dashboard → Webhooks**, set the endpoint to:

`https://<your-vercel-domain>/api/stripeWebhook`

Enable at least:

- `checkout.session.completed`
- `payment_intent.succeeded`

## 4. Site settings (`settings/site`)

Set **`stripePublicBaseUrl`** to your **Vercel** production URL (no trailing slash), e.g. `https://jitterbug-site.vercel.app`.  
This drives Stripe success/cancel URLs and iOS API base paths.

## 5. Avoid duplicate FCM / webhooks

If you **stop** using Cloud Functions for Stripe and push:

- Point the **Stripe webhook** only at Vercel (remove or disable the old Firebase URL).
- Optionally **undeploy** or remove Firestore triggers `onBookingCreatedPush` / `onBookingUpdatedPush` so FCM is not sent twice.

## 6. Firebase Hosting (optional)

The previous flow built a static `out/` folder for Firebase Hosting. That layout **does not** include these APIs. Either:

- Host the marketing site on **Vercel only**, or  
- Keep **Firebase Hosting** for static pages and **rewrites** to Cloud Functions (legacy) — not mixed with this Node Next build.

## Local dev

```bash
cd jitterbug-site
cp .env.local.example .env.local   # create and fill (see below)
npm install
npm run dev
```

Create `.env.local` with the same variables as Vercel. For `FIREBASE_SERVICE_ACCOUNT_JSON`, you can use a file path only if you add a small loader — easiest is to paste minified JSON on one line.

```bash
npm run build
```

should succeed before deploying.
