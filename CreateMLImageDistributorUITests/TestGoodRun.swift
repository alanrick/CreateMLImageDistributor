//
//  TestGoodRun.swift
//  CreateMLImageDistributor
//
//  Created by alanrick on 05.11.24.
//


import XCTest
@testable import CreateMLImageDistributor

final class TestGoodRun: XCTestCase {
    
    var app: XCUIApplication!
    var viewModel: AppEnvironment!
    
   

    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        viewModel = AppEnvironment()
        app.launchArguments = ["-UITest"]
        app.launch()
        
    }
    
    override func tearDownWithError() throws {
        // Clean up code that should run after every test
        viewModel = nil
        app = nil
    }
    
    
    
    @MainActor @Test("Test Column Name Extraction",
          arguments: [("/FewCards.csv", "FewCardsPhotos", 2,
                       ["Photoname", "Suit"]),
                      
                      ("/FewCards.csv", "FewCardsPhotos", 3,
                       ["Photoname", "Rank", "Suit"])])
    
    
    
    func testGoodRun(arg1: String, arg2: String, arg3: Int, arg4: [String]) throws {
        // UI tests must launch the application that they test.
        //        let app = XCUIApplication()
        //        app.launch()
        
        Thread.sleep(forTimeInterval: 5.0)
        
        // generate the complete paths of all the paths
        let compSpreadsheetDir = generateFilePath(arg1)
        try #require(compSpreadsheetDir != nil)
        
        let imageSourceDir = generateFilePath(arg2)
        try #require(imageSourceDir != nil)
        
//        let imageTargetDir = generateFilePath("")
//        try #require(imageTargetDir != nil)
        
        
        // Set the paths
        viewModel.identifyCSVDirectoryIntent(compSpreadsheetDir!)
        viewModel.identifyPhotoSourceDirectoryIntent(imageSourceDir!)
//        viewModel.identifyPhotoRootDirectoryIntent(imageTargetDir!)
        
        // Verify the paths in the UI
        let CSVPath = app.staticTexts["CSV picked"]
        XCTAssertTrue(CSVPath.exists)
     //   XCTAssertEqual(CSVPath.label, compSpreadsheetDir!)
        
        // Verify the paths in the UI
        let ImageSourcePath = app.staticTexts["Image source picked"]
        XCTAssertTrue(ImageSourcePath.exists)
     //   XCTAssertEqual(ImageSourcePath.label, imageSourceDir!)
        
        // Using the accessibility identifier you've set
            let columnText = app.staticTexts["ColumnName-Photoname"]
            
            // Verify the element exists and has the correct text
            XCTAssertTrue(columnText.exists)
            XCTAssertEqual(columnText.label, "Photoname")
        
        
    }
    
    func generateFilePath(_ filename: String)  -> URL? {
        guard var testDir = ProcessInfo.processInfo.environment["SPREADSHEET_PATH"] else {
            print("Environment variable SPREADSHEET_PATH not set")
            return nil
            
        }
        testDir.append(filename)
        return URL(fileURLWithPath: testDir)
    }
}
