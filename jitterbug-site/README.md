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

## Project structure

- **`src/app/`** — App Router pages (Home, About, Packages, Gallery, Booking, Contact)
- **`src/components/`** — Reusable UI (Navigation, Footer, FloatingBookNow, NeonButton)
- **`src/app/globals.css`** — Global styles and 80s theme (neon colors, grid, utilities)

## Features

- **Mobile-first** responsive layout
- **Sticky navigation** with mobile menu
- **Floating “Book Now”** button
- **Full booking service**: form submits to Firebase Firestore, booking reference (e.g. JB-1234) shown on success
- **Admin bookings page** at `/admin/bookings` — view and update status (pending / confirmed / declined / cancelled). Set `NEXT_PUBLIC_ADMIN_PASSWORD` in `.env.local` and enter it to unlock.
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

3. **Admin**: Set `NEXT_PUBLIC_ADMIN_PASSWORD` in `.env.local`, then open `/admin/bookings` and enter the password to view and manage bookings.

## Tech stack

- Next.js 16 (App Router)
- React 19
- Tailwind CSS 4
- Framer Motion
- Firebase (Analytics, Firestore)
