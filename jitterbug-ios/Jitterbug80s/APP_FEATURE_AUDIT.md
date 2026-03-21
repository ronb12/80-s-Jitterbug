# iOS App Feature Audit — 80's Jitterbug

Audit of current features, gaps vs. the web app, and recommended additions.

---

## 1. What the app has today

### Public (customer-facing)

| Area | Features |
|------|----------|
| **Launch** | Landing screen with “80's Jitterbug,” diamond branding, Enter button |
| **Home** | Hero, “We're New,” occasions (Weddings, Birthdays, Corporate, Parties), package preview, gallery teaser, final CTA; service area from Firestore |
| **Packages** | List from Firestore, “Most popular” badge, feature bullets, deposit line, “Request quote” and footer CTA |
| **Gallery** | Grid when photos exist; empty state “From our events” + “Request a booking” |
| **Book** | Full form (name, email, phone, event type/date/location/address, package, message, photo release, minors); success screen with booking reference |
| **More** | About, FAQ, Booking lookup, Contact, Appearance (System/Light/Dark), Legal (Privacy, Terms, Booking terms), Quick contact (email, call, Support web), Admin login |
| **Booking lookup** | Reference field, “Check status,” result card (status, event date/type/location) or “No booking found” |
| **About** | Our Story, Why a Photo Booth?, What We Offer, CTAs |
| **FAQ** | Same Q&As as web |
| **Contact** | Email, phone, Request a Quote (navigate to Book) |
| **Legal** | In-app Privacy, Terms, Booking terms (no external links required) |

### Admin

| Area | Features |
|------|----------|
| **Auth** | Email/password (Firebase), session, Log out |
| **Bookings** | List, filter by status, search, update status, add/edit/delete, email client link |
| **Packages** | Edit names and prices, save to Firestore |
| **Event types** | Add, remove, reorder, save |
| **Gallery** | Add by URL; upload from photo library (ImgBB); delete; list with thumbnails |
| **Documents** | Text explaining terms; booking picker; “Use the website to print contract and photo release” |
| **Settings** | Contact email, contact phone, service area; save to Firestore `settings/site` |

### Technical

- Firebase (Auth, Firestore); ImgBB for image uploads; site settings (contact, service area) from Firestore
- Appearance: System / Light / Dark (More → Appearance)
- No in-app notifications or reminders; push declared in project but not implemented

---

## 2. Gaps vs. web site

| Web feature | iOS status | Note |
|-------------|------------|------|
| **Admin Documents: print contract / photo release** | ⚠️ Partial | Web opens print-ready pages for a booking (contract, photo release). iOS only has text + “use the website”; no deep link to web print URL for selected booking. |
| **Admin Bookings: export CSV** | ❌ Missing | Web can export bookings to CSV; iOS cannot. |
| **Admin Bookings: copy ref, email link** | ⚠️ Partial | Web has copy ref + “email link”; iOS has “Email client” (mailto) only. Copy ref to clipboard would match web. |
| **Booking success: copy ref** | ❌ Missing | Success screen shows ref but no “Copy” button; users must manually note it. |
| **Rest** | ✅ In parity | Home, Packages, Gallery, Book, lookup, About, FAQ, Contact, Legal, admin bookings/packages/event types/gallery/settings align with web. |

---

## 3. Recommended features (in priority order)

### High value, low effort

1. **Copy booking reference (success screen)**  
   On `BookingSuccessView`, add a “Copy reference” button that copies the ref to the clipboard. Reduces support and user error.

2. **Copy booking reference (admin)**  
   In `AdminBookingsView`, add a “Copy ref” action so staff can paste the ref into email or other tools.

3. **Deep link to web print (admin documents)**  
   When a booking is selected in Admin → Documents, show a button “Open contract in Safari” (and optionally “Open photo release in Safari”) that opens the same print URLs the web uses (e.g. `https://jitterbug80s.web.app/...?booking=...` if you add that route, or a generic print page with a ref query). Improves parity with web without reimplementing print in the app.

### Medium value

4. **Export bookings (CSV)**  
   In Admin → Bookings, add “Export CSV” that builds a CSV of visible bookings and shares it (e.g. `UIActivityViewController` / share sheet). Matches web and helps back-office use.

5. **Request App Store review**  
   After a successful booking (or after returning to the app a few times), trigger `SKStoreReviewController.requestReview()` once. Helps ratings without being intrusive.

6. **Save or share booking reference**  
   On success, optional “Add to Calendar” (event date + ref in notes) or “Remind me” (e.g. local notification “Your 80's Jitterbug event is tomorrow”) to reduce no-shows and support.

### Nice to have

7. **Local notifications for bookings**  
   Optional “Remind me 1 day before” (and maybe “3 days before”) for the event date, using the booking ref. Requires notification permission and storing ref + date (e.g. UserDefaults or a simple local list).

8. **Share the app**  
   In More, add “Share app” that opens the share sheet with the App Store link (once live). Helps word of mouth.

9. **Accessibility pass**  
   Add `accessibilityLabel` / `accessibilityHint` on key buttons and sections (e.g. Book, Booking lookup, Copy ref) and test with VoiceOver. Improves accessibility and store perception.

10. **Haptics**  
    Light haptic on “Submit request” and “Copy” (e.g. `UIImpactFeedbackGenerator`) for clearer feedback.

---

## 4. Not recommended (or later)

| Item | Reason |
|------|--------|
| **In-app payments** | You’re selling a physical service; deposit/balance are handled offline. No need for IAP unless you add digital add-ons. |
| **Chat or in-app messaging** | Email/phone and booking form are enough for this use case; adds complexity and moderation. |
| **User accounts for customers** | Booking by form + ref lookup is sufficient; accounts would add sign-in and account-deletion compliance. |
| **Push notifications (until you’re ready)** | Currently declared but unused; either implement (e.g. “Booking confirmed”) or remove capability to avoid “declared but not used” in review. |

---

## 5. Summary

- **Missing vs. web:** Copy ref on success and in admin; optional deep link to web print from Admin Documents; CSV export in admin.
- **Recommended first:** Copy booking reference on success and in admin; then deep link to web print (if URLs exist); then CSV export and request review.
- **Optional later:** Local reminders, share app, accessibility and haptics.

The app is already feature-complete for core flows (browse, book, lookup, contact, admin). The items above are incremental improvements and parity tweaks, not blockers for release.
