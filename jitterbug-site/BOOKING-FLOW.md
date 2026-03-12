# Booking flow: User → Owner

End-to-end flow from when a user completes "Book Now" to when the owner completes the process.

---

## 1. User: Submits a booking

| Step | What happens |
|------|----------------|
| 1 | User goes to **/booking** (via "Book Your Booth", "Book Now" button, or nav). |
| 2 | Fills out the form: **Name**, **Email**, **Phone**, **Event type**, **Event date**, **Event location**, **Package**, **Message** (optional). |
| 3 | Clicks **"Request Quote"**. |
| 4 | Client-side validation runs (required fields, valid email). If invalid, errors show; form is not submitted. |
| 5 | If valid, `submitBooking(form)` is called (see **Data saved**, below). |
| 6 | On success: user sees **"Request Received!"** and a **booking reference** (e.g. **JB-1234**). They are told to save it and that you’ll get back with a quote. |
| 7 | On error (e.g. Firebase down): a generic error message is shown; they can correct and resubmit. |

**Data saved (Firestore `bookings` collection):**

- `name`, `email`, `phone`, `eventType`, `eventDate`, `eventLocation`, `package`, `message`
- `status`: **"pending"**
- `bookingRef`: e.g. **JB-1234** (unique per booking)
- `createdAt`, `updatedAt`: server timestamps

The customer does **not** get an email confirmation or receipt from the site. They only see the success screen and reference on the page.

---

## 2. Owner: Finding and viewing the booking

| Step | What happens |
|------|----------------|
| 1 | Owner goes to **/admin/bookings** (not linked from the main site; they must know the URL). |
| 2 | Enters **admin email** and **admin password** (from `NEXT_PUBLIC_ADMIN_EMAIL` and `NEXT_PUBLIC_ADMIN_PASSWORD` in `.env.local`). |
| 3 | Clicks **"Unlock"**. If wrong, "Incorrect email or password" is shown. |
| 4 | Once authenticated, the app calls `listBookings()` and loads all bookings from Firestore, **newest first**. |
| 5 | Each booking is shown with: **booking ref**, **status** (pending/confirmed/declined/cancelled), **name**, **email**, **phone**, **event type**, **date**, **location**, **package**, **message**, and **created** time. |

**Important:** There is **no automatic notification** when a new booking is submitted. The owner must open **/admin/bookings** and refresh or revisit the page to see new requests.

---

## 3. Owner: Completing the process

| Step | What happens |
|------|----------------|
| 1 | Owner reviews the booking (contact info, event details, package). |
| 2 | Owner can set **status** with the buttons on each card: **pending** | **confirmed** | **declined** | **cancelled**. |
| 3 | Clicking a status calls `updateBookingStatus(bookingId, status)`. Firestore is updated; the list on the page updates immediately. |
| 4 | **Completing the process** is done **outside the site**: owner contacts the customer (email/phone) to send quote, collect deposit, confirm details, etc. The site does not send any email or SMS to the customer when status changes. |

So “owner completing the process” in the app = **viewing the request and updating status**. All actual follow-up (quote, contract, deposit, confirmation) is manual (email/phone).

---

## 4. Flow summary (one-line)

**User:** Booking page → fill form → Request Quote → **Firestore** (`bookings`, status `pending`) → success screen + booking ref.  
**Owner:** Open /admin/bookings → sign in → see new booking → (optionally) set status to confirmed/declined/cancelled in Firestore → **manually** contact customer to complete (quote, deposit, etc.).

---

## 5. What is *not* in the flow (gaps)

- **No email to owner** when a new booking is submitted.
- **No email/SMS to customer** when owner confirms/declines (they only have the ref to quote when they call/email).
- **No customer-facing “view my booking” page** (customer cannot look up status by ref on the site).
- **No payment or deposit** in the app (handled offline).
- **No link to /admin/bookings** in the main site footer/nav (owner must bookmark or remember the URL).

If you want, the next step could be adding a short “Owner checklist” (e.g. in README or here) for: check admin daily → contact pending bookings → update status after confirmation/decline.
