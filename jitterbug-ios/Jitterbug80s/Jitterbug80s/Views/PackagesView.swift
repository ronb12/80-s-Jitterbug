import SwiftUI

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)

private let defaultFeatures: [String: [String]] = [
    "Basic": [
        "3 hours of booth time",
        "Unlimited digital photos",
        "Retro backdrop & basic props",
        "Online gallery for guests",
        "Setup & teardown included",
    ],
    "Standard": [
        "4 hours of booth time",
        "Unlimited prints + digital",
        "Neon backdrop & full prop kit",
        "Custom branding on prints",
        "Online gallery + same-day share",
        "Dedicated attendant",
    ],
    "VIP": [
        "6 hours of booth time",
        "Unlimited prints + digital",
        "Premium neon setup & green screen option",
        "Custom backdrop & branding",
        "Priority booking & flexible timing",
        "Full prop kit + attendant",
        "Extended online gallery access",
    ],
]

struct PackagesView: View {
    var onRequestQuote: (() -> Void)?
    @State private var packages: [PackagePrice] = []
    @State private var loading = true

    private func features(for pkg: PackagePrice) -> [String] {
        if !pkg.features.isEmpty { return pkg.features }
        return defaultFeatures[pkg.name] ?? ["Unlimited photos", "Retro backdrop & props", "Setup & teardown included"]
    }

    private func displayPackages() -> [(pkg: PackagePrice, highlighted: Bool)] {
        if packages.isEmpty {
            return [
                (PackagePrice(id: "basic", name: "Basic", price: "$299"), false),
                (PackagePrice(id: "standard", name: "Standard", price: "$449"), true),
                (PackagePrice(id: "vip", name: "VIP", price: "$649"), false),
            ]
        }
        return packages.enumerated().map { i, p in
            (p, i == 1 && packages.count >= 2)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Hero
                            VStack(spacing: 12) {
                                Text("Choose the package that fits your event. All include our signature 80s vibe, unlimited fun, and professional service.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Text("50% deposit to secure your date; balance due 7 days before the event.")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 8)

                            ForEach(displayPackages(), id: \.pkg.id) { item in
                                packageCard(pkg: item.pkg, highlighted: item.highlighted, featureList: features(for: item.pkg))
                            }

                            // Footer CTA
                            VStack(spacing: 12) {
                                Text("Prices may vary by date, location, and add-ons. We'll confirm your final quote when you request a booking.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                Button(action: { onRequestQuote?() }) {
                                    Text("Get a Custom Quote")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(accentPink)
                                        .foregroundStyle(.white)
                                        .clipShape(Capsule())
                                }
                                .padding(.horizontal, 32)
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Packages & Pricing")
            .task {
                packages = await PackagesService().getPackages()
                loading = false
            }
        }
    }

    private func packageCard(pkg: PackagePrice, highlighted: Bool, featureList: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if highlighted {
                Text("Most popular")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(accentPink)
                    .clipShape(Capsule())
            }

            Text(pkg.name)
                .font(.title2.bold())
                .foregroundStyle(accentPink)
            Text(pkg.price.isEmpty ? "Quote" : (pkg.price.hasPrefix("$") ? pkg.price : "$\(pkg.price)"))
                .font(.title3.bold())
            Text(highlighted ? "Our most popular package." : "Perfect for your event. Unlimited fun, professional setup.")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(featureList, id: \.self) { feature in
                    HStack(alignment: .top, spacing: 6) {
                        Text("✓")
                            .foregroundStyle(accentPink)
                        Text(feature)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.top, 4)

            Button(action: { onRequestQuote?() }) {
                Text("Request quote")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(highlighted ? accentPink : Color.clear)
                    .foregroundStyle(highlighted ? .white : accentPink)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(accentPink, lineWidth: highlighted ? 0 : 2))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(highlighted ? accentPink.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}
