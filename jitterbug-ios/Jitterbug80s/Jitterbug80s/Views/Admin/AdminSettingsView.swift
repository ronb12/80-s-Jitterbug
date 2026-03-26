import SwiftUI

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)

private struct ExportableFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct AdminSettingsView: View {
    @State private var settings: SiteSettings = .default
    @State private var loading = true
    @State private var saving = false
    @State private var error: String?
    @State private var success = false
    @State private var exportItem: ExportableFile?
    @State private var showStripeKeys = false

    var body: some View {
        NavigationStack {
            settingsMainContent
                .navigationTitle("Settings")
                .task { await load() }
                .alert("Saved", isPresented: $success) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Settings saved. They will appear on the site and in the app.")
                }
                .sheet(item: $exportItem) { item in
                    ExportedFileShareSheet(exportURL: item.url, onDismiss: { exportItem = nil })
                }
        }
        .jitterbugMacNavigationRootFill()
    }

    @ViewBuilder
    private var settingsMainContent: some View {
        if loading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            settingsForm
        }
    }

    @ViewBuilder
    private var settingsForm: some View {
        Form {
                        Section {
                            TextField("Owner name", text: $settings.ownerName)
                            TextField("Contact email", text: $settings.contactEmail)
                                #if os(iOS)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                #endif
                            TextField("Contact phone", text: $settings.contactPhone)
                                #if os(iOS)
                                .keyboardType(.phonePad)
                                #endif
                        } header: {
                            Text("Contact")
                        } footer: {
                            Text("Owner name and contact details are shown on Contact, in the app, and on printed contracts.")
                        }

                        Section {
                            #if os(iOS)
                            TextField("Service area", text: $settings.serviceArea, axis: .vertical)
                                .lineLimit(2...6)
                            #else
                            TextField("Service area", text: $settings.serviceArea)
                                .lineLimit(6)
                            #endif
                        } header: {
                            Text("Service area")
                        } footer: {
                            Text("Shown on Home and About (e.g. \"Augusta, GA and surrounding areas.\").")
                        }

                        Section {
                            Toggle("Enable “Pay deposit” after booking", isOn: $settings.stripeCheckoutEnabled)
                            TextField("Public site URL (Stripe redirects)", text: $settings.stripePublicBaseUrl)
                                #if os(iOS)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.URL)
                                #endif
                            Stepper(value: $settings.stripeDepositCents, in: 50...500_000, step: 50) {
                                Text("Deposit: \(formatDepositForDisplay(settings.stripeDepositCents))")
                            }
                            Picker("Stripe mode (display)", selection: $settings.stripeMode) {
                                Text("Test").tag("test")
                                Text("Live").tag("live")
                            }
                            Toggle("Show Stripe keys while editing", isOn: $showStripeKeys)
                            if showStripeKeys {
                                TextField("Publishable key — test (pk_test_…)", text: $settings.stripePublishableKeyTest)
                                    #if os(iOS)
                                    .textInputAutocapitalization(.never)
                                    #endif
                                    .font(.system(.body, design: .monospaced))
                                TextField("Publishable key — live (pk_live_…)", text: $settings.stripePublishableKeyLive)
                                    #if os(iOS)
                                    .textInputAutocapitalization(.never)
                                    #endif
                                    .font(.system(.body, design: .monospaced))
                            } else {
                                SecureField("Publishable key — test (pk_test_…)", text: $settings.stripePublishableKeyTest)
                                    #if os(iOS)
                                    .textInputAutocapitalization(.never)
                                    #endif
                                    .font(.system(.body, design: .monospaced))
                                SecureField("Publishable key — live (pk_live_…)", text: $settings.stripePublishableKeyLive)
                                    #if os(iOS)
                                    .textInputAutocapitalization(.never)
                                    #endif
                                    .font(.system(.body, design: .monospaced))
                            }
                        } header: {
                            Text("Stripe checkout")
                        } footer: {
                            Text(
                                "Deposit stepper changes the amount by $0.50 each tap. Never put Stripe secret keys (sk_…) or webhook secrets (whsec_…) here — settings/site is publicly readable. Set STRIPE_SECRET_KEY and STRIPE_WEBHOOK_SECRET as Firebase Function secrets (see STRIPE-SETUP.md in jitterbug-site). Publishable keys (pk_…) are safe to store here. The iOS app needs the matching pk_… for in-app Payment Sheet; the website can keep using hosted Checkout."
                            )
                        }

                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How to find test and live publishable keys")
                                    .font(.subheadline.weight(.semibold))
                                Group {
                                    Text("1. Sign in at stripe.com and open the Stripe Dashboard.")
                                    Text("2. Open Developers (top right) → API keys.")
                                    Text("3. Use the Test mode switch (top of the dashboard): when Test mode is ON you see Publishable key pk_test_…; turn Test mode OFF for live to see pk_live_…. Copy each into the matching field above.")
                                    Text("4. Under Standard keys, copy only the Publishable key—not the Secret key (sk_…).")
                                    Text("5. Secret keys (sk_test_ / sk_live_) and webhook secrets (whsec_…) never belong here. Set them with Firebase: firebase functions:secrets:set (see STRIPE-SETUP.md in jitterbug-site).")
                                }
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                                VStack(alignment: .leading, spacing: 8) {
                                    Link(destination: URL(string: "https://dashboard.stripe.com/test/apikeys")!) {
                                        Label {
                                            Text("Open API keys (test mode)")
                                        } icon: {
                                            Image(systemName: "arrow.up.right.square")
                                                .symbolRenderingMode(.multicolor)
                                        }
                                    }
                                    Link(destination: URL(string: "https://dashboard.stripe.com/apikeys")!) {
                                        Label {
                                            Text("Open API keys (live mode)")
                                        } icon: {
                                            Image(systemName: "arrow.up.right.square")
                                                .symbolRenderingMode(.multicolor)
                                        }
                                    }
                                }
                                .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        } header: {
                            Text("Stripe key help")
                        } footer: {
                            Text("Links open in Safari. If a key doesn’t match (test vs live), toggle Test mode in Stripe and copy again.")
                        }

                        Section {
                            Button("Export settings") {
                                exportSettings()
                            }
                            .frame(maxWidth: .infinity)
                        } header: {
                            Text("Backup")
                        } footer: {
                            Text("Save a copy of your settings (and optionally packages and event types) as JSON.")
                        }

                        if let err = error {
                            Section {
                                Text(err)
                                    .foregroundStyle(.red)
                            }
                        }

                        Section {
                            Button("Save settings") {
                                save()
                            }
                            .disabled(saving)
                            .frame(maxWidth: .infinity)
                        }
        }
        #if os(macOS)
        .controlSize(.small)
        #endif
        .jitterbugMacInsetLeadingScrollableForm()
    }

    /// Whole dollars as `$50`; otherwise `$50.50` (stepper still changes by 50¢).
    private func formatDepositForDisplay(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        if cents % 100 == 0 {
            return String(format: "$%.0f", dollars)
        }
        return String(format: "$%.2f", dollars)
    }

    private func exportSettings() {
        Task {
            var payload: [String: Any] = [
                "exportedAt": ISO8601DateFormatter().string(from: Date()),
                "ownerName": settings.ownerName,
                "contactEmail": settings.contactEmail,
                "contactPhone": settings.contactPhone,
                "serviceArea": settings.serviceArea,
                "stripePublicBaseUrl": settings.stripePublicBaseUrl,
                "stripeCheckoutEnabled": settings.stripeCheckoutEnabled,
                "stripeDepositCents": settings.stripeDepositCents,
                "stripePublishableKeyTest": settings.stripePublishableKeyTest,
                "stripePublishableKeyLive": settings.stripePublishableKeyLive,
                "stripeMode": settings.stripeMode,
            ]
            let packages = await PackagesService().getPackages()
            payload["packages"] = packages.map { ["id": $0.id, "name": $0.name, "price": $0.price] }
            payload["eventTypes"] = await EventTypesService().getEventTypes()
            guard let data = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted) else { return }
            let name = "jitterbug-settings-\(ISO8601DateFormatter().string(from: Date()).prefix(10)).json"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            try? data.write(to: url)
            await MainActor.run { exportItem = ExportableFile(url: url) }
        }
    }

    private func load() async {
        loading = true
        error = nil
        settings = await SettingsService().getSiteSettings()
        loading = false
    }

    private func save() {
        saving = true
        error = nil
        Task {
            do {
                try await SettingsService().updateSiteSettings(settings)
                await MainActor.run {
                    saving = false
                    success = true
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    saving = false
                }
            }
        }
    }
}
