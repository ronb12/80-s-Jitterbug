import SwiftUI
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

/// Presents iOS `UIActivityViewController` or a macOS sheet (Finder / Save) for a temp export file.
struct ExportedFileShareSheet: View {
    let exportURL: URL
    var onDismiss: () -> Void

    var body: some View {
        #if os(iOS)
        IOSActivityShareSheet(activityItems: [exportURL], onComplete: onDismiss)
        #elseif os(macOS)
        MacExportedFileSheet(url: exportURL, onDismiss: onDismiss)
        #else
        Color.clear.onAppear(perform: onDismiss)
        #endif
    }
}

#if os(iOS)
struct IOSActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var onComplete: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        vc.completionWithItemsHandler = { _, _, _, _ in onComplete?() }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

#if os(macOS)
private struct MacExportedFileSheet: View {
    let url: URL
    var onDismiss: () -> Void

    private var saveContentTypes: [UTType] {
        switch url.pathExtension.lowercased() {
        case "csv": return [.commaSeparatedText]
        case "json": return [.json]
        default: return [.data]
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                Text("Export ready")
                    .font(.headline)
                Text(url.lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Reveal in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                    onDismiss()
                }
                .keyboardShortcut(.defaultAction)
                Button("Save as…") {
                    let panel = NSSavePanel()
                    panel.nameFieldStringValue = url.lastPathComponent
                    panel.allowedContentTypes = saveContentTypes
                    panel.begin { response in
                        if response == .OK, let dest = panel.url {
                            try? FileManager.default.removeItem(at: dest)
                            try? FileManager.default.copyItem(at: url, to: dest)
                        }
                        onDismiss()
                    }
                }
                Button("Cancel", role: .cancel, action: onDismiss)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .jitterbugMacNavigationRootFill()
        .jitterbugMacFlushScrollContentMargins()
        .jitterbugMacSheetChromeIfNeeded()
    }
}
#endif
