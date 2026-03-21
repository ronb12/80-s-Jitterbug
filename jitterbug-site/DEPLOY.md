# Deploy 80's Jitterbug website

## Recommended: Vercel (Stripe + booking API on Next.js)

The app uses **Next.js Route Handlers** for Stripe, webhooks, and booking submit. Deploy from **`jitterbug-site`** on **Vercel** and set environment variables — see **`VERCEL.md`**.

In **Admin → Settings** (stored in **Neon** `site_settings`), set **`stripePublicBaseUrl`** to your Vercel production URL (no trailing slash).

---

## Legacy: Firebase Hosting + Cloud Functions

`next.config.ts` **no longer** uses `output: 'export'`, so `npm run build` does **not** produce an `out/` folder for Firebase Hosting as-is. To keep **only** static hosting on Firebase, you would need to restore static export (and lose in-app API routes unless you keep using Cloud Function rewrites).

If you still use **Firebase Functions** + static `out/`:

1. Restore `output: "export"` in `next.config.ts` (and ensure the site does not rely on `/api/*` on the same origin except via Hosting rewrites to Functions).
2. Run:

```bash
cd jitterbug-site
npm run build
firebase deploy --only hosting,functions
```

### Old one-liner (`deploy.sh`)

```bash
cd jitterbug-site
chmod +x deploy.sh
./deploy.sh
```

`deploy.sh` expects a static `out/` build unless you’ve customized the pipeline.

Your Firebase site URL is typically **https://jitterbug80s.web.app** (or your custom domain).

---

**If `firebase deploy` fails:** run `firebase login` first.

**Stripe:** **`STRIPE-SETUP.md`** (Vercel env vars or Firebase Functions secrets).

**Firestore rules:** `firebase deploy --only firestore:rules` when `firestore.rules` changes.

**Push (FCM):** On Vercel, see **`VERCEL.md`** + **`jitterbug-ios/IOS-PUSH.md`**. On Firebase-only, Functions `onBookingCreatedPush`, `onBookingUpdatedPush`, and `registerBookingPushToken` deploy with `functions`; hosting rewrites are in `firebase.json`.
