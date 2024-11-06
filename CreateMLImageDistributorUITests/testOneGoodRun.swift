//
//  testOneGoodRun.swift
//  CreateMLImageDistributorUITests
//
//  Created by alanrick on 05.11.24.
//

import XCTest

final class testOneGoodRun: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testChangeTheMaximumImagesPerFolder() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
  
        let labelMaximagesineachfolderTextField = app.staticTexts["labelMaxImagesInEachFolder"]
        XCTAssert(labelMaximagesineachfolderTextField.exists, "No label field for the max count of images")
        
        let maximagesineachfolderTextField = app.textFields["maxImagesInEachFolder"]
        XCTAssert(maximagesineachfolderTextField.exists, "No field for inputing the max count of images")
        
        maximagesineachfolderTextField.click()
        maximagesineachfolderTextField.typeKey(.delete, modifierFlags:[])
        maximagesineachfolderTextField.typeText("1\r")
        
    //    XCTAssertTrue(maximagesineachfolderTextField.value == "1001")
        
        
        
    }

    
}
