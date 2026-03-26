import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

private enum JBMoreColors {
    static var systemGray6: Color {
        #if os(iOS)
        Color(uiColor: .systemGray6)
        #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.gray.opacity(0.15)
        #endif
    }
}

private let websiteBaseURL = "https://jitterbug80s.web.app"
private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)
private let contactEmail = "sbowie207@gmail.com"
private let contactPhone = "646-673-1956"
private let contactPhoneTel = "+16466731956"
private let serviceAreaFallback = "Augusta, GA and surrounding areas."

private func telUrl(from phone: String) -> String {
    let digits = phone.filter(\.isNumber)
    if digits.count >= 10 { return "+1\(digits.suffix(10))" }
    return "+16466731956"
}

/// UserDefaults key for appearance; must match ContentView.
private let appearanceModeKey = "appearanceMode"

struct MoreView: View {
    var onOpenAdmin: () -> Void
    var isAdmin: Bool = false
    var onSelectTab: ((Int) -> Void)?
    @State private var siteSettings: SiteSettings?
    @AppStorage(appearanceModeKey) private var appearanceMode = "system"
    @Environment(\.openURL) private var openURL

    private var effectiveEmail: String {
        let s = siteSettings?.contactEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        return (s?.isEmpty == false ? s : nil) ?? contactEmail
    }
    private var effectivePhone: String {
        let s = siteSettings?.contactPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        return (s?.isEmpty == false ? s : nil) ?? contactPhone
    }
    private var effectiveTel: String { telUrl(from: effectivePhone) }
    private var effectiveServiceArea: String {
        let s = siteSettings?.serviceArea.trimmingCharacters(in: .whitespacesAndNewlines)
        return (s?.isEmpty == false ? s : nil) ?? serviceAreaFallback
    }
    private var effectiveOwnerName: String {
        let s = siteSettings?.ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return (s?.isEmpty == false ? s : nil) ?? "Shequanna Bowie"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Info") {
                    NavigationLink("About") {
                        AboutView(onRequestQuote: { onSelectTab?(3) }, onContact: { onSelectTab?(4) }, serviceArea: effectiveServiceArea)
                    }
                    NavigationLink("FAQ") { FAQView() }
                    NavigationLink("Booking lookup") { BookingLookupView() }
                    NavigationLink("Contact") {
                        ContactView(onRequestQuote: { onSelectTab?(3) }, ownerName: effectiveOwnerName, contactEmail: effectiveEmail, contactPhone: effectivePhone, contactPhoneTel: effectiveTel)
                    }
                }
                Section("Appearance") {
                    Picker("Theme", selection: $appearanceMode) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }
                Section("Legal") {
                    NavigationLink("Privacy", destination: LegalTextView(title: "Privacy", content: LegalContent.privacy))
                    NavigationLink("Terms", destination: LegalTextView(title: "Terms", content: LegalContent.terms))
                    NavigationLink("Booking terms", destination: LegalTextView(title: "Booking Terms", content: LegalContent.bookingTerms))
                }
                Section("Quick contact") {
                    Button("Email us") {
                        if let url = URL(string: "mailto:\(effectiveEmail)") {
                            openURL(url)
                        }
                    }
                    Button("Call") {
                        if let url = URL(string: "tel:\(effectiveTel)") {
                            openURL(url)
                        }
                    }
                    NavigationLink("Contact") {
                        ContactView(onRequestQuote: { onSelectTab?(3) }, ownerName: effectiveOwnerName, contactEmail: effectiveEmail, contactPhone: effectivePhone, contactPhoneTel: effectiveTel)
                    }
                }
                Section {
                    Button(isAdmin ? "Admin" : "Admin login", action: onOpenAdmin)
                        .foregroundStyle(Color(red: 0.93, green: 0.28, blue: 0.6))
                }
                Section("Credit") {
                    VStack(spacing: 4) {
                        Text("Built by Ronell Bradley")
                        Text("Product of Bradley Virtual Solutions, LLC")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            .jitterbugMacListTightUnderNavigationTitle()
            .navigationTitle("More")
            .task { siteSettings = await SettingsService().getSiteSettings() }
        }
        .jitterbugMacNavigationRootFill()
    }
}

