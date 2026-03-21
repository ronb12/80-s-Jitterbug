import SwiftUI

private let adminTipsKey = "adminTipsShown"

struct AdminTabView: View {
    @EnvironmentObject var auth: AuthService
    var onLogout: () -> Void
    var onViewAsCustomer: (() -> Void)?
    /// When set, overrides greeting; else uses auth.adminGreetingName ("Apple" if email contains "apple").
    var preferredGreetingName: String?
    @State private var selectedTab = 0
    @State private var showAdminTips = false

    var body: some View {
        TabView(selection: $selectedTab) {
            AdminDashboardView(selectedTab: $selectedTab, onViewAsCustomer: onViewAsCustomer, onLogout: onLogout, preferredGreetingName: preferredGreetingName ?? auth.adminGreetingName)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }
                .tag(0)
            AdminBookingsView()
                .tabItem { Label("Bookings", systemImage: "list.bullet") }
                .tag(1)
            AdminPackagesView()
                .tabItem { Label("Packages", systemImage: "dollarsign.circle") }
                .tag(2)
            AdminEventTypesView()
                .tabItem { Label("Event types", systemImage: "tag") }
                .tag(3)
            AdminGalleryView()
                .tabItem { Label("Gallery", systemImage: "photo") }
                .tag(4)
            AdminDocumentsView()
                .tabItem { Label("Documents", systemImage: "doc.text") }
                .tag(5)
            AdminSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(6)
        }
        .tint(Color(red: 0.93, green: 0.28, blue: 0.6))
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
                Button("Log out", action: onLogout)
            }
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: adminTipsKey) {
                showAdminTips = true
            }
        }
        .sheet(isPresented: $showAdminTips) {
            AdminTipsSheet(onDismiss: {
                UserDefaults.standard.set(true, forKey: adminTipsKey)
                showAdminTips = false
            })
        }
    }
}

struct AdminTipsSheet: View {
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Swipe left on a package or event type row to delete it. Tap Save after editing.")
                    Text("In Bookings, tap a row for details. Use Print contract or Print photo release to print or save as PDF.")
                    Text("Dashboard shows pending count and next event. Use Quick links to jump to any section.")
                } header: {
                    Text("Quick tips")
                }
            }
            .navigationTitle("Admin tips")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Got it", action: onDismiss)
                }
            }
        }
    }
}
