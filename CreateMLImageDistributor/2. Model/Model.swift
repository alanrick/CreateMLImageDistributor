//
//  AppModel.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import Foundation


struct AppModel  {
    // MARK: - Variable properties
    private(set) var csvFileLocation:        URL? {
        didSet {
            self.completeReset()      //     New csv file, so reset old values
        }
    }
    private(set) var goalRootPath:           URL?
    private(set) var imageSourcePath:        URL?
                 var maxCount                = 1000
    private(set) var appError:               AppError?
    
    // MARK: - Determined properties
    private(set) var columns:                [CsvColumn]?          // Determined from by the csv file
    private(set) var imageDistributedCount   = 0
    private(set) var uniquePots              = [uniquePot]()       // Determined from by the csv file and identified categories
    
    static       let goalSubDir              = "CreateMLImages"
                 var fullGoalDirExists:      Bool { self.fullRootDirExists() }
    var fullGoalPath:                        URL? { self.goalRootPath?.appendingPathComponent(AppModel.goalSubDir) ?? nil}
    private(set) var currentStatus           = ProcessStateEngine.notStarted
    var readyToGo:                           Bool { self.determineNewStatus() == .allSet }

    // MARK: - Methods
    mutating func identifyCSVDirectory(_ url: URL) {
        self.csvFileLocation                 = url
        self.identifyColumns()
        self.setProcessStatusIndirectly()
    }
    
    mutating func identifyImageSourceDirectory(_ url: URL) {
        self.imageSourcePath                 = url
        self.setProcessStatusIndirectly()
    }
    
    mutating func identifyImageTargetDirectory(_ url: URL)  {
        self.goalRootPath                    = url
        self.setProcessStatusIndirectly()
    }

    
    mutating func updateCategoryName(_ id: UUID, to newName: String) {
        if let index = columns?.firstIndex(where: { $0.id == id }) {
            self.columns?[index].categoryName = newName
        } else {
            // MARK: - Improve by changing to a throw
            print("Failed to update. ID: \(id) new value \(newName)")
        }
    }
    
    mutating func updatePurpose(_ newPurpose: ColumnPurpose, colName: String) {
        
        let count = columns?.count ?? 0
        guard count > 0 else { return }
        
        if newPurpose == .images {
            for index in 0..<count {
                if columns?[index].purpose == .images {
                    columns?[index].purpose = .ignore
                }
            }
        }
        
        if let index = columns?.firstIndex(where: { $0.colName == colName }) {
            columns?[index].purpose = newPurpose
        }
        self.setProcessStatusIndirectly()
    }
    mutating func identifyColumns() {
        do { try self.columns = doIdentifyColumns(csv: self.csvFileLocation)
        } catch {
            print("Error Identify columns: \(error.localizedDescription)")
            self.setAppError(.problemsWithCsVFile(reason: error.localizedDescription))
        }
        self.setProcessStatusIndirectly()
    }
    
    mutating func createUniquePots() {
        self.uniquePots = []
        guard let columns else { return }
        
        var count = 0
        for column in columns {
            
            if column.purpose == .category {
                self.uniquePots.append(uniquePot(colIndex: count, categoryName: column.categoryName, categoryValues: [] ))
            }
            count += 1
        }
    }
    
    mutating func getCategoryValues() async throws -> Void {
        //  MARK: - Improve by adding a throw or testing that the throw is propagated
        guard let csv = self.csvFileLocation else { return }
        
        try CSVParser.getPermissionForFileAccess(csv, crud: .read)
        defer { CSVParser.stopPermissionForFileAccess(csv) }
        
        self.uniquePots = try doCalcCategoryValues(uniquePots: self.uniquePots, csv: self.csvFileLocation)
    }
    
    mutating func CreateDirectories() throws {
        guard goalRootPath != nil else { return }
        guard let columns else { return }
        guard let fullGoalPath else { return }
        
        
        do { try doCreateDirectories(filePathPicked: fullGoalPath, catColumns: columns,
                                     uniquePots: self.uniquePots )
        } catch {
            self.setAppError(AppError.noFilePermission(file: fullGoalPath.path, action: "Create Directory"))
            throw error
        }
        
    }
    