struct FAQView: View {
    var body: some View {
        List {
            FAQRow(q: "How long does setup and teardown take?", a: "We typically need about 45–60 minutes for setup before your event and 30–45 minutes for teardown after.")
            FAQRow(q: "How much space do you need?", a: "We recommend a clear area of about 10×10 feet for the booth, backdrop, and props.")
            FAQRow(q: "What about power?", a: "We need access to a standard 120V outlet. We bring extension cords.")
            FAQRow(q: "What's the deposit and when is the balance due?", a: "A 50% deposit secures your date. The remaining balance is due 7 days before your event.")
            FAQRow(q: "What's included?", a: "All packages include retro booth setup, unlimited digital photos, backdrop and props, and setup & teardown.")
            FAQRow(q: "Custom branding?", a: "Yes. Standard and VIP packages include custom branding on prints.")
            FAQRow(q: "Minimum rental period?", a: "We generally recommend at least 3 hours. Shorter events can be discussed.")
        }
        .jitterbugMacListTightUnderNavigationTitle()
        .navigationTitle("FAQ")
    }
}

struct FAQRow: View {
    let q: String
    let a: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(q).font(.headline)
            Text(a).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct LegalTextView: View {
    let title: String
    let content: String
    var body: some View {
        ScrollView {
            Text(content)
                .font(.body)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        #if os(macOS)
        .jitterbugMacFlushScrollContentMargins()
        #endif
        .navigationTitle(title)
    }
}

enum LegalContent {
    static let privacy = """
    Privacy Policy — 80's Jitterbug

    We collect information you provide when you use our website or app or request a booking: name, email address, phone number, and event details (date, location, package, message). We use this information to process your booking request, communicate with you, and provide our photo booth services.

    We do not sell your personal information. We may share data with service providers that help us operate (e.g., hosting, email); they are required to protect your information.

    If you agree to the photo release when booking, we may use selected event photos on our website, social media, or marketing materials as described in our Booking Terms. We will not use photos of minors for marketing unless you separately grant permission.

    We retain booking and contact information as needed for our business and legal obligations. You may contact us to ask about your data or to request deletion where applicable.

    For questions about this privacy policy or your data, contact us by email or phone (see Contact in this app or on our website).
    """

    static let terms = """
    Terms of Service — 80's Jitterbug

    1. Agreement to Terms
    By using the 80's Jitterbug website or app and requesting or booking our photo booth services, you agree to these terms. If you do not agree, please do not use our services.

    2. Services
    We provide photo booth rental services for events. Quotes and availability are subject to confirmation. A booking is confirmed only when we have agreed in writing (e.g., email) and any deposit or terms we specify have been met.

    3. Booking & Payment
    Submitting a request through our website or app does not guarantee a booking. We will contact you to confirm details, pricing, and payment. Payment terms (deposit, balance, cancellation) will be communicated at the time of confirmation.

    4. Cancellation
    Cancellation policies will be stated in your booking confirmation. Please contact us as soon as possible if you need to change or cancel your event.

    5. Use of Website and App
    You may use this website and app only for lawful purposes. You may not attempt to interfere with the site or app, access data you are not authorized to access, or use our name or content for unauthorized purposes.

    6. Limitation of Liability
    To the extent permitted by law, 80's Jitterbug is not liable for indirect, incidental, or consequential damages arising from your use of the website, app, or our services. Our liability is limited to the amount you paid for the service in question.

    For questions about these terms or your booking, contact us by email or phone (see Contact in this app or on our website).
    """

    static let bookingTerms = """
    Booking Terms — 80's Jitterbug

    These terms apply when you book 80's Jitterbug for your event. By confirming a booking (including payment of the deposit), you agree to these terms. We recommend reviewing them before you confirm.

    1. Services & What's Included
    The services we provide are described in your quote and confirmation: photo booth type, rental hours, setup and teardown, and included items (e.g., prints, props, backdrop, online gallery, attendant if applicable). Any upgrades or add-ons will be listed in your confirmation. We will arrive in time to set up before your event start (typically at least one hour prior, unless otherwise agreed). Overtime or extra hours may be available for an additional fee; we will confirm the rate when you book or request it.

    2. Venue & Technical Requirements
    You are responsible for providing adequate space (typically at least 10×10 feet for the booth and queue), level ground, and a standard electrical outlet within a reasonable distance of the setup (e.g., 50 feet). If your package requires internet or WiFi for digital delivery or printing, you agree to provide a stable connection; we are not responsible for delays or print issues caused by venue connectivity. You must provide a safe working environment for our staff and equipment, free of hazards, violence, or harassment. We reserve the right to cease operations and remove equipment if conditions become unsafe; in such cases no refund is due.

    3. Deposit & Confirmation
    A non-refundable deposit (typically 50% of the total, or as stated in your quote) is required to confirm your booking. The deposit secures your date and is applied toward your total. We will send payment details when we confirm your quote. Accepted payment methods (e.g., card, transfer, check) and any fees (e.g., for returned checks) will be communicated at that time. Your booking is confirmed only after we receive the deposit and send you a written confirmation (e.g., by email).

    4. Balance Due & Late Payment
    The remaining balance is due no later than the date we specify in your confirmation (often 7–14 days before the event, or as agreed). We may accept payment on the day of the event by prior arrangement. If the balance is not received by the due date, we reserve the right to treat the booking as cancelled and the deposit as forfeited, and we are not obligated to perform services.

    5. Cancellation & Rescheduling
    The deposit is non-refundable. If you cancel after paying the balance, we may refund the balance (excluding the deposit) only if you cancel with sufficient notice (e.g., 7–14+ days before the event, as we specify in your confirmation) and we can rebook the date; otherwise the full amount may be forfeited. Rescheduling or date changes must be requested in writing and are subject to availability; we will work with you to find an alternative date when possible. We reserve the right to cancel or reschedule due to circumstances beyond our control (e.g., severe weather, illness, equipment failure); in that case we will offer a full refund or a new date.

    6. Equipment Damage & Liability
    You are responsible for any damage to or loss of our equipment caused by you, your guests, or the venue (including misuse, theft, or damage from fire, flood, or similar). To the fullest extent permitted by law, 80's Jitterbug is not liable for indirect, incidental, or consequential damages (including loss of enjoyment, lost profits, or third-party claims) arising from your event, our equipment, or our services. Our liability is limited to the amount you paid for the booking. You indemnify us (and our staff) against claims arising from the event except where caused by our fault or negligence. If we are unable to provide a fully operational photo booth for the event, your remedy is a refund of amounts paid for the affected service; we are not liable for further damages. Partial service (e.g., brief downtime) may be prorated or addressed as we reasonably determine.

    7. Use of Event Photos (Photo Release)
    When you grant permission (e.g., by checking the photo release box on our booking form), we may use selected photos from your event on our website, social media, and marketing materials to showcase our work. We will not use images of minors (e.g. children) unless you separately grant "minor permission" on the booking form; if you do grant that permission, we may use photos that include minors in the same ways. We will not use your photos in a way that is misleading or inappropriate. If you do not grant permission, we will not use your event photos for marketing. You can withdraw permission later by contacting us; we will remove existing uses where practicable. You warrant that you have authority to agree to the use of likeness of attendees at your event (or that you have obtained consent where required).

    8. Entire Agreement & Changes
    These Booking Terms, together with your written confirmation and our general Terms of Service, constitute the entire agreement for this booking. Changes must be agreed in writing. These terms are governed by the laws of the state in which the event takes place (or our business is located, if not specified).

    For questions about these booking terms, your quote, or payment, contact us by email or phone (see Contact in this app or on our website).
    """
}

// MARK: - About (matches web About page)
struct AboutView: View {
    var onRequestQuote: (() -> Void)?
    var onContact: (() -> Void)?
    var serviceArea: String = serviceAreaFallback

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(spacing: 12) {
                    Text("About 80's Jitterbug")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(accentPink)
                    Text("Professional photo booth rentals with a retro twist. We bring the fun, the neon, and the memories.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Text(serviceArea)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

                aboutSection("Our Story") {
                    Text("80's Jitterbug was born from a simple idea: every celebration deserves a moment of pure, unscripted fun. We combine the energy of the 80s—neon lights, bold colors, and that carefree vibe—with modern photo booth technology so your guests get instant, shareable memories.")
                    Text("Whether it's a wedding, birthday, corporate event, or party, we show up with a polished setup, professional service, and an eye for the details. Our goal is to make your job as the host easy while giving your guests something they'll talk about long after the last song plays.")
                }

                aboutSection("Why a Photo Booth?") {
                    Text("Photo booths aren't just a novelty—they're a proven way to bring people together and create keepsakes that last.")
                }
                whyItems

                aboutSection("What We Offer") {
                    bullet("Professional setup & teardown — We handle everything so you can enjoy your own event.")
                    bullet("Retro 80s styling — Neon backdrops, props, and a vibe that stands out from typical booths.")
                    bullet("Unlimited photos — No per-print nickel-and-diming; we want everyone to take as many as they like.")
                    bullet("Digital delivery — Guests can access and share their photos online after the event.")
                    bullet("Flexible packages — From intimate gatherings to full-blown parties, we have options that scale.")
                }

                VStack(spacing: 16) {
                    Text("Ready to Bring the Retro Vibes?")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    Text("Tell us about your event and we'll put together a quote. No obligation—just a quick, friendly conversation.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    HStack(spacing: 12) {
                        if let onRequestQuote = onRequestQuote {
                            Button(action: onRequestQuote) {
                                Text("Request a Quote")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(accentPink)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                        if let onContact = onContact {
                            Button(action: onContact) {
                                Text("Contact Us")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .overlay(Capsule().stroke(accentPink, lineWidth: 2))
                                    .foregroundStyle(accentPink)
                            }
                        }
                    }
                }
                .padding(20)
                .background(JBMoreColors.systemGray6)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        #if os(macOS)
        .jitterbugMacFlushScrollContentMargins()
        #endif
        .navigationTitle("About")
    }

    private func aboutSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var whyItems: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Bundled PNGs (Assets) — same emoji as web About; no “?” from missing emoji fonts.
            whyRow(assetName: "IconHandshake", title: "Break the ice", desc: "Guests who might not mingle naturally end up laughing together in front of the camera.")
            whyRow(assetName: "IconCamera", title: "Instant takeaways", desc: "Print or digital—everyone leaves with a tangible memory from your event.")
            whyRow(assetName: "IconSparkles", title: "Social-ready content", desc: "Shareable photos and boomerangs that extend the buzz of your event online.")
        }
    }

    private func whyRow(assetName: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(desc).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JBMoreColors.systemGray6)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(accentPink)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
                .accessibilityHidden(true)
            Text(text)
        }
    }
}

// MARK: - Contact (matches web Contact page)
struct ContactView: View {
    var onRequestQuote: (() -> Void)?
    var ownerName: String = "Shequanna Bowie"
    var contactEmail: String = "sbowie207@gmail.com"
    var contactPhone: String = "646-673-1956"
    var contactPhoneTel: String = "+16466731956"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Get in touch for photo booth rentals. We'd love to hear about your event.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !ownerName.isEmpty {
                    Text(ownerName)
                        .font(.title2.weight(.semibold))
                }
                contactBlock(title: "Email", subtitle: "For quotes, bookings, or general questions:") {
                    Link(contactEmail, destination: URL(string: "mailto:\(contactEmail)")!)
                }
                contactBlock(title: "Phone", subtitle: "Call or text to discuss your event:") {
                    Link(contactPhone, destination: URL(string: "tel:\(contactPhoneTel)")!)
                }
                contactBlock(title: "Request a Quote", subtitle: "Prefer to send event details online? Use our booking form and we'll get back to you with availability and pricing.") {
                    if let onRequestQuote = onRequestQuote {
                        Button(action: onRequestQuote) {
                            Text("Book Your Booth")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(accentPink)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding()
        }
        #if os(macOS)
        .jitterbugMacFlushScrollContentMargins()
        #endif
        .navigationTitle("Contact Us")
    }

    private func contactBlock<C: View>(title: String, subtitle: String, @ViewBuilder action: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(accentPink)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            action()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(JBMoreColors.systemGray6)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
