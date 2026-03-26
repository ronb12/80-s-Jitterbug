# macOS: scroll & visible content (windows & sheets)

## Helpers (`Utilities/JitterbugMacSheet.swift`)

| Modifier | Use |
|----------|-----|
| `jitterbugMacNavigationRootFill()` | macOS only: **`frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)`** on every **`NavigationStack`** root (customer tabs, admin tabs, form sheets) and on **top-level** `ScrollView` (landing, CSV/JSON export sheet) so scroll views get a **finite** height. Pair with existing wrappers where applicable. |
| `jitterbugMacSheetScrollableFormWrapper()` | macOS only: vertical `ScrollView` + `fixedSize` around a **`Form`** so it isn’t clipped in sheets, the main **TabView** window, or the tabbed admin hub. The `ScrollView` uses **`frame(maxWidth: .infinity, maxHeight: .infinity)`** so it receives a bounded height and actually scrolls (otherwise the form grows to full height and the window clips the bottom). Inner **horizontal padding** reduces edge clipping on field labels. Also **`contentMargins(0, for: .scrollContent)`** and a small negative top padding under the **navigation title**. |
| `jitterbugMacInsetLeadingScrollableForm()` | macOS preferred for dense **`Form`**s: leading `VStack`, **8 / 36pt** horizontal inset, visible scrollbar. Used by **Book**, **Admin login**, **Add / edit booking**, **Edit package**, **Settings**, **Gallery → edit caption**. Pair with **`.controlSize(.small)`** on the `Form` where it helps. |
| `jitterbugMacFlushScrollContentMargins()` | macOS only: `contentMargins(0, for: .scrollContent)` on **`ScrollView`** roots (customer tabs, legal, export sheet, etc.) for the same title-to-content gap. |
| `jitterbugMacListTightUnderNavigationTitle()` | macOS only: zero scroll content margins + small negative top padding on **`List`** (More, FAQ, admin tabs, tips sheet). |
| `jitterbugMacSheetChromeIfNeeded()` | macOS only: min/max width & height on **modal** sheet roots (`NavigationStack` or export UI). |
| `jitterbugMacSheetChrome()` | Same bounds; use when you know you’re on macOS. |

**Do not** wrap **`List`** in `jitterbugMacSheetScrollableFormWrapper()` — `List` already scrolls (double-scroll risk).

## Audit checklist (rechecked)

### Modal sheets (`.sheet`)

| Presentation | Scroll / fit |
|--------------|----------------|
| Admin login | `NavigationStack` root fill + `Form` + **`jitterbugMacInsetLeadingScrollableForm()`** + small controls + chrome |
| Admin hub (macOS) | `frame(min/max)` on root + **`jitterbugMacNavigationRootFill()`** on `AdminTabView`’s `TabView`; each tab’s `NavigationStack` also uses **root fill** |
| Admin tips | `List` + root fill + chrome |
| Booking detail | `Form` + wrapper + chrome |
| Add booking | `Form` + wrapper + chrome |
| Export file (CSV/JSON) | `ScrollView` + root fill + flush margins + chrome |
| Gallery → edit caption | `Form` + **inset-leading scroll** + small controls + chrome |
| Settings → export JSON | Uses `ExportedFileShareSheet` (same as above) |

### Admin hub tabs (inside mac sheet, bounded height)

| Tab | Scroll |
|-----|--------|
| Dashboard | `List` |
| Bookings | `List` |
| Add / detail booking | sheets (see above) |
| Packages | `List` + macOS **8 / 36pt** horizontal inset; **Edit package** → `Form` + **`jitterbugMacInsetLeadingScrollableForm()`** + small controls |
| Event types | `List` |
| Gallery | `List` + caption sheet |
| Documents | `List` |
| **Settings** | **`Form` + inset-leading scroll** + small controls (long Stripe / help text) |

### Customer app (main window, not sheets)

Each tab’s **`NavigationStack`** uses **`jitterbugMacNavigationRootFill()`** on macOS so `ScrollView` / `List` get a bounded height.

| Screen | Scroll |
|--------|--------|
| Home | `ScrollView` |
| Book | **`Form` + Book scroll wrapper** (inset layout + scrollbar) + small controls + compact date picker |
| Packages | `ScrollView` |
| Gallery | `ScrollView` |
| More | `List` |
| FAQ | `List` |
| Legal | `ScrollView` in `LegalTextView` |
| About / Contact | `ScrollView` |
| Booking lookup | `ScrollView` |
| Booking success | `ScrollView` |
| Landing | macOS: `ScrollView` + **root fill** + `landingMainStack`; iOS: centered `Spacer` layout |

## After changes

Build **Jitterbug80sMac** and smoke-test: Settings (scroll to bottom), Book (submit section), Packages → edit a package with many “included” lines, plus existing admin sheets.
