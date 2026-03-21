import SwiftUI

private let adminTipsKey = "adminTipsShown"
private let tabAccent = Color(red: 0.93, green: 0.28, blue: 0.6)

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
                .tabItem {
                    Label {
                        Text("Gallery")
                    } icon: {
                        Image("IconGallery")
                            .renderingMode(.original)
                    }
                }
                .tag(4)
            AdminDocumentsView()
                .tabItem { Label("Documents", systemImage: "doc.text") }
                .tag(5)
            AdminSettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(6)
        }
        .tint(tabAccent)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarLeading) {
                viewAsCustomerToolbarButton
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Log out", action: onLogout)
            }
            #else
            ToolbarItem(placement: .navigation) {
                viewAsCustomerToolbarButton
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Log out", action: onLogout)
            }
            #endif
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

    @ViewBuilder
    private var viewAsCustomerToolbarButton: some View {
        if let onViewAsCustomer = onViewAsCustomer {
            Button {
                onViewAsCustomer()
            } label: {
                Label {
                    Text("View as customer")
                } icon: {
                    Image(systemName: "person.crop.circle")
                        .symbolRenderingMode(.multicolor)
                }
            }
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
