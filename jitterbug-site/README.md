# 80's Jitterbug Photo Booth

A modern marketing and booking website for **80's Jitterbug** retro photo booth rentals. Built with Next.js, React, Tailwind CSS, **Vercel** + **Neon**.

---

## Overview

- **Live site:** [https://jitterbug80s.web.app](https://jitterbug80s.web.app)
- **Stack:** Next.js 16 (App Router), React 19, Tailwind CSS 4, Framer Motion. **Hosting:** **[Vercel](https://vercel.com)**. **Database:** **[Neon](https://neon.tech)** (Postgres). **No Firebase client** (no Firestore / Analytics in the browser). Optional server-only **FCM** for push — **`STACK.md`**, **`NEON.md`**, **`VERCEL.md`**.
- **Features:** Public pages (Home, About, Packages, Gallery, Booking, Contact), booking form (API → Neon), owner admin (bookings, packages, event types, gallery), session-persistent admin login

---

## Quick Start

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

---

## Scripts

| Command | Description |
|--------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Production build (Node server + static pages; use Vercel or `next start`) |
| `npm start` | Serve production build locally |

---

## Environment

Copy **`.env.local.example`** to `.env.local` and fill in:

- **Server / Vercel:** `DATABASE_URL` (Neon), `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`; optional `FCM_SERVICE_ACCOUNT_JSON` (Google push only) — **`NEON.md`**, **`VERCEL.md`**
- **Admin:** `NEXT_PUBLIC_ADMIN_EMAIL`, `NEXT_PUBLIC_ADMIN_PASSWORD` (required for `/admin/*`)
- **Optional second admin:** `NEXT_PUBLIC_ADMIN_EMAIL_2`, `NEXT_PUBLIC_ADMIN_PASSWORD_2`
- **Site URL:** `NEXT_PUBLIC_SITE_URL` (e.g. `https://80sjitterbug.com` for canonical and Open Graph)
- **Contact (shown on Contact, Privacy, Terms):** `NEXT_PUBLIC_CONTACT_EMAIL`, `NEXT_PUBLIC_CONTACT_PHONE` (e.g. `you@example.com`, `(555) 123-4567`)

**Google Cloud API keys:** the **website** does not use a browser Firebase config. See **[`GOOGLE-CLOUD-API-KEY-SETUP.md`](GOOGLE-CLOUD-API-KEY-SETUP.md)** mainly for **iOS** / legacy allowlists if needed.

---

## Deployment

**GitHub + Vercel + Neon:** **[`INTEGRATIONS.md`](INTEGRATIONS.md)** — how the three connect and how to verify **`DATABASE_URL`** on Vercel.

**Recommended:** **[`VERCEL.md`](VERCEL.md)** — connect the repo, set env vars, deploy. In **Admin → Settings** (Neon `site_settings`), set **`stripePublicBaseUrl`** to your Vercel production URL (no trailing slash).

**Firebase (Firestore rules, optional legacy hosting):** Project ID **jitterbug80s**.

```bash
firebase deploy --only firestore:rules   # when rules change
```

Custom domain: configure in Vercel and/or [Firebase Hosting](https://console.firebase.google.com/project/jitterbug80s/hosting); set `NEXT_PUBLIC_SITE_URL` accordingly.

---

## Project Structure

```
src/
├── app/                    # App Router routes
│   ├── admin/              # Owner-only: bookings, packages, event-types, gallery
│   ├── about, booking, contact, gallery, packages
│   ├── privacy, terms
│   └── layout.tsx, globals.css
├── components/             # Navigation, Footer, FloatingBookNow, NeonButton
└── lib/                    # Firebase, booking, packages, event-types, gallery, admin-auth
```

---

## Features

- **Public site:** Home, About, Packages, Gallery, Booking, Contact; Privacy and Terms.
- **Booking:** **`POST /api/bookings/submit`** creates a row in **Neon** and can trigger admin FCM when configured. Customer sees a booking reference (e.g. JB-1234).
- **Admin (session-persistent):**
  - **Bookings** — List, filter, search, update status, add/edit/delete, export CSV, copy ref, email link.
  - **Packages** — Edit package names and prices (stored in Firestore; used on Packages page and booking form).
  - **Event types** — Add/edit/remove event types (e.g. Wedding, Birthday) used in the booking form.
  - **Gallery** — Add photos by image URL (no Firebase Storage required); edit captions, delete.
- **Theme:** Neon 80s (pink/black), DM Sans, sticky nav, floating “Book Now.”

---

## Database (Neon)

- **Tables:** See `src/lib/db/schema.ts` (`bookings`, `site_settings`, `packages_config`, `event_types_config`, `gallery_photos`, push token tables).
- **Migrations:** `npm run db:push` with `DATABASE_URL` set — **`NEON.md`**.
- **Firestore:** Still used by the **iOS** app in this repo (`firestore.rules`); not used by the website data layer.

---

## License & Support

Proprietary. For questions or custom domain setup, see the contact details on the live site.
