# 80's Jitterbug

Retro photo booth rentals — marketing site, booking flow, owner admin, and optional **Stripe** deposits via Firebase Cloud Functions.

---

## Live site

**[https://jitterbug80s.web.app](https://jitterbug80s.web.app)**  
Firebase project: **jitterbug80s**

---

## Repository layout

| Path | Description |
|------|-------------|
| **[`jitterbug-site/`](jitterbug-site)** | Next.js site (static export → Firebase Hosting). Booking form, gallery, admin, legal pages. **Start here** for dev and deploy. |
| **`layout.tsx`** | Root layout helper used by the site build. |
| **Scripts** | `jitterbug-site/deploy.sh`, `rename-and-deploy.sh`, etc. — see each file’s comments. |

Full setup, env vars, scripts, and hosting steps: **[`jitterbug-site/README.md`](jitterbug-site/README.md)**

---

## Quick start (website)

```bash
cd jitterbug-site
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

Production build (outputs `out/` for Firebase):

```bash
npm run build
```

---

## Deploy

Hosting + Cloud Functions (Stripe checkout):

```bash
cd jitterbug-site
./deploy.sh
```

Or manually: `npm run build` then `firebase deploy --only hosting,functions`  
Firestore rules: `firebase deploy --only firestore:rules` when `firestore.rules` changes.

---

## Stripe (optional)

- **Setup:** [`jitterbug-site/STRIPE-SETUP.md`](jitterbug-site/STRIPE-SETUP.md)  
- **API smoke test:** [`jitterbug-site/scripts/test-stripe-checkout.sh`](jitterbug-site/scripts/test-stripe-checkout.sh) (same `POST /api/stripeCheckout` as the web client)

Secrets (`STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`) are **Firebase Functions secrets**, not in Firestore.

---

## iOS app

A **Jitterbug80s** Xcode project may live locally under `jitterbug-ios/` (not always committed). Open `jitterbug-ios/Jitterbug80s/Jitterbug80s.xcodeproj` in Xcode.  
Stripe testing from the app: [`jitterbug-ios/STRIPE-CHECKOUT-TEST-IOS.md`](jitterbug-ios/STRIPE-CHECKOUT-TEST-IOS.md) (if that folder exists in your clone).

---

## Tech stack (site)

Next.js (App Router), React, Tailwind CSS, Firebase (Firestore, Hosting), Cloud Functions (Node + Stripe).

---

**© 80's Jitterbug / Bradley Virtual Solutions, LLC** — see site footer and legal pages for contact and terms.
