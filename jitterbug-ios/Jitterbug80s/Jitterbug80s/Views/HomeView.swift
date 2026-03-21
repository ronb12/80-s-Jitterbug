import SwiftUI

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)
private let serviceAreaFallback = "Augusta, GA and surrounding areas."

private let featuredEvents: [(title: String, icon: String, desc: String)] = [
    ("Weddings", "💒", "Say I do with style"),
    ("Birthdays", "🎂", "Celebrate in neon"),
    ("Corporate", "🏢", "Team building, retro style"),
    ("Parties", "🎉", "Any occasion"),
]

struct HomeView: View {
    var onBook: () -> Void
    var onSelectTab: ((Int) -> Void)?
    @State private var packages: [PackagePrice] = []
    @State private var loading = true
    @State private var siteSettings: SiteSettings?
    @State private var diamondOpacity: Double = 0.6
    @State private var diamondScale: CGFloat = 0.95

    private var effectiveServiceArea: String {
        let s = siteSettings?.serviceArea.trimmingCharacters(in: .whitespacesAndNewlines)
        return (s?.isEmpty == false ? s : nil) ?? serviceAreaFallback
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero
                    heroSection

                    // We're New—and Ready for You
                    weAreNewSection

                    // Perfect For Every Occasion
                    featuredEventsSection

                    // Packages That Pop
                    packagesSection

                    // From Our Events (gallery preview)
                    galleryPreviewSection

                    // Ready to Bring the Retro Vibes?
                    finalCTASection
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    navTitleWithDiamonds
                }
            }
            .task {
                siteSettings = await SettingsService().getSiteSettings()
                packages = await PackagesService().getPackages()
                loading = false
            }
        }
    }

    private var navTitleWithDiamonds: some View {
        HStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { _ in
                DiamondShape()
                    .fill(accentPink.opacity(diamondOpacity))
                    .frame(width: 8, height: 8)
                    .scaleEffect(diamondScale)
            }
            Text("80's Jitterbug")
                .font(.headline)
                .foregroundStyle(accentPink)
            ForEach(0..<2, id: \.self) { _ in
                DiamondShape()
                    .fill(accentPink.opacity(diamondOpacity))
                    .frame(width: 8, height: 8)
                    .scaleEffect(diamondScale)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                diamondOpacity = 1.0
                diamondScale = 1.15
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 24) {
            Text("Bring the Party to Life with 80's Jitterbug Photo Booth!")
                .font(.title2.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(accentPink)
                .padding(.horizontal)

            Text("Retro fun. Instant memories. The ultimate photo booth experience for weddings, birthdays, and corporate events.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(effectiveServiceArea)
                .font(.subheadline)
                .foregroundStyle(.tertiary)

            Button(action: onBook) {
                Text("Book Your Booth")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(accentPink)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .padding(.top, 4)

            // Sample booth visual
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentPink.opacity(0.2))
                    .aspectRatio(4/3, contentMode: .fit)
                    .overlay(Text("📸✨").font(.system(size: 44)))
                Text("Your event. Your memories.")
                    .font(.subheadline)
                    .foregroundStyle(accentPink)
            }
                .padding(.horizontal, 24)
            .padding(.top, 8)
            heroDiamondBranding
        }
        .padding(.vertical, 28)
    }

    private var heroDiamondBranding: some View {
        HStack(spacing: 10) {
            ForEach(0..<4, id: \.self) { _ in
                DiamondShape()
                    .fill(accentPink.opacity(0.7))
                    .frame(width: 10, height: 10)
            }
            Text("80's Jitterbug")
                .font(.headline)
                .foregroundStyle(accentPink)
            ForEach(0..<4, id: \.self) { _ in
                DiamondShape()
                    .fill(accentPink.opacity(0.7))
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.top, 12)
    }

    private var weAreNewSection: some View {
        VStack(spacing: 16) {
            Text("We're New—and Ready for You")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("80's Jitterbug is just getting started. We don't have reviews yet, but we're committed to making your event unforgettable. Book us and be one of our first—we'd love to earn your feedback.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onBook) {
                Text("Request a quote")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(accentPink)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .padding(.vertical, 20)
    }

    private var featuredEventsSection: some View {
        VStack(spacing: 20) {
            Text("Perfect For Every Occasion")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 16) {
                ForEach(featuredEvents, id: \.title) { e in
                    VStack(spacing: 8) {
                        Text(e.icon).font(.system(size: 36))
                        Text(e.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(e.desc)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 28)
    }

    private var packagesSection: some View {
        VStack(spacing: 20) {
            Text("Packages That Pop")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            Text("From intimate gatherings to full-blown parties — we've got you covered.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if loading {
                ProgressView()
                    .padding()
            } else {
                let displayPackages = packages.isEmpty
                    ? [PackagePrice(id: "basic", name: "Basic", price: ""), PackagePrice(id: "standard", name: "Standard", price: ""), PackagePrice(id: "vip", name: "VIP", price: "")]
                    : Array(packages.prefix(3))

                VStack(spacing: 12) {
                    ForEach(displayPackages) { pkg in
                        VStack(spacing: 6) {
                            Text(pkg.name)
                                .font(.headline)
                                .foregroundStyle(accentPink)
                            if !pkg.price.isEmpty {
                                Text(pkg.price.hasPrefix("$") ? pkg.price : "$\(pkg.price)")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                            }
                            Text("Unlimited photos • Props • Digital sharing")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)

                Button(action: { onSelectTab?(1) }) {
                    Text("See All Packages")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(accentPink)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 28)
        .background(Color(.systemGray6).opacity(0.5))
    }

    private var galleryPreviewSection: some View {
        VStack(spacing: 20) {
            Text("From Our Events")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(1...6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accentPink.opacity(0.15))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(Text("📸").font(.system(size: 32)))
                }
            }
            .padding(.horizontal, 20)

            Button(action: { onSelectTab?(2) }) {
                Text("View Full Gallery")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accentPink)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 28)
    }

    private var finalCTASection: some View {
        VStack(spacing: 16) {
            Text("Ready to Bring the Retro Vibes?")
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("Get in touch and we'll help you plan the perfect photo booth experience.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button(action: onBook) {
                    Text("Request a Quote")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(accentPink)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                Button(action: { onSelectTab?(4) }) {
                    Text("Contact Us")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .overlay(Capsule().stroke(accentPink, lineWidth: 2))
                        .foregroundStyle(accentPink)
                }
            }
            .padding(.top, 8)
        }
        .padding(24)
        .padding(.top, 20)
    }
}
