# Admin parity: run the business from the iOS app

**Goal:** The owner can fully run the business from the iOS app in the same way they can from the web app.

**Conclusion: Yes.** The iOS app has feature parity with the web admin for all business operations. One workflow difference: contract/photo release **printing** is done by opening the admin Documents page in Safari and using the browser’s Print there (the app does not show a native print dialog).

---

## Admin areas (web vs iOS)

| Area | Web | iOS | Notes |
|------|-----|-----|------|
| **Login** | Email + password, session | Same (More → Admin login) | Firebase Auth |
| **Bookings** | Full CRUD, filter, search, export, print, email | Same | See below |
| **Packages** | Add, edit, delete, save | Same | Add + swipe delete + Save |
| **Event types** | Add, edit, delete, save | Same | Add + swipe delete + Save |
| **Gallery** | Add by URL, edit caption, delete | Same + upload from photo library | iOS adds Photos picker (Imgur upload) |
| **Documents** | Contract template, sample/blank print, pick booking → print, policies links | Same | Print = open Safari to admin/documents |
| **Settings** | Contact email, phone, service area | Same | Shown on site and app |

---

## Bookings (detail)

| Action | Web | iOS |
|--------|-----|-----|
| List bookings | ✅ | ✅ |
| Filter by status | ✅ | ✅ (toolbar menu) |
| Search (name, email, phone, ref, location) | ✅ | ✅ |
| Export CSV | ✅ | ✅ (share sheet) |
| Add booking (manual) | ✅ | ✅ (“Add booking” + form) |
| View detail | ✅ | ✅ (tap row) |
| Copy booking ref | ✅ | ✅ (Copy ref in detail) |
| Edit full booking (all fields + status) | ✅ | ✅ (Edit in detail) |
| Update status only | ✅ | ✅ (picker in detail) |
| Delete booking | ✅ | ✅ (Delete in detail, confirm) |
| Email client | ✅ | ✅ (mailto link in detail) |
| Print contract | ✅ (new tab, then Print) | Open Safari → admin/documents (print there) |
| Print photo release | ✅ (new tab, then Print) | Open Safari → admin/documents (print there) |

---

## Packages

| Action | Web | iOS |
|--------|-----|-----|
| Add package | ✅ | ✅ (“Add package” → “New Package” row) |
| Edit name & price | ✅ | ✅ (inline fields) |
| Delete package | ✅ | ✅ (swipe left) |
| Save to Firestore | ✅ | ✅ (Save in toolbar) |

---

## Event types

| Action | Web | iOS |
|--------|-----|-----|
| Add event type | ✅ | ✅ (“Add event type” → “New type” row) |
| Edit name | ✅ | ✅ (inline field) |
| Delete | ✅ | ✅ (swipe left) |
| Save to Firestore | ✅ | ✅ (Save in toolbar) |

---

## Gallery

| Action | Web | iOS |
|--------|-----|-----|
| Add by image URL | ✅ | ✅ |
| Add with caption | ✅ | ✅ |
| Edit caption | ✅ | ✅ (pencil → sheet) |
| Delete photo | ✅ | ✅ |
| Upload from device | — | ✅ (Photos picker → Imgur) |

---

## Documents

| Action | Web | iOS |
|--------|-----|-----|
| Contract template description | ✅ | ✅ |
| Sample contract preview | ✅ | ✅ (scrollable in-app) |
| Open sample / print blank (in browser) | ✅ | Open in Safari → admin/documents |
| Pick booking → print contract | ✅ | Pick booking, then “Print contract” → Safari |
| Pick booking → print photo release | ✅ | Pick booking, then “Print photo release” → Safari |
| Links: Booking terms, Terms, Privacy | ✅ | ✅ (open in Safari) |

---

## Settings

| Action | Web | iOS |
|--------|-----|-----|
| Contact email | ✅ | ✅ |
| Contact phone | ✅ | ✅ |
| Service area | ✅ | ✅ |
| Save to Firestore | ✅ | ✅ (used on site + app) |

---

## Printing (contract / photo release)

- **Web:** “Print contract” / “Print photo release” open a new tab with HTML, then the browser Print (or Save as PDF) is used.
- **iOS:** The app does not render that HTML or show a native print dialog. Instead, “Print contract” and “Print photo release” open the **admin Documents page in Safari**. The owner signs in on the web (if needed) and uses the same “Print contract” / “Print photo release” buttons there. So the **same outcome** (printed/PDF contract or photo release) is achieved via Safari on the phone.

If the owner is at an event and needs to print without opening Safari, a future enhancement could add in-app printing (e.g. generate HTML and use `UIPrintInteractionController`). Until then, running the business from the app is still complete: all data and actions are in the app; only the final print step is done in the browser.

---

## Summary

The owner can **fully run the business from the iOS app**: manage bookings (add, edit, delete, status, export, email), manage packages and event types (add, edit, delete, save), manage the gallery (add by URL or from photos, edit captions, delete), access documents (template preview, policies, and print via Safari), and update settings (contact and service area). The only difference from the web is that printing contracts and photo releases is done in Safari on the admin Documents page rather than in a native print dialog.
