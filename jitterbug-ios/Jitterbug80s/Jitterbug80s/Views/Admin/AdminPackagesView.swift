import SwiftUI

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)

struct AdminPackagesView: View {
    @State private var packages: [PackagePrice] = []
    @State private var loading = true
    @State private var saving = false
    @State private var saveError: String?
    @State private var saveSuccess = false

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            Button {
                                addPackage()
                            } label: {
                                Label("Add package", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .foregroundStyle(accentPink)
                        } header: {
                            Text("Packages & pricing")
                        } footer: {
                            Text("Tap a package to edit name, price, and what's included. Swipe left to delete. Tap Save when done.")
                        }

                        Section("Your packages") {
                            ForEach(packages.indices, id: \.self) { i in
                                NavigationLink {
                                    AdminPackageEditView(package: $packages[i])
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(packages[i].name.isEmpty ? "Package" : packages[i].name)
                                                .font(.headline)
                                            if !packages[i].features.isEmpty {
                                                Text("\(packages[i].features.count) included")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Text(packages[i].price.isEmpty ? "Quote" : (packages[i].price.hasPrefix("$") ? packages[i].price : "$\(packages[i].price)"))
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .onDelete(perform: deletePackages)
                        }
                    }
                }
            }
            .navigationTitle("Packages")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { save() }
                        .disabled(saving || loading)
                }
            }
            .task { load() }
            .alert("Saved", isPresented: $saveSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Packages saved. Customers will see these on the app and website.")
            }
            .alert("Error", isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK", role: .cancel) { saveError = nil }
            } message: {
                Text(saveError ?? "")
            }
        }
    }

    private func addPackage() {
        let newId = "pkg-\(Int(Date().timeIntervalSince1970))"
        packages.append(PackagePrice(id: newId, name: "New Package", price: "", features: []))
    }

    private func deletePackages(at offsets: IndexSet) {
        packages.remove(atOffsets: offsets)
    }

    private func load() {
        loading = true
        Task {
            packages = await PackagesService().getPackages()
            await MainActor.run { loading = false }
        }
    }

    private func save() {
        let valid = packages
            .map { p in
                PackagePrice(
                    id: p.id.trimmingCharacters(in: .whitespaces).isEmpty ? "pkg-\(Int(Date().timeIntervalSince1970))" : p.id,
                    name: p.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Package" : p.name.trimmingCharacters(in: .whitespaces),
                    price: p.price.trimmingCharacters(in: .whitespaces),
                    features: p.features.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                )
            }
            .filter { !$0.name.isEmpty }
        guard !valid.isEmpty else {
            saveError = "Keep at least one package with a name."
            return
        }
        saving = true
        saveError = nil
        Task {
            do {
                try await PackagesService().savePackages(valid)
                await MainActor.run {
                    packages = valid
                    saving = false
                    saveSuccess = true
                }
            } catch {
                await MainActor.run {
                    saveError = error.localizedDescription
                    saving = false
                }
            }
        }
    }
}

// MARK: - Package edit (name, price, what's included)
private struct AdminPackageEditView: View {
    @Binding var package: PackagePrice

    var body: some View {
        Form {
            Section("Package") {
                TextField("Name", text: $package.name)
                TextField("Price", text: $package.price)
                    .keyboardType(.decimalPad)
            }
            Section {
                ForEach(Array(package.features.enumerated()), id: \.offset) { index, _ in
                    TextField("What's included", text: binding(for: index))
                }
                .onDelete(perform: deleteFeatures)
                Button {
                    var p = package
                    p.features.append("")
                    package = p
                } label: {
                    Label("Add what's included", systemImage: "plus.circle")
                        .foregroundStyle(accentPink)
                }
            } header: {
                Text("What's included")
            } footer: {
                Text("These lines appear under the package for customers (e.g. \"3 hours of booth time\", \"Unlimited prints\"). Leave empty to use default text by package name.")
            }
        }
        .navigationTitle(package.name.isEmpty ? "Edit package" : package.name)
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { package.features.indices.contains(index) ? package.features[index] : "" },
            set: { newValue in
                var p = package
                if p.features.indices.contains(index) {
                    p.features[index] = newValue
                    package = p
                }
            }
        )
    }

    private func deleteFeatures(at offsets: IndexSet) {
        var p = package
        p.features.remove(atOffsets: offsets)
        package = p
    }
}
