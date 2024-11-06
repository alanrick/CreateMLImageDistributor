//
//  CreateMLImageDistributorUITests.swift
//  CreateMLImageDistributorUITests
//
//  Created by Alanrick on 02.11.24.
//

import XCTest


final class CreateMLImageDistributorUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITest"]
        app.launch()
        
    }
    
    override func tearDownWithError() throws {
        // Clean up code that should run after every test
        app = nil
    }
        
    func testInitialDisplayCorrect() throws {
        // UI tests must launch the application that they test.
        //        let app = XCUIApplication()
        //        app.launch()
        
        Thread.sleep(forTimeInterval: 5.0)
        
        // Given: Locate and click the Distribute button
        let distributeButton = app.buttons["DistributeButton"]
        XCTAssertTrue(distributeButton.exists, "Distribute button should exist")
        
        // Given: Locate and click the Delete button
        let deleteButton = app.buttons["DeleteButton"]
        XCTAssertTrue(deleteButton.exists, "Delete button should exist")
        
    
        
        // Both buttons should be disabled initially.
        deleteButton.click()
        XCTAssertFalse(deleteButton.isEnabled, "Delete button should be disabled")
        
        distributeButton.click()
        XCTAssertFalse(distributeButton.isEnabled, "Distribute button should be disabled")
        
        // A reason for the distribute button being disabled should appear within 5 seconds.
        // Get the actual text content
        let exists = app.staticTexts["reasonForDisabled"]
        XCTAssertTrue(exists.waitForExistence(timeout: 5), "Status text should appear within 5 seconds")
        
        // Get the actual text content
        let statusText = app.staticTexts["reasonForDisabled"]
        XCTAssertTrue(statusText.waitForExistence(timeout: 5), "Status text should exist")
        
        let statusTextValue = exists.value as? String
        
        
        // Verify it's not empty and filled with correct content
        XCTAssertFalse((statusTextValue == nil), "Status text should not be empty")
        
        // MARK: - Temporary: Needs to be made language-independent
        XCTAssertTrue((statusTextValue == "Not Started"), "Status text be - Not Started")
        
    }
    
    
    
    
        @MainActor
        func testLaunchPerformance() throws {
            if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
                // This measures how long it takes to launch your application.
                measure(metrics: [XCTApplicationLaunchMetric()]) {
                    XCUIApplication().launch()
                }
            }
        }
    
}


final class DeleteButtonUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testDeleteButtonExists() throws {
        // Look for the button using its accessibility identifier
        let deleteButton = app.buttons["DeleteButton"]
        
        // Verify the button exists
        XCTAssertTrue(deleteButton.exists, "Delete button should be present in the UI")
        
        // Optional: Verify the button is showing (visible on screen)
        XCTAssertTrue(deleteButton.isHittable, "Delete button should be hittable")
    }
    
    func testDeleteButtonInitialState() throws {
        let deleteButton = app.buttons["DeleteButton"]
        
        // If you want to test the initial disabled state
        // (assuming fullGoalDirExists is false at launch)
        XCTAssertFalse(deleteButton.isEnabled, "Delete button should be disabled initially")
    }
}
