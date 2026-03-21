# 80's Jitterbug — Website Audit

**Date:** March 2026  
**Scope:** Full site audit — technical, security, content, UX, SEO, accessibility, and business features.

---

## 1. Executive summary

The site is **production-ready** with Firebase Auth for admin, locked-down Firestore rules, FAQ, service area, deposit copy, sitemap/robots, skip-to-main link, and contact placeholders. Remaining opportunities: **real photos** (hero/gallery), **payment links** (Stripe/deposit CTA), and **new-booking email** (Cloud Function).

---

## 2. What’s working well

### Technical
- **Stack:** Next.js 16 (App Router), React 19, Tailwind 4, Framer Motion, Firebase (Auth, Firestore, Hosting). Static export (`output: "export"`).
- **Structure:** `app/` (routes), `components/`, `lib/` (services, auth, print). Shared contract terms in `booking-contract-terms.ts`.
- **Build:** TypeScript, ESLint; sitemap and robots use `dynamic = "force-static"` for static export.

### Security
- **Firestore rules:** `bookings`: create public; read/update/delete require `request.auth != null`. `settings` and `gallery`: read public; write require auth. No open write access.
- **Admin auth:** Firebase Authentication only (no password in client). Admin users created in Firebase Console → Authentication → Users. Login shows specific error messages (user not found, wrong password, sign-in method).
- **Admin exposure:** No Admin link in footer; admin at `/admin` for those who know the URL. `robots.txt` disallows `/admin`.

### Public site
- **Pages:** Home, About, Packages, Gallery, Booking, Contact, FAQ, Privacy, Terms, Booking terms, 404, booking lookup.
- **Booking flow:** Required fields, email/phone validation, photo release + minors checkboxes, link to Booking terms. Saves to Firestore with ref; success screen shows ref.
- **Packages & event types:** From Firestore; admin edits propagate to Packages, booking form, and home. **Deposit copy:** “50% deposit to secure your date; balance due 7 days before the event” on Packages and in FAQ.
- **Service area:** Home and About show `NEXT_PUBLIC_SERVICE_AREA` or fallback “Serving the greater area and surrounding communities.”
- **Gallery:** From Firestore; empty state when no photos. Admin can add by URL, edit captions, delete.
- **Contact:** Email + phone (placeholders when env missing: `contact@example.com`, `(555) 000-0000`). Link to booking; no form submission.
- **Branding:** 80s theme, pink/black, DM Sans, sticky nav, floating “Book Now,” logo sparkle animation (aria-hidden).

### Admin
- **Auth:** Firebase Auth; async login/logout; clear error messages. Multiple admins supported (any Firebase user).
- **Hub:** Bookings, Packages, Event types, Gallery, **Documents** (contract template, print contract & photo release).
- **Bookings:** List (newest first), filter, search, edit, delete, export CSV, copy ref, mailto, print contract, print photo release.
- **Documents:** Template preview, open sample in new tab, print photo release (blank + per booking), print contract per booking, links to policies/terms.

### Legal & documents
- **Booking terms:** Deposit, balance, cancellation, venue/tech, liability, photo release (incl. minors). Used in contract print and Documents.
- **Contract print:** Full booking details + full terms + signature (Blob URL).
- **Photo release print:** Standalone (blank or pre-filled from booking).

### SEO & crawlability
- Root metadata: title, description, keywords, Open Graph, canonical, icons. Per-route metadata where checked.
- **Sitemap:** `app/sitemap.ts` — public routes; base URL from `NEXT_PUBLIC_SITE_URL`.
- **Robots:** `app/robots.ts` — Allow `/`, Disallow `/admin`, Sitemap URL.

### Accessibility
- **Skip to main content:** Link at top of body (visible on focus); `<main id="main">`.
- **Forms:** Booking form has visible labels and `htmlFor`/`id` on inputs.
- **Nav:** Mobile menu button has `aria-label="Toggle menu"` and `aria-expanded`. Logo sparkles and gallery placeholder are `aria-hidden`.

---

## 3. Remaining opportunities (optional)

### 3.1 Real photos (content)
- **Current:** Home hero and empty gallery use placeholders (gradients/emojis).
- **Recommendation:** Add 6–12 real booth/event photos via admin Gallery. Replace hero placeholder with one strong photo or short video when available.

### 3.2 Payment links (conversion)
- **Current:** Deposit/balance described in copy; no Stripe or payment links.
- **Recommendation:** When ready, add Stripe (or similar) and “Pay deposit” / “Pay balance” in confirmation flow or follow-up email. Optional: link from booking success or admin booking view.

### 3.3 New-booking notification (operations)
- **Current:** Owner sees new requests only when opening or refreshing admin.
- **Recommendation:** Optional Cloud Function on `bookings` create that emails the owner with ref and details (see `EMAIL-SETUP.md` if present).

### 3.4 Local SEO (optional)
- **Current:** Service area text on Home/About; generic fallback.
- **Recommendation:** Set `NEXT_PUBLIC_SERVICE_AREA` in production (e.g. “Serving [City] and the [Region]”). Optionally add city/region to meta description or title for key pages.

---

## 4. Checklist summary

| Area                | Status | Notes |
|---------------------|--------|--------|
| Public pages        | ✅     | Home, About, Packages, Gallery, Booking, Contact, FAQ, Privacy, Terms, Booking terms, 404, lookup |
| Booking flow        | ✅     | Validation, Firestore, ref, photo release + minors |
| Admin auth          | ✅     | Firebase Auth only; no password in client; clear errors |
| Firestore rules     | ✅     | Public create for bookings; read/write restricted by auth |
| Admin hub           | ✅     | Bookings, Packages, Event types, Gallery, Documents |
| Admin bookings      | ✅     | List, filter, search, edit, delete, export CSV, print contract/photo release |
| Admin documents     | ✅     | Template, print contract/photo release (blank + per booking) |
| FAQ                 | ✅     | Setup, space, power, deposit/balance, included, branding, minimum hours |
| Service area        | ✅     | Home + About; env or fallback |
| Deposit/payment copy| ✅     | Packages + FAQ |
| Sitemap / robots    | ✅     | app/sitemap.ts, app/robots.ts; Disallow /admin |
| Skip to main        | ✅     | Link + main id="main" |
| Contact fallbacks   | ✅     | Placeholder email/phone when env missing |
| Footer              | ✅     | No Admin link; FAQ linked |
| Real photos         | ⚪     | Optional: replace placeholders |
| Payment links       | ⚪     | Optional: Stripe/deposit CTA |
| New-booking email   | ⚪     | Optional: Cloud Function |

---

## 5. Suggested next steps (if any)

1. **Content:** Add real gallery photos and consider one strong hero image.
2. **Conversion:** When ready, add payment (e.g. Stripe) and deposit/balance links.
3. **Operations:** Optionally add new-booking email via Cloud Function.
4. **SEO:** Set `NEXT_PUBLIC_SERVICE_AREA` and optionally refine meta for local search.

---

*Audit reflects the codebase as of the audit date. Re-run after major changes or before launch.*
