//
//  Jitterbug80sUITests.swift
//  Jitterbug80sUITests
//
//  Created by Ronell J Bradley on 3/12/26.
//

import XCTest

final class Jitterbug80sUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    /// Crash test: launch app and exercise main flows. Fails if any screen crashes.
    @MainActor
    func testCrashTestMainFlows() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10), "App should launch and stay in foreground")

        // Dismiss landing if present (tap "Enter" or similar)
        let enterButton = app.buttons["Enter"]
        if enterButton.waitForExistence(timeout: 3) {
            enterButton.tap()
        }

        // Tab bar: Home (0), Packages (1), Gallery (2), Book (3), More (4)
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "Tab bar should appear")

        // Tap each tab to ensure no crash
        let packagesTab = app.tabBars.buttons["Packages"]
        if packagesTab.waitForExistence(timeout: 2) { packagesTab.tap(); _ = app.staticTexts.firstMatch.waitForExistence(timeout: 2) }

        let galleryTab = app.tabBars.buttons["Gallery"]
        if galleryTab.waitForExistence(timeout: 2) { galleryTab.tap(); _ = app.staticTexts.firstMatch.waitForExistence(timeout: 2) }

        let bookTab = app.tabBars.buttons["Book"]
        if bookTab.waitForExistence(timeout: 2) { bookTab.tap(); _ = app.staticTexts.firstMatch.waitForExistence(timeout: 2) }

        let moreTab = app.tabBars.buttons["More"]
        XCTAssertTrue(moreTab.waitForExistence(timeout: 2), "More tab should exist")
        moreTab.tap()

        // More: open Booking lookup (stress BookingLookupView)
        let lookupText = app.staticTexts["Booking lookup"]
        if lookupText.waitForExistence(timeout: 3) {
            lookupText.tap()
            _ = app.navigationBars["Booking Lookup"].waitForExistence(timeout: 3)
            app.navigationBars.buttons.element(boundBy: 0).tap() // Back
        }

        // More: open FAQ
        let faqText = app.staticTexts["FAQ"]
        if faqText.waitForExistence(timeout: 2) {
            faqText.tap()
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }

        // App still in foreground = no crash
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2), "App should not have crashed")
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
