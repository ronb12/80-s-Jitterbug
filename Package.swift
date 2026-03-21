// swift-tools-version: 5.9
// For Swift LSP / IDE only: resolves types (AuthService, AdminLoginView, etc.) when workspace root is "80's Jitterbug".
// Build and run the app from Xcode: open jitterbug-ios/Jitterbug80s/Jitterbug80s.xcodeproj
import PackageDescription

let package = Package(
    name: "Jitterbug80s",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Jitterbug80s", targets: ["Jitterbug80s"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
    ],
    targets: [
        .target(
            name: "Jitterbug80s",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
            ],
            path: "jitterbug-ios/Jitterbug80s/Jitterbug80s",
            exclude: [
                "Assets.xcassets",
                "Info.plist",
            ]
        ),
    ]
)
