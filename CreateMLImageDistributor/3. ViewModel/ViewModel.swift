//
//  ViewModel.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

@Observable
class AppEnvironment {
    var trainData: AppModel
    
    init() {
        self.trainData = AppModel()
        if let testPath = CommandLine.arguments.firstIndex(of: "--test-csv-path").map({ CommandLine.arguments[$0 + 1] }) {
            let testURL = URL(fileURLWithPath: testPath)
            // Assuming you have access to your AppEnvironment instance
            self.trainData.identifyCSVDirectory(testURL)
        }
    }
    
    
    // MARK: - Intent
    
    @MainActor
    func updatePurposeIntent(_ purpose: ColumnPurpose, _ colName: String)  -> Void{
        trainData.updatePurpose(purpose, colName: colName)
    }
    
    @MainActor
    func identifyCSVDirectoryIntent(_ url: URL)  {
        self.trainData.reset()
        trainData.identifyCSVDirectory(url)
    }
    
    func identifyImageRootDirectoryIntent(_ url: URL)  {
        self.trainData.reset()
        trainData.identifyImageTargetDirectory(url)
    }
    
    func identifyImageSourceDirectoryIntent(_ url: URL)  {
        self.trainData.reset()
        trainData.identifyImageSourceDirectory(url)
    }
    

    
    @MainActor
    func DeleteRootDirectoryIntent() async throws -> Void {
        self.trainData.reset()
        do {
            try await trainData.deleteRootDirectory()
        }
        return
    }
    
    
    func identifyColumnNamesIntent(){
        trainData.identifyColumns()
    }
    
    func updateCategoryNameIntent(_ id: UUID, to newCategoryName: String) {
        trainData.updateCategoryName(id, to: newCategoryName)
    }
    
     func updatePurposeIntent(_ newPurpose: ColumnPurpose, colName: String) {
         trainData.updatePurpose(newPurpose, colName: colName)
    }
    
    @MainActor
    func findUniquePotsIntent() async  -> Void {
        trainData.createUniquePots()
        do {
            try await trainData.getCategoryValues()
        } catch let error {
            // MARK: - Improve by throwing
            print("Error finding unique pots : \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func createDirectoriesIntent() throws -> Void {
        do { try trainData.CreateDirectories()
        }
    }
    
    @MainActor
    func distributeImagesIntent() async throws -> Void  {
        
        do {   try await trainData.distributeImages()
            self.trainData.setStatusDirectly(ProcessStateEngine.finished)
                return
        } catch {
            print("Error distributing images: \(error.localizedDescription)")
            self.trainData.setStatusDirectly(ProcessStateEngine.finished)
            throw error
        }
    }
    
    func setMaxFilesIntent(_ maxCount: Int) -> Void {
        trainData.setMaxCount(maxCount)
    }
    
    @MainActor
    func completeChainOfGenAndDistributionIntent() async throws -> Void {
        
        await self.findUniquePotsIntent()
        
        do { try self.createDirectoriesIntent()
        }
        do { try await self.distributeImagesIntent()
        }
        
        return
    }
    
    @MainActor
    func setStatusIntent( _ status: ProcessStateEngine) -> Void {
        self.trainData.setStatusDirectly(status)
    }
}


    
