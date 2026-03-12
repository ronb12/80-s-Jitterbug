# 80's Jitterbug Photo Booth — Website

A modern, responsive website for **80's Jitterbug** photo booth rentals. Built with Next.js, React, Tailwind CSS, and Framer Motion.

## Run locally

```bash
cd jitterbug-site
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Build for production

```bash
npm run build
npm start
```

## Deploy to Firebase Hosting

The site uses project **jitterbug80s** (name: **80s Jitterbug**) so the live URL is **https://jitterbug80s.web.app**.

**One-time setup:** Add your Firebase config to the new project:

1. Open [Firebase Console → jitterbug80s](https://console.firebase.google.com/project/jitterbug80s/overview).
2. Enable **Firestore** (Build → Firestore → Create database) and **Hosting** (Build → Hosting → Get started).
3. Add a **Web app** (</>) in Project settings → Your apps, then copy the `firebaseConfig`.
4. Put the config in **`.env.local`** using the same variable names as in `.env.example` (all `NEXT_PUBLIC_FIREBASE_*` and admin vars).

Then deploy:

```bash
cd jitterbug-site
npm run build
npx firebase-tools deploy --only hosting
npx firebase-tools deploy --only firestore
```

Live site: **https://jitterbug80s.web.app** (or **https://80sjitterbug.com** once you add a custom domain).

**URL that says "80s Jitterbug":** The app is set to use **https://80sjitterbug.com** for canonical and sharing. To make that the real URL: (1) Register **80sjitterbug.com** with a domain provider. (2) In [Firebase Console → Hosting](https://console.firebase.google.com/project/jitterbug80s/hosting), click **Add custom domain**, enter **80sjitterbug.com**, and follow the DNS steps. (3) Set `NEXT_PUBLIC_SITE_URL=https://80sjitterbug.com` in `.env.local`, rebuild and deploy. Then your live URL will be **https://80sjitterbug.com**.

**Delete duplicate projects:** See [DELETE-DUPLICATE-PROJECTS.md](DELETE-DUPLICATE-PROJECTS.md) for links and steps to remove **fir-jitterbug** and **jitterbug-80s** (keep **jitterbug80s**). The CLI cannot delete projects; use the Firebase Console.

## Project structure

- **`src/app/`** — App Router pages (Home, About, Packages, Gallery, Booking, Contact)
- **`src/components/`** — Reusable UI (Navigation, Footer, FloatingBookNow, NeonButton)
- **`src/app/globals.css`** — Global styles and 80s theme (neon colors, grid, utilities)

## Features

- **Mobile-first** responsive layout
- **Sticky navigation** with mobile menu
- **Floating “Book Now”** button
- **Full booking service**: form submits to Firebase Firestore, booking reference (e.g. JB-1234) shown on success
- **Admin bookings page** at `/admin/bookings` — view and update status (pending / confirmed / declined / cancelled). Set `NEXT_PUBLIC_ADMIN_EMAIL` and `NEXT_PUBLIC_ADMIN_PASSWORD` in `.env.local` and sign in to access.
- **Booking form** validation (name, email, phone, event type/date/location, package, message)
- **Per-page SEO** via `layout.tsx` metadata
- **Neon 80s theme** (pink, blue, purple, black) with retro grid and glow effects

## Adding real images

Place photo booth images in `public/` (e.g. `public/gallery/1.jpg`). Use the Next.js `Image` component for optimized loading:

```tsx
import Image from "next/image";
<Image src="/gallery/1.jpg" alt="..." width={400} height={300} />
```

## Booking service & Firestore

1. **Firestore**: Bookings are stored in the `bookings` collection. Deploy rules from the project root:
   ```bash
   firebase deploy --only firestore:rules
   ```
   Rules are in `firestore.rules` (create + read/update for bookings). Tighten with Firebase Auth when you add admin login.

2. **Index**: The first time you load the admin bookings list, Firestore may ask for a composite index (e.g. `bookings` collection, `createdAt` descending). Use the link in the browser console to create it in the Firebase Console.

3. **Admin**: Set `NEXT_PUBLIC_ADMIN_EMAIL` and `NEXT_PUBLIC_ADMIN_PASSWORD` in `.env.local`, then open `/admin/bookings` and sign in to view and manage bookings.

## Tech stack

- Next.js 16 (App Router)
- React 19
- Tailwind CSS 4
- Framer Motion
- Firebase (Analytics, Firestore)
