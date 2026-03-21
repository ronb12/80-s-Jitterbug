//
//  Jitterbug80sApp.swift
//  Jitterbug80s
//
//  Created by Ronell J Bradley on 3/12/26.
//

import SwiftUI

@main
struct Jitterbug80sApp: App {
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
