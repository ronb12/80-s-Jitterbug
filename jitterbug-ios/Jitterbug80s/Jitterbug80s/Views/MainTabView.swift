import SwiftUI

struct MainTabView: View {
    var onOpenAdmin: () -> Void
    var isAdmin: Bool = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(onBook: { selectedTab = 3 }, onSelectTab: { selectedTab = $0 })
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            PackagesView(onRequestQuote: { selectedTab = 3 })
                .tabItem { Label("Packages", systemImage: "dollarsign.circle.fill") }
                .tag(1)
            GalleryView(onBook: { selectedTab = 3 })
                .tabItem { Label("Gallery", systemImage: "photo.fill") }
                .tag(2)
            BookView()
                .tabItem { Label("Book", systemImage: "calendar.badge.plus") }
                .tag(3)
            MoreView(onOpenAdmin: onOpenAdmin, isAdmin: isAdmin, onSelectTab: { selectedTab = $0 })
                .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
                .tag(4)
        }
        .tint(Color(red: 0.93, green: 0.28, blue: 0.6))
    }
}
