# Deploy on Vercel (Stripe + booking API + FCM)

## “No Next.js version detected”

The app’s `package.json` is inside **`jitterbug-site/`**. If you connected the **whole GitHub repo** to Vercel, either:

1. Set **Root Directory** to **`jitterbug-site`** (Project → Settings → General), **or**
2. Use the **repo root** `vercel.json` + `package.json` (see **`../VERCEL-ROOT.md`**), which sets **`outputDirectory`** to **`jitterbug-site/.next`** so the Next.js output is found.

If you still see **routes-manifest.json** / **Output Directory** errors: in Vercel → Settings → Build & Output, **do not** set Output Directory to `.next` at the monorepo root; use **`jitterbug-site/.next`** or leave it empty so `vercel.json` controls it.

---

The Next.js app includes **Route Handlers** that replace Firebase Cloud Functions for:

- `POST /api/stripeCheckout` — hosted Checkout session
- `POST /api/stripePaymentIntent` — Payment Sheet (`clientSecret`)
- `POST /api/stripeWebhook` — Stripe events (raw body; **must** be this URL in Stripe Dashboard)
- `POST /api/registerBookingPushToken` — customer opt-in for deposit-paid push
- `POST /api/bookings/submit` — web booking form (creates **Neon** row + admin **new booking** FCM when configured)
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

### Option A — CLI (recommended)

1. Copy **`.env.vercel.secrets.example`** → **`.env.vercel.secrets`** in `jitterbug-site/` (gitignored).
2. Fill in **`DATABASE_URL`** (Neon), **`STRIPE_SECRET_KEY`**, **`STRIPE_WEBHOOK_SECRET`**. Optionally **`FCM_SERVICE_ACCOUNT_JSON`** for push (see **`NEON.md`**).
3. From **`jitterbug-site/`**:

```bash
npm run vercel:push-env
```

This merges **`.env.local`** (optional Firebase Analytics keys, admin login) with **`.env.vercel.secrets`**, then uploads to **Production** on Vercel. Run **`npm run db:push`** once against your Neon DB (locally or CI) before relying on production data APIs.  
(Optional: set `VERCEL_ENV_TARGETS=production,preview` if you solve Preview branch prompts manually in the dashboard.)

Stripe-only quick test after secrets exist:

```bash
npm run vercel:push-env && npm run deploy:vercel
```

If server secrets are not ready yet, **`npm run vercel:push-env:partial`** pushes only what’s in `.env.local` and generates **`INTERNAL_NEW_BOOKING_NOTIFY_SECRET`** (Stripe routes will error until you add `.env.vercel.secrets` and run **`vercel:push-env`** again).

### Option B — Dashboard

Add these in **Vercel → Project → Settings → Environment Variables** (Production + Preview as needed):

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | **Neon** Postgres connection string (pooled URL recommended). |
| `STRIPE_SECRET_KEY` | Stripe secret key (`sk_…`) |
| `STRIPE_WEBHOOK_SECRET` | Signing secret from Stripe Dashboard → Webhooks |
| `FCM_SERVICE_ACCOUNT_JSON` | Optional — **Google FCM** (server only). Single-line service account JSON. Legacy alias: `FIREBASE_SERVICE_ACCOUNT_JSON`. Without it, push is skipped. |
| `INTERNAL_NEW_BOOKING_NOTIFY_SECRET` | Optional — iOS `notify-new-booking` endpoint; see **`IOS-PUSH.md`**. |

**Schema:** run **`npm run db:push`** with `DATABASE_URL` set (see **`NEON.md`**).

## 3. Stripe webhook

In **Stripe Dashboard → Webhooks**, set the endpoint to:

`https://<your-vercel-domain>/api/stripeWebhook`

Enable at least:

- `checkout.session.completed`
- `payment_intent.succeeded`

## 4. Site settings (Neon `site_settings` row)

In **Admin → Settings** on the website (or via API), set **`stripePublicBaseUrl`** to your **Vercel** production URL (no trailing slash), e.g. `https://jitterbug-site.vercel.app`.  
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

Create `.env.local` with the same variables as Vercel. For FCM, paste minified service account JSON on one line as `FCM_SERVICE_ACCOUNT_JSON`.

```bash
npm run build
```

should succeed before deploying.
