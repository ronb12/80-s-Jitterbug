import SwiftUI

extension View {
    /// macOS: Fill the tab or sheet along **both** axes so nested `ScrollView` / `jitterbugMacSheetScrollableFormWrapper`
    /// receives a **finite height** and scrolls instead of growing unbounded (window clips the bottom).
    /// Apply to **`NavigationStack`** roots and to **top-level** `ScrollView` where there is no enclosing stack (e.g. landing).
    @ViewBuilder
    func jitterbugMacNavigationRootFill() -> some View {
        #if os(macOS)
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        #else
        self
        #endif
    }

    /// macOS modal sheets: bounded size and top alignment so tall content scrolls instead of clipping.
    func jitterbugMacSheetChrome() -> some View {
        #if os(macOS)
        frame(
            minWidth: 480,
            idealWidth: 600,
            maxWidth: 920,
            minHeight: 320,
            idealHeight: 520,
            maxHeight: 880,
            alignment: .top
        )
        #else
        self
        #endif
    }

    /// Use after `NavigationStack { … }` so macOS gets chrome without invalid `#if` chains in `body`.
    func jitterbugMacSheetChromeIfNeeded() -> some View {
        #if os(macOS)
        jitterbugMacSheetChrome()
        #else
        self
        #endif
    }

    /// On macOS, wrap a `Form` in a vertical `ScrollView` so content isn’t clipped in **sheets** or the **admin hub**
    /// (tabbed sheet with a max height). On iOS this is a no-op (system `Form` scrolls).
    /// Pairing uses `fixedSize(horizontal: false, vertical: true)` on the `Form` so intrinsic height drives scrolling.
    @ViewBuilder
    func jitterbugMacSheetScrollableFormWrapper() -> some View {
        #if os(macOS)
        // TabView + NavigationStack often propose unbounded height to children; without a max-height fill,
        // ScrollView sizes to full content and the window clips the bottom (no effective scrolling).
        // Padding **before** `frame(maxWidth: .infinity)` so the Form is laid out in a narrower width;
        // padding-after-frame makes the content wider than the viewport and clips the leading edge.
        ScrollView(.vertical, showsIndicators: true) {
            self
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .contentMargins(0, for: .scrollContent)
        #else
        self
        #endif
    }

    /// macOS: scrollable `Form` aligned to the **leading** edge — **Book**, **Admin login**, **Add / edit booking**,
    /// **Edit package**, **Settings**, **Edit caption**, and any other dense `Form` in a tab or sheet.
    /// **Asymmetric** horizontal padding (8pt leading, 36pt trailing) so the block sits left and
    /// does not drift or clip past the right edge of the window/sheet.
    @ViewBuilder
    func jitterbugMacInsetLeadingScrollableForm() -> some View {
        #if os(macOS)
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                self
                    .padding(.leading, 8)
                    .padding(.trailing, 36)
                    .padding(.top, 6)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .contentMargins(0, for: .scrollContent)
        #else
        self
        #endif
    }

    /// macOS: removes default top/bottom scroll content margins (sheet/window chrome gap under titles).
    @ViewBuilder
    func jitterbugMacFlushScrollContentMargins() -> some View {
        #if os(macOS)
        contentMargins(0, for: .scrollContent)
        #else
        self
        #endif
    }

    /// macOS: tightens `List` under a navigation title (same default inset issue as `ScrollView`).
    @ViewBuilder
    func jitterbugMacListTightUnderNavigationTitle() -> some View {
        #if os(macOS)
        contentMargins(0, for: .scrollContent)
        .padding(.top, -6)
        #else
        self
        #endif
    }
}
