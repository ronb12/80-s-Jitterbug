# App Store Spam Rejection Audit — 80's Jitterbug

Apple rejects apps for **spam** when they appear low quality, misleading, or designed to game the store. This audit checks the iOS app against common spam rejection triggers and recommends fixes.

---

## 1. Placeholder / incomplete content

| Check | Status | Notes |
|-------|--------|--------|
| "Coming soon" or "Under construction" | ⚠️ **Risk** | **Gallery** shows "Coming soon" when there are no photos, with copy: "We're just getting started! Photos from our events will appear here soon. Book us for your next party and you could be in our first gallery." |
| Lorem ipsum or fake copy | ✅ OK | No placeholder text. |
| Empty or broken screens | ✅ OK | All main screens have real content or clear empty states with CTAs. |

**Recommendation:** Reduce spam risk by softening the gallery empty state so it doesn’t read like an unfinished app:

- Option A: Change the title from **"Coming soon"** to something like **"Gallery"** or **"From our events"** and keep the same body copy (explains new business + CTA).
- Option B: Keep "Coming soon" but ensure the rest of the app (Home, Packages, Booking, FAQ, About, Contact) is clearly complete so reviewers see one intentional “coming soon” section, not a half-built app.

---

## 2. Minimum functionality & unique value

| Check | Status | Notes |
|-------|--------|--------|
| App has a clear purpose | ✅ OK | Photo booth rental business: browse packages, book, lookup booking, view gallery, contact, legal. |
| More than a web wrapper | ✅ OK | Native SwiftUI; no single full-screen WebView. |
| Core features work | ✅ OK | Booking (Firestore), booking lookup, packages from Firestore, gallery (when photos exist), admin (auth, bookings, packages, event types, gallery, documents, settings). |
| Distinct from website | ✅ OK | App adds native UX, booking form, lookup, and admin in one place; not a thin clone of the site. |

No change needed for spam here.

---

## 3. Misleading metadata & keyword stuffing

| Check | Status | Notes |
|-------|--------|--------|
| App name / display name | ⚠️ **Align** | Bundle/display name is **"Jitterbug80s"**; in-app branding is **"80's Jitterbug"**. For consistency (and to match your brand), consider setting **CFBundleDisplayName** to **"80's Jitterbug"** so the home screen matches the app. |
| App Store title | — | In App Store Connect, use a short, accurate title (e.g. **80's Jitterbug** or **80's Jitterbug Photo Booth**). Do **not** pack extra keywords (e.g. "Photo Booth Wedding Birthday Corporate Party Rental…"). |
| Subtitle | — | One short line (e.g. "Retro photo booth rentals"). No keyword stuffing. |
| Description | — | Describe what the app does (browse packages, book, check booking, gallery, contact). Do not promise features the app doesn’t have. |
| Keywords | — | Relevant terms (e.g. photo booth, rental, wedding, 80s) without repeating or stuffing. |

**Recommendation:** In Xcode, set **CFBundleDisplayName** to **"80's Jitterbug"** if that’s your public name. In App Store Connect, keep title/subtitle/description/keywords accurate and free of stuffing.

---

## 4. Contact, support & legal

| Check | Status | Notes |
|-------|--------|--------|
| Contact in app | ✅ OK | More → Quick contact (mailto, tel); Contact screen with email, phone, quote CTA. |
| Support URL (App Store Connect) | — | **Required.** Set to a working URL (e.g. `https://jitterbug80s.web.app/contact/`). |
| Privacy Policy URL | — | **Required.** Set to your live policy (e.g. `https://jitterbug80s.web.app/privacy/`). |
| In-app privacy & terms | ✅ OK | More → Legal: Privacy, Terms, Booking terms (in-app text). |

Ensure Support URL and Privacy Policy URL in App Store Connect point to live pages that match the app’s behavior.

---

## 5. Login walls & required account

| Check | Status | Notes |
|-------|--------|--------|
| Browsing without account | ✅ OK | Users can view Home, Packages, Gallery, FAQ, About, Contact, Legal without signing in. |
| Booking without account | ✅ OK | Booking form does not require an account. |
| Admin behind auth | ✅ OK | Admin is separate (email/password); not a forced gate for normal users. |

No spam concern here.

---

## 6. Broken or deceptive behavior

| Check | Status | Notes |
|-------|--------|--------|
| External links | ✅ OK | `mailto:`, `tel:`, and `https://jitterbug80s.web.app/contact/` are valid. Ensure the domain is live and the contact page works. |
| Promised vs actual features | ✅ OK | App does not promise notifications, reminders, or other unimplemented features in user-facing copy. (Push is declared in capabilities but not implemented; consider removing if you don’t plan to use it.) |
| Crashes / obvious bugs | — | Run the crash test and fix any launch or main-flow crashes before submission. |

No changes required in code for spam; keep links and store listing accurate.

---

## 7. Duplicate / copycat

| Check | Status | Notes |
|-------|--------|--------|
| Same as another app | ✅ OK | Single app for this business. |
| Generic template look | ✅ OK | Branded (80s, neon, pink), custom copy, real packages and booking flow. |

No issue.

---

## 8. Declared but unused capabilities

| Check | Status | Notes |
|-------|--------|--------|
| Push notifications | ⚠️ **Declared, not implemented** | `UIBackgroundModes = remote-notification` and `aps-environment` are set, but the app does not register for or handle push. Reviewers can reject for “declared but not used.” |

**Recommendation:** Either implement push (e.g. booking updates) or remove the Push Notifications capability and `remote-notification` from the target so the binary matches what the app does.

---

## 9. Summary: spam-related actions

| Priority | Action |
|----------|--------|
| **High** | **Gallery empty state:** Replace or reword "Coming soon" so the app doesn’t look incomplete (e.g. "Gallery" / "From our events" + same explanatory copy and CTA). |
| **High** | **App Store Connect:** Set **Support URL** and **Privacy Policy URL**; use an accurate, non-stuffed **title**, **subtitle**, **description**, and **keywords**. |
| **Medium** | **Display name:** Set **CFBundleDisplayName** to **"80's Jitterbug"** in Xcode if that’s your public name. |
| **Medium** | **Push:** Either implement push or remove the Push Notifications capability and `remote-notification` background mode. |
| **Low** | **Links:** Confirm `https://jitterbug80s.web.app` (contact, privacy) is live and correct before submit. |

---

## 10. What already helps avoid spam

- **Native app** with real flows (booking, lookup, packages, gallery, admin).
- **Real business purpose** (photo booth rental) and real contact info.
- **No forced account** for browsing or booking.
- **In-app privacy and terms** plus recommended URLs in App Store Connect.
- **No web-only shell:** app is not a minimal wrapper around a single URL.
- **No placeholder or lorem** outside the single gallery empty state.
- **Consistent branding** (80s, neon, pink) and real content on Home, Packages, FAQ, About.

Addressing the **Gallery "Coming soon"** wording and **metadata/capabilities** (Support/Privacy URLs, title/keywords, push or remove) will significantly reduce the chance of a spam-related rejection.
