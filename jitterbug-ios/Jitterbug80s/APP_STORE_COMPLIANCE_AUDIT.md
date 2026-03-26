# App Store Compliance Audit — 80's Jitterbug

This document audits the **80's Jitterbug** iOS app against Apple’s App Store Review Guidelines, App Privacy, and common compliance areas. Use it to fix gaps before submission and to fill out App Store Connect correctly.

---

## 1. Privacy & data handling

### 1.1 Data collection (what the app collects)

| Data | Where | Purpose | Linked to user? |
|------|--------|---------|------------------|
| **Name, email, phone** | Booking form → Firestore `bookings` | Process bookings, contact customer | Yes |
| **Event details** (date, type, location, address, package, message) | Booking form → Firestore | Fulfill service | Yes |
| **Photo release consent** (incl. minors) | Booking form → Firestore | Legal consent for use of event photos | Yes |
| **Admin email** | Firebase Auth (admin sign-in only) | Account management | Yes |
| **Photos from device** | Admin only: PhotosPicker → ImgBB API → URL in Firestore | Gallery management | No (admin action; gallery is public) |

**Compliance:**  
- In-app privacy text (More → Legal → Privacy) describes booking data and “we do not sell your data.”  
- **Action:** In **App Store Connect → App Privacy**, declare: **Name**, **Email address**, **Phone number** (and optionally **User ID** for admin) as “Data linked to you,” purpose **App functionality** / **Account management** as appropriate.  
- **Action:** Ensure your **web Privacy Policy URL** (required in App Store Connect) matches this behavior and includes Firestore, Firebase Auth, and ImgBB if you mention third parties.

---

## 2. Permission usage descriptions (Info.plist)

Apple requires a clear, user-facing reason for each capability that accesses sensitive data.

| Capability | Status | Notes |
|------------|--------|--------|
| **Photo Library** | ✅ **Set** | `NSPhotoLibraryUsageDescription` is configured on the target (admin gallery uploads). |
| Camera | ✅ N/A | Not used. |
| Location | ✅ N/A | Not used. |
| Microphone | ✅ N/A | Not used. |
| Push Notifications | ✅ **Removed** | `aps-environment` and `UIBackgroundModes = remote-notification` were removed; the app does not use push. Re-add only if you implement FCM/APNs later. |

**Action:**  
1. ~~Add NSPhotoLibraryUsageDescription~~ — done.  
2. ~~Push~~ — unused declarations removed from entitlements and Info.

---

## 3. Sign in with Apple (Guideline 4.8)

- The app uses **Firebase Auth with email/password only** for **admin** sign-in.  
- There is **no** “Sign in with Google/Facebook/Apple” or other third-party **social** login for users.  
- **Conclusion:** Sign in with Apple is **not required** for this app. If you later add social login (e.g. “Sign in with Google”), you must also offer Sign in with Apple for that flow.

---

## 4. Account creation and account deletion (Guideline 5.1.1(v))

- **Users** do not create accounts in the app; they submit a **booking** (name, email, phone, etc.).  
- **Admins** use pre-configured Firebase Auth accounts (created in Firebase Console), not in-app registration.  
- **Conclusion:** Apple’s “account deletion” requirement for **user**-created accounts does not clearly apply. To be safe:  
  - In **App Store Connect** and/or **Support URL**, state that the app does not create user accounts; bookings are one-time submissions.  
  - If asked, explain that “admin” accounts are business accounts managed in Firebase Console (no in-app account creation/deletion).  
- **Optional:** In your **Privacy Policy** or **Support** page, describe how users can request deletion of their booking/data (e.g. contact email).

---

## 5. Export compliance (encryption)

- **ITSAppUsesNonExemptEncryption = NO** is set in the project.  
- The app uses standard HTTPS/TLS only (Firebase, ImgBB).  
- **Conclusion:** Compliant. In App Store Connect, answer the encryption questions as “No” for non-exempt encryption; no separate export documentation is typically needed.

---

## 6. Third-party SDKs and services

| Service | Use | App Privacy / disclosure |
|---------|-----|---------------------------|
| **Firebase Auth** | Admin sign-in | Declare “User ID” / account management if you describe admin login. |
| **Firebase Firestore** | Bookings, packages, event types, gallery metadata, site settings | Data stored in Google’s cloud; declare purposes (e.g. App functionality). |
| **ImgBB** | Admin uploads images; returns public URL stored in Firestore | Image data is sent to ImgBB. Mention in Privacy Policy; in App Privacy, this is “admin” usage (no end-user account). |

