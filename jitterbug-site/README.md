# 80's Jitterbug Photo Booth

A modern marketing and booking website for **80's Jitterbug** retro photo booth rentals. Built with Next.js, React, Tailwind CSS, and Firebase.

---

## Overview

- **Live site:** [https://jitterbug80s.web.app](https://jitterbug80s.web.app)
- **Stack:** Next.js 16 (App Router), React 19, Tailwind CSS 4, Framer Motion, Firebase (Firestore, Analytics, Hosting)
- **Features:** Public pages (Home, About, Packages, Gallery, Booking, Contact), booking form with Firestore, owner admin (bookings, packages, event types, gallery), session-persistent admin login

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
| `npm run build` | Production build (output in `out/` for static export) |
| `npm start` | Serve production build locally |

---

## Environment

Copy `.env.example` to `.env.local` and fill in:

- **Firebase:** `NEXT_PUBLIC_FIREBASE_*` (from [Firebase Console](https://console.firebase.google.com/project/jitterbug80s/settings/general) → Your apps)
- **Admin:** `NEXT_PUBLIC_ADMIN_EMAIL`, `NEXT_PUBLIC_ADMIN_PASSWORD` (required for `/admin/*`)
- **Optional second admin:** `NEXT_PUBLIC_ADMIN_EMAIL_2`, `NEXT_PUBLIC_ADMIN_PASSWORD_2`
- **Site URL:** `NEXT_PUBLIC_SITE_URL` (e.g. `https://80sjitterbug.com` for canonical and Open Graph)
- **Contact (shown on Contact, Privacy, Terms):** `NEXT_PUBLIC_CONTACT_EMAIL`, `NEXT_PUBLIC_CONTACT_PHONE` (e.g. `you@example.com`, `(555) 123-4567`)

---

## Deployment (Firebase)

Project ID: **jitterbug80s**.

```bash
npm run build
firebase deploy --only hosting
firebase deploy --only firestore   # when rules change
```

Custom domain: Add the domain in [Firebase Hosting](https://console.firebase.google.com/project/jitterbug80s/hosting), then set `NEXT_PUBLIC_SITE_URL` and redeploy.

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
- **Booking:** Form submits to Firestore; customer sees a booking reference (e.g. JB-1234). No email sending (optional future enhancement).
- **Admin (session-persistent):**
  - **Bookings** — List, filter, search, update status, add/edit/delete, export CSV, copy ref, email link.
  - **Packages** — Edit package names and prices (stored in Firestore; used on Packages page and booking form).
  - **Event types** — Add/edit/remove event types (e.g. Wedding, Birthday) used in the booking form.
  - **Gallery** — Add photos by image URL (no Firebase Storage required); edit captions, delete.
- **Theme:** Neon 80s (pink/black), DM Sans, sticky nav, floating “Book Now.”

---

## Firestore

- **Collections:** `bookings`, `settings` (e.g. `settings/packages`, `settings/eventTypes`, `settings/gallery`).
- **Rules:** See `firestore.rules`. Deploy with `firebase deploy --only firestore`.
- **Indexes:** Create any composite indexes suggested in the browser console when loading admin lists.

---

## License & Support

Proprietary. For questions or custom domain setup, see the contact details on the live site.
