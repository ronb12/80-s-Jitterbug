# Mac App Store readiness — **80's Jitterbug** (`Jitterbug80sMac`)

**No one can “confirm” full compliance from source code alone.** Apple validates the **archived binary**, **signing**, **App Store Connect** metadata, and **review guidelines**. Use this as a technical preflight; your legal/compliance review is separate.

---

## Menu bar (Mac)

- **`Utilities/MacAppMenuCommands.swift`** (Mac target only) defines `JitterbugMacApplicationCommands`, attached in **`Jitterbug80sMacApp`** via `.commands { … }`.
- **App menu:** About (standard panel + version/build/credits from Info.plist), Hide, Hide Others, Show All, Quit — with standard shortcuts.
- **Help menu:** Website, FAQ, Privacy (web), Email Support.
- **Window:** Close Window (⌘W) after system window arrangement items.
- **Edit** (Cut/Copy/Paste, etc.) remains the **system default** for `TextField` / `TextEditor` on macOS.

---

## What the project already has (good signs)

| Area | Project state |
|------|----------------|
| **App Sandbox** | `ENABLE_APP_SANDBOX = YES`; entitlements include `com.apple.security.app-sandbox`, `network.client`, `files.user-selected.read-write` (Save as… / exports) |
| **Hardened Runtime** | `ENABLE_HARDENED_RUNTIME = YES` |
| **Encryption export** | `ITSAppUsesNonExemptEncryption = NO` — you must still answer export compliance in App Store Connect accurately |
| **Category** | `LSApplicationCategoryType` = `public.app-category.business` |
| **Copyright** | `NSHumanReadableCopyright` set |
| **Sensitive APIs — strings** | `NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription` present (required if those APIs are used) |
| **Versioning** | `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in build settings (bump per release) |
| **Mac icons** | `AppIcon.appiconset` includes **mac** 512@1x and 512@2x entries |
| **Distribution team** | `DEVELOPMENT_TEAM` set in Xcode |
| **Stripe on native Mac** | `StripeNativePayment` throws `unavailableOnNativeMac`; Mac target does **not** link Stripe SPM (avoids UIKit-only SDK issues). **Describe** limited in-app payment on Mac in review notes / description if relevant. |

---

## Must verify yourself (not provable from repo)

1. **App Store Connect**
   - Mac distribution enabled for this app (Catalyst and/or native Mac, depending on how you ship).
   - **Privacy** nutrition labels match real behavior (Firebase Auth, Firestore, FCM, analytics if any, etc.).
   - Screenshots, description, support URL, privacy policy URL, age rating.

2. **Signing & archive**
   - Archive **Release** with a **Distribution** profile / team signing.
   - Run **Validate App** in Organizer before upload.
   - After archive, check push entitlement:  
     `codesign -d --entitlements :- /path/to/Jitterbug80sMac.app`  
     Store builds should show **`aps-environment` = `production`** (the repo file currently says `development`, which is normal for local debug; distribution signing usually overrides for release).

3. **App Review Guidelines (samples)**
   - **2.1** App completeness, no broken flows.
   - **2.3** Accurate metadata (e.g. Mac vs iPhone capabilities).
   - **2.5.2** Software requirements; **5.1** privacy; **3.1.1** payments (Stripe / web checkout disclosure if needed).

4. **Minimum OS**  
   `MACOSX_DEPLOYMENT_TARGET = 15.6` is aggressive; ensure that matches your marketing and ASC “minimum macOS”.

---

## Issues to treat as **high priority** (security / review risk)

| Issue | Detail |
|--------|--------|
| **ImgBB API key** | No key is committed. Set **`IMGBB_API_KEY`** in Xcode (User-Defined) or CI; see **`BUILD-SECRETS.md`**. The key still ends up in the **shipping bundle** if injected at build time—long term, prefer a **server-side** upload proxy if you need stronger protection. |
| **App `PrivacyInfo.xcprivacy`** | Included in **Jitterbug80s** and **Jitterbug80sMac** bundle resources (declares User Defaults API use with reason **CA92.1**). Firebase SPM brings additional SDK manifests; keep **App Store Connect** privacy labels aligned with real behavior. |

---

## Sandbox: exports (“Save as…”)

Mac target uses **`com.apple.security.files.user-selected.read-write`** and **`ENABLE_USER_SELECTED_FILES = readwrite`**. **Test a Release sandbox build**: Settings/Bookings export → **Save as…** and **Reveal in Finder**.

## Push entitlements (Mac)

- **Debug** → `Jitterbug80sMac-Debug.entitlements` (`aps-environment` = **development**).
- **Release** (App Store archive) → `Jitterbug80sMac-Release.entitlements` (`aps-environment` = **production**).

---

## Documentation correction

- **`MACOS-TARGET.md`**: the **Mac target** uses **`Jitterbug80sMac-Debug.entitlements`** / **`Jitterbug80sMac-Release.entitlements`** (sandbox + network + user-selected read-write + push).

---

## Bottom line

- **Technically aligned** with many Mac App Store **platform** requirements (sandbox, hardened runtime, usage strings, category, icons, privacy manifest, sandbox file access for exports).  
- **Not** a guarantee of approval: set **ImgBB** (and any other) secrets only via local/CI build settings, validate **Release** entitlements (`aps-environment` production), complete **App Store Connect**, and run **Validate App** + manual **sandbox** tests before submission.
