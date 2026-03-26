import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// Generates print-ready HTML for contract and photo release and presents the system print dialog (or Save as PDF).
enum PrintService {
    private static func escapeHtml(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private static func formatDate(_ iso: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: iso) else { return iso }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    private static func signatureSVG(from signatureStrokes: [[String: Any]]) -> String? {
        var pathParts: [String] = []
        for stroke in signatureStrokes {
            guard let points = stroke["points"] as? [[String: Any]] else { continue }
            var strokePoints: [(Double, Double)] = []
            for point in points {
                guard let x = point["x"] as? Double, let y = point["y"] as? Double else { continue }
                strokePoints.append((x, y))
            }
            guard let first = strokePoints.first else { continue }
            var part = "M \(first.0) \(first.1)"
            for p in strokePoints.dropFirst() {
                part += " L \(p.0) \(p.1)"
            }
            pathParts.append(part)
        }
        guard !pathParts.isEmpty else { return nil }
        let d = pathParts.joined(separator: " ")
        return """
        <svg viewBox="0 0 320 180" width="320" height="180" xmlns="http://www.w3.org/2000/svg" style="background:#fff;border:1px solid #ddd;border-radius:8px;">
          <path d="\(d)" fill="none" stroke="#111" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
        """
    }

    /// Generate HTML for the full booking contract. Contact info from settings.
    static func htmlForContract(
        booking: Booking,
        ownerName: String,
        contactEmail: String,
        contactPhone: String,
        signedName: String? = nil,
        signedAt: String? = nil,
        signatureStrokes: [[String: Any]] = []
    ) -> String {
        let b = booking
        let termsHtml = BookingContractTerms.all.map { term in
            "<div class=\"section\"><h2>\(escapeHtml(term.title))</h2><p>\(escapeHtml(term.body))</p></div>"
        }.joined(separator: "\n  ")
        let messageBlock = b.message.isEmpty ? "" : "<div class=\"section\"><h2>Message</h2><p>\(escapeHtml(b.message))</p></div>"
        let signatureBlock: String = {
            let cleanName = signedName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let signedDateRaw = signedAt?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let signedDate = signedDateRaw.isEmpty ? "" : formatDate(signedDateRaw)
            let svg = signatureSVG(from: signatureStrokes)
            if cleanName.isEmpty && signedDate.isEmpty && svg == nil { return "" }
            return """
              <div class="section">
                <h2>Customer signature</h2>
                \(cleanName.isEmpty ? "" : "<p><strong>Signed by:</strong> \(escapeHtml(cleanName))</p>")
                \(signedDate.isEmpty ? "" : "<p><strong>Signed at:</strong> \(escapeHtml(signedDate))</p>")
                \(svg ?? "")
              </div>
            """
        }()
        return """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Booking \(escapeHtml(b.bookingRef)) – 80's Jitterbug</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 700px; margin: 24px auto; padding: 20px; color: #111; font-size: 14px; }
    h1 { font-size: 1.5rem; color: #ec4899; margin-bottom: 4px; }
    .sub { font-size: 12px; color: #666; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; margin: 16px 0; }
    th, td { text-align: left; padding: 8px 12px; border-bottom: 1px solid #e5e5e5; }
    th { font-weight: 600; color: #444; width: 140px; }
    .section { margin-top: 24px; }
    .section h2 { font-size: 1rem; margin-bottom: 8px; color: #333; }
    .section p { line-height: 1.5; margin: 0; }
    .signature { margin-top: 32px; padding-top: 16px; border-top: 1px solid #ccc; }
    .signature-line span { display: inline-block; width: 200px; border-bottom: 1px solid #111; margin-right: 16px; }
    .contact-box { margin-top: 24px; padding: 12px; background: #f5f5f5; border-radius: 8px; font-size: 13px; }
    @media print { body { margin: 16px; } }
  </style>
</head>
<body>
  <h1>80's Jitterbug Photo Booth</h1>
  <p class="sub" style="font-weight: 600;">Booking Contract</p>
  <p class="sub" style="margin-bottom: 16px;">This document is the booking contract between 80's Jitterbug Photo Booth and the client named below. By signing below, the client agrees to the terms in this contract.</p>
  <table>
    <tr><th>Booking reference</th><td>\(escapeHtml(b.bookingRef))</td></tr>
    <tr><th>Status</th><td>\(b.status.rawValue)</td></tr>
    <tr><th>Requested</th><td>\(formatDate(b.createdAt))</td></tr>
  </table>
  <div class="section">
    <h2>Client</h2>
    <table>
      <tr><th>Name</th><td>\(escapeHtml(b.name))</td></tr>
      <tr><th>Email</th><td>\(escapeHtml(b.email))</td></tr>
      <tr><th>Phone</th><td>\(escapeHtml(b.phone))</td></tr>
    </table>
  </div>
  <div class="section">
    <h2>Event</h2>
    <table>
      <tr><th>Type</th><td>\(escapeHtml(b.eventType))</td></tr>
      <tr><th>Date</th><td>\(escapeHtml(b.eventDate))</td></tr>
      <tr><th>Location</th><td>\(escapeHtml(b.eventLocation))</td></tr>
      <tr><th>Full address</th><td>\(escapeHtml(b.eventAddress))</td></tr>
      <tr><th>Package</th><td>\(escapeHtml(b.package))</td></tr>
    </table>
  </div>
  \(messageBlock)
  <div class="section">
    <h2>Photo release</h2>
    <table>
      <tr><th>Use photos for marketing</th><td>\(b.photoReleaseConsent ? "Yes" : "No")</td></tr>
      <tr><th>Includes minors permission</th><td>\(b.photoReleaseIncludesMinors ? "Yes" : "No")</td></tr>
    </table>
  </div>
  <h2 style="margin-top: 28px; font-size: 1rem; color: #333;">Terms of This Contract</h2>
  <p class="sub" style="margin-bottom: 12px;">The following terms form part of this contract. By signing below, the client agrees to these terms.</p>
  \(termsHtml)
  \(signatureBlock)
  <div class="contact-box">
    <strong>Questions?</strong> Contact \(escapeHtml(ownerName)): \(escapeHtml(contactEmail)) · \(escapeHtml(contactPhone))
  </div>
  <div class="signature">
    <div class="signature-line">Client signature: <span></span> Date: <span></span></div>
  </div>
</body>
</html>
"""
    }

    /// Generate HTML for photo release form. Pass nil for blank form.
    static func htmlForPhotoRelease(
        booking: Booking?,
        contactEmail: String,
        contactPhone: String,
        signedName: String? = nil,
        signedAt: String? = nil,
        signatureStrokes: [[String: Any]] = []
    ) -> String {
        let clientName = booking.map { escapeHtml($0.name) } ?? ""
        let eventDate = booking?.eventDate ?? ""
        let marketingYesNo = booking.map { $0.photoReleaseConsent ? "Yes" : "No" } ?? "__________"
        let minorsYesNo = booking.map { $0.photoReleaseIncludesMinors ? "Yes" : "No" } ?? "__________"
        let refLine = booking.map { "<tr><th>Booking ref</th><td>\(escapeHtml($0.bookingRef))</td></tr>" } ?? ""
        let signatureBlock: String = {
            let cleanName = signedName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let signedDateRaw = signedAt?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let signedDate = signedDateRaw.isEmpty ? "" : formatDate(signedDateRaw)
            let svg = signatureSVG(from: signatureStrokes)
            if cleanName.isEmpty && signedDate.isEmpty && svg == nil { return "" }
            return """
              <div class="section">
                <h2>Customer signature</h2>
                \(cleanName.isEmpty ? "" : "<p><strong>Signed by:</strong> \(escapeHtml(cleanName))</p>")
                \(signedDate.isEmpty ? "" : "<p><strong>Signed at:</strong> \(escapeHtml(signedDate))</p>")
                \(svg ?? "")
              </div>
            """
        }()
        return """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Photo Release Form – 80's Jitterbug</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 640px; margin: 24px auto; padding: 24px; color: #111; font-size: 14px; }
    h1 { font-size: 1.35rem; color: #ec4899; margin-bottom: 4px; }
    .sub { font-size: 12px; color: #666; margin-bottom: 20px; }
    table { width: 100%; border-collapse: collapse; margin: 12px 0; }
    th, td { text-align: left; padding: 6px 10px; border-bottom: 1px solid #e5e5e5; }
    th { font-weight: 600; color: #444; width: 120px; }
    .terms { margin: 20px 0; line-height: 1.5; }
    .terms p { margin: 10px 0; }
    .sig-line { margin-top: 28px; padding-top: 16px; border-top: 1px solid #ccc; }
    .sig-line span { display: inline-block; width: 200px; border-bottom: 1px solid #111; margin-right: 12px; }
    @media print { body { margin: 16px; } }
  </style>
</head>
<body>
  <h1>80's Jitterbug Photo Booth</h1>
  <p class="sub">Photo Release Form</p>
  <table>
    <tr><th>Client name</th><td>\(clientName)</td></tr>
    <tr><th>Event date</th><td>\(eventDate)</td></tr>
    \(refLine)
    <tr><th>Use photos for marketing</th><td>\(marketingYesNo)</td></tr>
    <tr><th>Includes minors permission</th><td>\(minorsYesNo)</td></tr>
  </table>
  <div class="terms">
    <p>I grant 80's Jitterbug Photo Booth permission to use selected photos and/or videos from my event on its website, social media, and marketing materials. I understand that these images may be used to showcase the company's work.</p>
    <p>I understand that 80's Jitterbug will not use images of minors (e.g. children) for marketing unless I have separately granted "minor permission" above or in my booking.</p>
    <p>I warrant that I have authority to agree to the use of likeness of attendees at my event (or have obtained consent where required). I may withdraw this permission later by contacting 80's Jitterbug.</p>
  </div>
  \(signatureBlock)
  <div class="sig-line">
    <p>Signature: <span></span> &nbsp; Date: <span></span></p>
  </div>
</body>
</html>
"""
    }

    /// Present the system print UI (or Save as PDF) for the given HTML. Call from main thread.
    static func printHtml(_ html: String) {
        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              window.rootViewController != nil else { return }
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.jobName = "80's Jitterbug"
        let formatter = UIMarkupTextPrintFormatter(markupText: html)
        formatter.perPageContentInsets = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printFormatter = formatter
        printController.present(animated: true) { _, completed, _ in
            if !completed { }
        }
        #elseif os(macOS)
        printHtmlMacOS(html)
        #endif
    }

    #if os(macOS)
    /// macOS: HTML → attributed string, then system print / Save as PDF.
    private static func printHtmlMacOS(_ html: String) {
        guard let data = html.data(using: .utf8) else { return }
        let opts: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attr = try? NSAttributedString(data: data, options: opts, documentAttributes: nil) else { return }

        let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
        let pageWidth = printInfo.paperSize.width - printInfo.leftMargin - printInfo.rightMargin
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: max(pageWidth, 400), height: 10_000))
        textView.isEditable = false
        textView.isSelectable = true
        textView.textStorage?.setAttributedString(attr)

        let op = NSPrintOperation(view: textView, printInfo: printInfo)
        op.jobTitle = "80's Jitterbug"
        _ = op.run()
    }
    #endif

    /// Print the full contract for a booking. Uses current site settings for contact info.
    static func printContract(booking: Booking, ownerName: String, contactEmail: String, contactPhone: String) {
        let html = htmlForContract(booking: booking, ownerName: ownerName, contactEmail: contactEmail, contactPhone: contactPhone)
        printHtml(html)
    }

    /// Print photo release (pre-filled if booking provided, otherwise blank).
    static func printPhotoRelease(booking: Booking?, contactEmail: String, contactPhone: String) {
        let html = htmlForPhotoRelease(booking: booking, contactEmail: contactEmail, contactPhone: contactPhone)
        printHtml(html)
    }
}
