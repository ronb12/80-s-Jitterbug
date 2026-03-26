import AppKit
import SwiftUI

// MARK: - URLs (keep aligned with `MoreView` / site)

private enum MacMenuSupportURLs {
    static let website = URL(string: "https://jitterbug80s.web.app/")!
    static let faq = URL(string: "https://jitterbug80s.web.app/faq")!
    static let privacy = URL(string: "https://jitterbug80s.web.app/privacy")!
    static let supportEmail = URL(string: "mailto:sbowie207@gmail.com?subject=80%27s%20Jitterbug%20Mac%20app")!
}

private enum MacMenuBundleInfo {
    static var appName: String {
        let b = Bundle.main
        if let s = b.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, !s.isEmpty { return s }
        if let s = b.object(forInfoDictionaryKey: "CFBundleName") as? String, !s.isEmpty { return s }
        return "80's Jitterbug"
    }

    static var aboutOptions: [NSApplication.AboutPanelOptionKey: Any] {
        let b = Bundle.main
        let marketing = b.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build = b.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        let copy = b.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? ""
        var opts: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationName: appName
        ]
        if !marketing.isEmpty {
            opts[.applicationVersion] = marketing
        }
        if !build.isEmpty {
            opts[.version] = build
        }
        if !copy.isEmpty {
            opts[.credits] = NSAttributedString(string: copy)
        }
        return opts
    }
}

/// Menu bar for the native Mac target: **App** (About, Hide, Quit), **Help** (web + mail), **Window** (Close).
/// Native macOS SwiftUI does not expose `AboutCommand()`; we use the standard About panel instead.
struct JitterbugMacApplicationCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About \(MacMenuBundleInfo.appName)") {
                NSApplication.shared.orderFrontStandardAboutPanel(options: MacMenuBundleInfo.aboutOptions)
            }

            Divider()

            Button("Hide \(MacMenuBundleInfo.appName)") {
                NSApplication.shared.hide(nil)
            }
            .keyboardShortcut("h", modifiers: .command)

            Button("Hide Others") {
                NSApplication.shared.hideOtherApplications(nil)
            }
            .keyboardShortcut("h", modifiers: [.command, .option])

            Button("Show All") {
                NSApplication.shared.unhideAllApplications(nil)
            }

            Divider()

            Button("Quit \(MacMenuBundleInfo.appName)") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }

        CommandMenu("Help") {
            Button("80's Jitterbug Website") {
                NSWorkspace.shared.open(MacMenuSupportURLs.website)
            }
            Button("FAQ on the Web") {
                NSWorkspace.shared.open(MacMenuSupportURLs.faq)
            }
            Button("Privacy (Web)") {
                NSWorkspace.shared.open(MacMenuSupportURLs.privacy)
            }
            Divider()
            Button("Email Support…") {
                NSWorkspace.shared.open(MacMenuSupportURLs.supportEmail)
            }
        }

        CommandGroup(after: .windowArrangement) {
            Button("Close Window") {
                NSApplication.shared.keyWindow?.close()
            }
            .keyboardShortcut("w", modifiers: .command)
        }
    }
}
