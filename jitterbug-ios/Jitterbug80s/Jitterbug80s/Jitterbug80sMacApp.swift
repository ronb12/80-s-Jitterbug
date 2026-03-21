//
//  Jitterbug80sMacApp.swift
//  Jitterbug80sMac (Mac Catalyst) — same UI as iOS; separate @main from Jitterbug80sApp.swift.
//

import SwiftUI

@main
struct Jitterbug80sMacApp: App {
    #if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    @StateObject private var auth = AuthService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
        }
    }
}
