# Admin Area — Feature Audit

What the admin has today vs common gaps.

---

## What You Have

| Feature | Status |
|--------|--------|
| **Login** | Email + password (from .env at build time) |
| **List bookings** | All bookings, newest first; ref, status, name, email, phone, event type/date/location, package, message, created time |
| **Update status** | Pending → Confirmed / Declined / Cancelled |
| **Add manual booking** | Full form (same fields as public); creates booking with ref, adds to list |

---

## Gaps (Nice to Have)

### 1. **Refresh list**
- List is loaded once when you log in. New submissions from the website don’t appear until you reload the page.
- **Add:** A “Refresh” button (or auto-refresh every 1–2 minutes) so you see new bookings without leaving the page.

### 2. **Filter / search**
- No way to filter by status (e.g. “Pending only”) or by event date, or to search by name, email, or booking ref.
- **Add:** Status filter (All / Pending / Confirmed / etc.) and optional search by name, email, or ref.

### 3. **Edit booking**
- You can only change status. You can’t fix a typo in email, change event date, or update package.
- **Add:** “Edit” on each booking → form with current values → save updates to Firestore (new `updateBooking` in booking-service).

### 4. **Delete booking**
- No way to remove a booking (e.g. duplicate, spam, test).
- **Add:** “Delete” with confirmation; call Firestore `deleteDoc` (rules already allow delete).

### 5. **Export**
- No export for accounting or backup.
- **Add:** “Export to CSV” that downloads name, email, phone, event date, package, status, ref, etc.

### 6. **Quick actions**
- **Add:** “Email” (mailto: customer email) and “Copy ref” so you can quickly contact the customer or paste the ref elsewhere.

### 7. **Simple dashboard**
- No at-a-glance counts.
- **Add:** e.g. “X pending”, “X this week”, “X total” at the top.

### 8. **New-booking notification**
- You only see new requests when you open or refresh the admin page. No email or push when someone submits the form.
- **Add:** Backend (e.g. Firebase Cloud Function on `bookings` create) that sends you an email with booking details and ref. (Not in the admin UI itself but improves admin workflow.)

---

## Suggested priority

1. **Refresh** – Low effort, high convenience.
2. **Filter by status** – Very useful as bookings grow.
3. **Edit booking** – Fix mistakes without re-entering.
4. **Delete** – Clean up duplicates/tests.
5. **Export CSV** – Useful for records and taxes.
6. **Quick actions** (email + copy ref) – Small UX win.
7. **Dashboard counts** – Optional polish.
8. **New-booking email** – Requires backend (e.g. Cloud Function); do when you’re ready to add server-side logic.

If you tell me which of these you want first, I can implement them in that order (e.g. Refresh + filter + edit + delete).