    mutating func distributeImages( ) async throws ->  Void {
     
        guard let columns else { return }
        guard let imageSourcePath else { return }
        guard let goalRootPath else { return }
        guard let fullGoalPath else { return }
        guard let csvFileLocation else { return }
        
        do { try self.imageDistributedCount =  doDistributeImages(columns: columns,
                                                                 imageRootURL: imageSourcePath,
                                                                 imageDestinationURL: fullGoalPath,
                                                                 csv: csvFileLocation,
                                                                 maxImageCount: self.maxCount)
        }
        return
    }
    
    @MainActor
    mutating func   deleteRootDirectory() async throws -> Void {
        guard let fullGoalPath else { return }
        do {  try doDeleteRootDirectory(rootDir: fullGoalPath)
            self.reset()
            return
        }
        
    }
    
    mutating func setMaxCount(_ maxCount: Int) {
        
        self.maxCount = maxCount
    }
    
    func dirRootDefinedAndSafe() -> Bool {
        guard let goalRootPath else { return false }
        guard let fullGoalPath else { return false }
        
        // Safety check... the directory exists and it contains the sub-directory name of this application
        let result1 = FileManager.default.fileExists(atPath: goalRootPath.path )
        let result2 = fullGoalPath.path.contains(String(AppModel.goalSubDir))
        return result1 && result2
    }
    
    func fullRootDirExists() -> Bool {
        guard let fullGoalPath  else { return false }
        
        // Safety check... the directory exists and it contains the sub-directory name of this application
        return FileManager.default.fileExists(atPath: fullGoalPath.path )
    }
    
    mutating func completeReset() {
        self.columns = []
        self.uniquePots = []
        self.imageDistributedCount = 0
        self.setProcessStatusIndirectly()
    }
    
    
    mutating func reset() {
        self.imageDistributedCount = 0
        self.setProcessStatusIndirectly()
        self.resetAppError()
    }
    
    mutating func setStatusDirectly(_ status: ProcessStateEngine) {
        self.currentStatus = status
    }

    mutating func setProcessStatusIndirectly() {
        self.currentStatus = determineNewStatus()
    }
    
    func determineNewStatus() -> ProcessStateEngine {
        // Do not touch these statuses - they are set from elsewhere
        guard !(self.currentStatus == .processing) else { return .processing }

        
        // The following are status showing how far the setup is complete
        guard self.appError == nil else { return .error }
        guard (self.maxCount > 0)               else { return .zeroFiles }
        guard csvFileLocation != nil  else { return .noCSV }
        guard imageSourcePath != nil  else { return .noSourceImageFolder }
        guard let columns  else { return .noCategories }
        guard fullGoalPath != nil else { return .noTargetFolder }
        
        guard columns.count(where: {$0.purpose == ColumnPurpose.images}) == 1 else { return .noImageColumn }
        guard columns.count(where: {$0.purpose == ColumnPurpose.category}) > 0 else { return .noCategories }
        guard self.dirRootDefinedAndSafe()  else { return .noTargetFolder }
        guard doCheckImageSourceHasImages(self.imageSourcePath!, exampleFile: self.columns?.first(where: {$0.purpose == ColumnPurpose.images})?.firstValue) else { return .badSourceImageFolder }
        guard !self.fullRootDirExists() else { return .delTargetDir }
        
        guard !(self.currentStatus == .finished) else { return .finished }   // Keep the finished state so the count is displayed
        
        // All systems are go
        return .allSet
    }
    
    mutating func setAppError(_ error: AppError) {
        self.appError = error
    }

    mutating func resetAppError() {
        self.appError = nil
    }
}



// MARK: - sub structures


struct CsvColumn:  Equatable, Identifiable, Hashable {
    let id = UUID()
    let colName: String
    var firstValue: String
    var categoryName: String
    var purpose = ColumnPurpose.ignore
}

struct uniquePot {
    var colIndex: Int
    var categoryName: String
    var categoryValues = Set<subFolders>()   //empty set of strings.
}

struct subFolders: Hashable {
    var name: String
    var count: Int
}

