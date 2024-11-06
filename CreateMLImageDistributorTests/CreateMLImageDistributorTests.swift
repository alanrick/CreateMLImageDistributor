//
//  CreateMLImageDistributorTests.swift
//  CreateMLImageDistributorTests
//
//  Created by Alanrick on 02.11.24.
//

import Testing
import Foundation
@testable import CreateMLImageDistributor

@Suite(.serialized)
struct CreateMLImageDistributorTests {

    @Test("Test Column Name Extraction",
          arguments: [("/FewCards.csv", 3,
                            ["Photoname", "Rank", "Suit"]),
                      
                      ("/ManyCards.csv", 6,
                            ["class index", "filepaths", "labels", "card type", "Suit", "data set"] )])
    
    func testColumnNames(arg1: String, arg2: Int, arg3: [String]) async throws {
        
        // generate the complete path
        let compSpreadsheetDir = generateFilePath(arg1)
        try #require(compSpreadsheetDir != nil)
        
        let columns:  [CsvColumn] = try doIdentifyColumns(csv: compSpreadsheetDir)
        guard  columns.count > 0 else {
            print("Failed to identify columns")
            return
        }
        // Check the count of columns identified
        try #require(columns.count == arg2)
        
        // Check the column names agree
        for column in columns {
            #expect(arg3.contains(column.colName))
        }
    }
    
    @Test("Testing bad CSV files",
          arguments: ["/DoesntExist.csv",
                      "/FewCardsNoData.csv",
                      "/FewCardsNoPhotos.csv"])
    
    func testBadCSVFiles(arg1: String) async throws {
        var columns: [CsvColumn]
        
        let compSpreadsheetDir = generateFilePath(arg1)
        try #require(compSpreadsheetDir != nil)

        
        do { columns =  try doIdentifyColumns(csv: compSpreadsheetDir)
        } catch {
            print("Failed to identify bad file")
            columns = []
        }
        
        guard  columns.count == 0 else {
            print("Failed to identify bad file")
            return
        }
        #expect(columns.count == 0)
    }

    @Test("Test that photos are in the directory",
          arguments: [("/fewCardsPhotos", "1club.jpg", true),
                      ("/fewCardsPhotos", "joker.jpg", false)])
    
    func testVerifyFolderHasPhotosWorks(arg1: String, arg2: String, arg3: Bool) async throws {
        
        
        let testPath = generateFilePath(arg1)
        try #require(testPath != nil)
        
         let result = doCheckImageSourceHasImages(testPath!, exampleFile: arg2)
        #expect(result == arg3)
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
        
       

