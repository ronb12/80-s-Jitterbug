# Neon (Postgres) database

The **Next.js site** stores all app data in **Neon** (PostgreSQL), not Firestore:

- Bookings, site settings (contact + Stripe publishable config), packages, event types, gallery
- Customer deposit push tokens (`booking_push_tokens`)
- Admin FCM tokens (`admin_fcm_tokens`) when registered via **`POST /api/data/admin-fcm`**

**Push notifications** (optional) use **Google FCM** on the server only via `firebase-admin`. Set **`FCM_SERVICE_ACCOUNT_JSON`** (or legacy **`FIREBASE_SERVICE_ACCOUNT_JSON`**) to a one-line service account JSON. If unset, pushes are skipped (logs a warning). The **browser does not load Firebase**.

## 1. Create Neon project

1. [Neon](https://neon.tech) → New project → copy **connection string** (use **pooled** / serverless-friendly URL when offered).

2. Add to **`.env.local`** and Vercel:

```bash
DATABASE_URL=postgresql://USER:PASSWORD@HOST/neondb?sslmode=require
```

## 2. Apply schema

From **`jitterbug-site/`** with `DATABASE_URL` set:

```bash
npm install
npm run db:push
```

This runs **`drizzle-kit push`** against `src/lib/db/schema.ts`.

**Confirm tables + readiness** (needs `DATABASE_URL` in `.env.local` or env):

```bash
npm run db:verify
```

**Neon CLI** (auth, connection string, `psql` table list): **`NEON-CLI.md`**

## 3. Migrate data from Firestore (optional)

There is no automatic importer. Export bookings/settings from Firebase Console or a script, then insert into Postgres (or use Neon SQL editor / `psql`). Table names match Drizzle (`bookings`, `site_settings`, `packages_config`, `event_types_config`, `gallery_photos`, …).

## 4. iOS app

The **iOS** app still uses **Firestore** in this repo. It will **not** see bookings created on the **web** (Neon) and vice versa until you add a shared API or migrate the app off Firestore. Plan that separately.
