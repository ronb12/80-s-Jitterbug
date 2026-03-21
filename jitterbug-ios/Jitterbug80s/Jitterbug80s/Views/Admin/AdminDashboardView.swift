import SwiftUI

private let accentPink = Color(red: 0.93, green: 0.28, blue: 0.6)

struct AdminDashboardView: View {
    @State private var bookings: [Booking] = []
    @State private var loading = true
    @State private var ownerName: String?
    @Binding var selectedTab: Int
    var onViewAsCustomer: (() -> Void)?
    var onLogout: (() -> Void)?
    /// When set (e.g. "Apple" for demo account), used instead of owner name for welcome.
    var preferredGreetingName: String?

    private var welcomeName: String? {
        if let preferred = preferredGreetingName, !preferred.isEmpty {
            return preferred
        }
        if let name = ownerName, !name.isEmpty {
            return firstName(from: name)
        }
        return nil
    }

    private var pendingCount: Int { bookings.filter { $0.status == .pending }.count }
    private var nextBooking: Booking? {
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        return bookings
            .filter { $0.status == .confirmed && $0.eventDate >= today }
            .sorted { $0.eventDate < $1.eventDate }
            .first
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let onViewAsCustomer = onViewAsCustomer {
                        Button {
                            onViewAsCustomer()
                        } label: {
                            Label("View as customer", systemImage: "person.crop.circle")
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(accentPink)
                    }
                    Text("See the app as customers do, without logging out.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Switch to customer view")
                }
                if let name = welcomeName {
                    Section {
                        Text("Welcome, \(name)")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(accentPink)
                    }
                }
                Section {
                    if loading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundStyle(accentPink)
                                Text("\(pendingCount) pending request\(pendingCount == 1 ? "" : "s")")
                                    .font(.headline)
                            }
                            if let next = nextBooking {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(.secondary)
                                    Text("Next: \(next.eventDate) — \(next.eventType) — \(next.name)")
                                        .font(.subheadline)
                                }
                            }
                            Button {
                                selectedTab = 1
                            } label: {
                                Label("Add booking", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .foregroundStyle(accentPink)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } header: {
                    Text("Overview")
                }

                Section("Quick links") {
                    row("Bookings", icon: "list.bullet") { selectedTab = 1 }
                    row("Packages", icon: "dollarsign.circle") { selectedTab = 2 }
                    row("Event types", icon: "tag") { selectedTab = 3 }
                    row("Gallery", icon: "photo") { selectedTab = 4 }
                    row("Documents", icon: "doc.text") { selectedTab = 5 }
                    row("Settings", icon: "gearshape") { selectedTab = 6 }
                }

            }
            .navigationTitle("Admin")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let onViewAsCustomer = onViewAsCustomer {
                        Button {
                            onViewAsCustomer()
                        } label: {
                            Label("View as customer", systemImage: "person.crop.circle")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if let onLogout = onLogout {
                        Button("Log out", action: onLogout)
                    }
                }
            }
            .task { await load() }
        }
    }

    private func firstName(from fullName: String) -> String {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true).first.map(String.init)
        return first ?? trimmed
    }

    private func row(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(accentPink)
                    .frame(width: 28, alignment: .center)
                Text(title)
            }
        }
    }

    private func load() async {
        loading = true
        ownerName = (await SettingsService().getSiteSettings()).ownerName
        do {
            bookings = try await BookingService().listBookings()
        } catch {
            bookings = []
        }
        loading = false
    }
}
