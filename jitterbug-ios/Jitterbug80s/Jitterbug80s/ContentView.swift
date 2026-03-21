//
//  ContentView.swift
//  Jitterbug80s
//

import SwiftUI

/// Must match `appearanceModeKey` in `MoreView`.
private let appearanceModeKey = "appearanceMode"

struct ContentView: View {
    @EnvironmentObject private var auth: AuthService
    @AppStorage(appearanceModeKey) private var appearanceMode = "system"
    @AppStorage("hasPassedLanding") private var hasPassedLanding = false
    @State private var showAdminLogin = false
    @State private var showAdminHub = false

    var body: some View {
        Group {
            if !hasPassedLanding {
                LandingView {
                    hasPassedLanding = true
                }
            } else {
                MainTabView(
                    onOpenAdmin: openAdmin,
                    isAdmin: auth.isAdmin
                )
            }
        }
        .preferredColorScheme(resolvedColorScheme)
        .sheet(isPresented: $showAdminLogin) {
            AdminLoginView(
                onDismiss: { showAdminLogin = false },
                onSuccess: {
                    showAdminLogin = false
                    showAdminHub = true
                }
            )
            .environmentObject(auth)
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showAdminHub) {
            adminHubContent
        }
        #else
        .sheet(isPresented: $showAdminHub) {
            adminHubContent
        }
        #endif
    }

    @ViewBuilder
    private var adminHubContent: some View {
        AdminTabView(
            onLogout: {
                showAdminHub = false
                Task { try? await auth.signOut() }
            },
            onViewAsCustomer: {
                showAdminHub = false
            }
        )
        .environmentObject(auth)
    }

    private func openAdmin() {
        if auth.isAdmin {
            showAdminHub = true
        } else {
            showAdminLogin = true
        }
    }

    private var resolvedColorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
