//
//  Jitterbug80sMacApp.swift
//  Jitterbug80sMac — macOS build; same bundle ID as iOS (com.bradleyvirtualsolutions.Jitterbug80s).
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
                .frame(minWidth: 720, minHeight: 640)
        }
        .defaultSize(width: 980, height: 820)
        .commands {
            JitterbugMacApplicationCommands()
        }
    }
}