**Action:**  
- In App Store Connect → App Privacy, list **Firebase** (Auth, Firestore) and, if applicable, that **images** are processed by a third-party service (ImgBB) for gallery uploads.  
- **ImgBB API key:** Set via Xcode **User-Defined** `IMGBB_API_KEY` or env (see repo `jitterbug-ios/BUILD-SECRETS.md`); do not commit keys. For stronger protection, use a backend upload proxy instead of embedding a client key.

---

## 7. App Store Connect metadata and legal

| Item | Requirement | Status / action |
|------|-------------|------------------|
| **Privacy Policy URL** | Required | Set to your live policy, e.g. `https://jitterbug80s.web.app/privacy/`. Must match what the app does (booking data, Firestore, Auth, ImgBB). |
| **Support URL** | Required | e.g. `https://jitterbug80s.web.app/contact/`. |
| **Terms / EULA** | Optional | In-app Terms and Booking terms exist; no separate EULA required unless you add one. |
| **Contact** | Good practice | App shows contact (e.g. sbowie207@gmail.com, 646-673-1956) and Support (web). |

---

## 8. Content and age rating

- No gambling, violence, sexual content, or user-generated content from general users (gallery is admin-curated).  
- **Conclusion:** Age rating **4+** is appropriate. Complete the App Store Connect questionnaire honestly.

---

## 9. In-app purchase and payments

- The app does **not** sell digital goods or subscriptions.  
- Bookings are for a **physical service** (photo booth rental); payment is handled outside the app.  
- **Conclusion:** No in-app purchase or StoreKit required.

---

## 10. Advertising and tracking

- No advertising SDKs.  
- No use of IDFA or other tracking for ads or cross-app tracking.  
- **Conclusion:** In App Privacy, “Data used to track you” = **None**. No ATT prompt needed.

---

## 11. Display name and branding

- **Current:** `CFBundleDisplayName` = **"80's Jitterbug"** (target Info / build settings).

---

## 12. Accessibility

- No explicit `accessibilityLabel` / `accessibilityHint` audit was performed.  
- SwiftUI provides basic accessibility by default.  
- **Action:** Before release, run **Accessibility Inspector** and VoiceOver on key flows (booking, lookup, More, Admin). Add labels/hints where needed so all actions and content are clear.

---

## 13. Summary: required and recommended actions

### Must fix before submission

1. ~~**NSPhotoLibraryUsageDescription**~~ — already set on the target.

2. **App Store Connect**  
   - Set **Privacy Policy URL** (e.g. `https://jitterbug80s.web.app/privacy/`).  
   - Set **Support URL** (e.g. `https://jitterbug80s.web.app/contact/`).  
   - Complete **App Privacy** for: name, email, phone (booking); optionally User ID (admin); purposes = App functionality / Account management; third parties = Firebase (and ImgBB if you disclose it).  
   - Complete **Age rating** questionnaire (expect 4+).

3. ~~**Push / background**~~ — unused push entitlements and `remote-notification` background mode removed from the project.

### Recommended

- In **Privacy Policy** (web), mention Firestore, Firebase Auth, and ImgBB (for admin gallery uploads).  
- Add a sentence on how users can request **deletion of their data** (e.g. contact you).  
- Run an **accessibility** pass (VoiceOver, Accessibility Inspector).  
- **ImgBB API key** is already set in the project; optional: if the repo is public, use a private config or backend proxy for the key.

### Already in good shape

- Export compliance (ITSAppUsesNonExemptEncryption = NO).  
- In-app Privacy, Terms, and Booking terms.  
- No Sign in with Apple required (email/password only).  
- No IAP, no ads, no tracking.  
- Contact and support available in the app and via URLs.

---

## Quick reference

| Area | Status |
|------|--------|
| Privacy Policy URL (App Store Connect) | Set required URL |
| Support URL (App Store Connect) | Set required URL |
| App Privacy (data types & purposes) | Complete in App Store Connect |
| NSPhotoLibraryUsageDescription | ✅ Set |
| Push / remote-notification | ✅ Removed (unused) |
| Export compliance | ✅ Set (NO) |
| Sign in with Apple | ✅ N/A |
| Account deletion | N/A for users; document if asked |
| Third-party (Firebase, ImgBB) | Declare / document |
| Display name | Optional: "80's Jitterbug" |
| Accessibility | Recommended pass |

After completing the “Must fix” items and the App Store Connect fields, the app should align with App Store compliance expectations for this type of app.
