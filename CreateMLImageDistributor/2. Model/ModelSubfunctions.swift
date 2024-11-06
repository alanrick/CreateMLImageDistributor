//
//  ModelSubfunctions.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import Foundation

enum CSVError: LocalizedError {
    case insufficientData
    case fileReadError(Error)
    case invalidColumnIndex
    case noReadPermision
    case noWritePermision
    
    var errorDescription: String? {
        switch self {
        case .insufficientData:
            return "CSV file does not contain enough data."
        case .fileReadError(let error):
            return "Error reading CSV file: \(error.localizedDescription)"
        case .invalidColumnIndex:
            return "Lost track of column count"
        case .noReadPermision:
            return "No permission to read file"
        case .noWritePermision:
            return "No permission to write file"
        }
    }
}


func doIdentifyColumns(csv: URL?) throws -> [CsvColumn] {
    try CSVParser.identifyColumns(from: csv)
}


struct CSVParser {
    private static let imageExtensions = ["png", "jpg", "heic"]
   
    static func identifyColumns(from csv: URL?) throws -> [CsvColumn] {
        
        // Check csv directory has been specified
        guard let csv else { return [] }
        
        // Set up File permissions
        try self.getPermissionForFileAccess(csv, crud: .read)
                
        defer {
            self.stopPermissionForFileAccess(csv)
        }
        
        // Process the spreadshet
        do {
            let lines = try readCSVLines(from: csv)
            guard lines.count > 1 else { throw CSVError.insufficientData }
      
            let columns = createColumns(headerLine: lines[0], dataLine: lines[1])
            
            return columns
        } catch {
            print(error.localizedDescription)
            throw error
        }
        

    }
    
    static func getPermissionForFileAccess(_ file: URL, crud: Crud) throws -> Void
    {
        let fileManager = FileManager.default
        let parentDir = file.deletingLastPathComponent()
        var scopedResourceURL: URL {crud == .create ? parentDir  : file}
        
        // Check existence of file, but it doesn't matter if it does or doesnt for .create
        if !fileManager.fileExists(atPath: file.path) && !(crud == .create) {
            throw AppError.fileDoesNotExist(file: file.path)
        }
        
        guard  scopedResourceURL.startAccessingSecurityScopedResource()  else {
            throw AppError.noFilePermission(file: file.path, action: "Access")
        }
        
      
        switch crud {
        case .create:
            guard fileManager.isWritableFile(atPath: parentDir.path) else {
                throw AppError.noFilePermission(file: parentDir.path, action: crud.action())
            }
        case .read:
            guard fileManager.isReadableFile(atPath: file.path) else {
                throw AppError.noFilePermission(file: file.path, action: crud.action())
            }
        case .update:
            guard fileManager.isWritableFile(atPath: file.path) else {
                throw AppError.noFilePermission(file: file.path, action: crud.action())
            }
        case .delete:
            guard fileManager.isDeletableFile(atPath: file.path) else {
                throw AppError.noFilePermission(file: file.path, action: crud.action())
            }
        }
        return
    }

     static func stopPermissionForFileAccess(_ csv: URL)
    {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: csv.path) else {
            return
        }
        csv.stopAccessingSecurityScopedResource()
    }
  
    static func readCSVLines(from url: URL) throws -> [String.SubSequence] {
        let content = try String(contentsOf: url, encoding: .utf8)
        return content.split(separator: "\r\n")
    }
    
    private static func createColumns(headerLine: String.SubSequence, dataLine: String.SubSequence) -> [CsvColumn] {
        let columnNames = headerLine.split(separator: ",").map(String.init)
        let rowData = dataLine.split(separator: ",").map(String.init)
        
        return zip(columnNames, rowData).map { name, value in
            var column = CsvColumn(colName: name, firstValue: value, categoryName: name)
            if isImageURL(value) {
                column.purpose = .images
            }
            return column
        }
    }
    
    private static func isImageURL(_ value: String) -> Bool {
        guard let url = URL(string: value) else { return false }
        return imageExtensions.contains(url.pathExtension.lowercased())
    }
}


func doCalcCategoryValues(uniquePots: [uniquePot], csv: URL?) throws -> [uniquePot] {
    guard let csv else { return [] }
    
    do {
        let lines = try readCSVLines(from: csv)
        guard lines.count > 1 else { throw CSVError.insufficientData }
        
        // Skip header row and process data rows
        let dataLines = Array(lines.dropFirst())
        return try processUniquePots(uniquePots, with: dataLines)
    } catch {
        print("Error calculating Catagories: \(error.localizedDescription)")
        throw error
    }
}

// MARK: - Private Helper Functions

private func readCSVLines(from url: URL) throws -> [String.SubSequence] {
    let content = try String(contentsOf: url, encoding: .utf8)
    return content.split(separator: "\r\n")
}

private func processUniquePots(
    _ uniquePots: [uniquePot],
    with dataLines: [String.SubSequence]
) throws -> [uniquePot] {
    try uniquePots.map { pot in
        var updatedPot = pot
        updatedPot.categoryValues = extractCategoryValues(
            from: dataLines,
            columnIndex: pot.colIndex
        )
        return updatedPot
    }
}

private func extractCategoryValues(
    from lines: [String.SubSequence],
    columnIndex: Int
) -> Set<subFolders> {
    var categoryValues = Set<subFolders>()
    
    for line in lines {
        let columnValues = line.split(separator: ",").map(String.init)
        guard columnIndex < columnValues.count else { continue }
        
        let subfolder = subFolders(
            name: columnValues[columnIndex],
            count: 0
        )
        categoryValues.insert(subfolder)
    }
    
    return categoryValues
}

enum DirectoryError: LocalizedError {
    case emptyCategories
    case createFailed(path: String, underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .emptyCategories:
            return "No categories provided for directory creation"
        case .createFailed(let path, let error):
            return "Failed to create directory at \(path): \(error.localizedDescription)"
        }
    }
}

func doCreateDirectories(
    filePathPicked: URL,
    catColumns: [CsvColumn],
    uniquePots: [uniquePot]
) throws
{
    let creator = DirectoryCreator()
    try creator.doCreateDirectories(
        filePathPicked: filePathPicked,
        catColumns: catColumns,
        uniquePots: uniquePots
    )
}

struct DirectoryCreator {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func doCreateDirectories(
        filePathPicked: URL,
        catColumns: [CsvColumn],
        uniquePots: [uniquePot]
    ) throws {

        try CSVParser.getPermissionForFileAccess(filePathPicked, crud: .create)
        defer {CSVParser.stopPermissionForFileAccess(filePathPicked) }
        
            do {
                try createBaseDirectory(at: filePathPicked)
                try createCategoryStructure(at: filePathPicked, for: catColumns, uniquePots: uniquePots)
            } catch {
                print("Creating directory failed: \(error.localizedDescription)")
                throw error
            }
    }
    
    private func createBaseDirectory(at path: URL) throws {
        try fileManager.createDirectory( at: path, withIntermediateDirectories: false)
    }
    
    private func createCategoryStructure(
        at basePath: URL,
        for categories: [CsvColumn],
        uniquePots: [uniquePot]
    ) throws {
        guard !categories.isEmpty else {
            throw DirectoryError.emptyCategories
        }
        
        for pot in uniquePots {
            let categoryPath = basePath.appending(path:  pot.categoryName)
            try createDirectory(at:  categoryPath)
            
            try createSubcategoryDirectories(
                for: pot.categoryValues,
                in: categoryPath
            )
        }
    }
    
    private func createSubcategoryDirectories(
        for categoryValues: Set<subFolders>,
        in basePath: URL
    ) throws {
        for catValue in categoryValues {
            let subcategoryPath = basePath.appending(path:  catValue.name)
            try fileManager.createDirectory( at: subcategoryPath, withIntermediateDirectories: false)
        }
    }
    
    private func createDirectory(at path: URL) throws {
        do {
            try CSVParser.getPermissionForFileAccess(path, crud: .create)
            defer {  CSVParser.stopPermissionForFileAccess(path) }
            
            try fileManager.createDirectory(at: path, withIntermediateDirectories: false)
          
        } catch {
            print("Error creating directory structure: \(error.localizedDescription)")
            throw DirectoryError.createFailed(path: path.absoluteString, underlying: error)
        }
    }
}


@MainActor
func doDeleteRootDirectory(rootDir: URL) throws -> Void {
    
    // Ask for directory access permission
    try CSVParser.getPermissionForFileAccess(rootDir, crud: .delete)
    defer { CSVParser.stopPermissionForFileAccess(rootDir) }
    
    let fileManager = FileManager.default
    
    do {
        try fileManager.removeItem(atPath: rootDir.path)
    }
}

func doCheckImageSourceHasImages(_ imageRootURL: URL, exampleFile: String?) -> Bool {
    
    let fileManager = FileManager.default
    
    guard let exampleFile else { return false }
    
    let imageSourcePath = imageRootURL.appending(path: exampleFile)
    
    // Ask for directory access permission
    do
    { try  CSVParser.getPermissionForFileAccess(imageRootURL, crud: .read) }
    catch {
        print("Error checking image source is legit: \(error.localizedDescription)")
        return false }
            
    defer { CSVParser.stopPermissionForFileAccess(imageRootURL) }
    
    // Check that example image file exists
    guard fileManager.fileExists(atPath: imageSourcePath.path) else { return false }
    
    // Check that the extension is in the set of allowed extensions
    return ["jpg","png", "heic"].contains(imageSourcePath.pathExtension)
    
}



struct ImageDistributor {
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func doDistributeImages(
        columns: [CsvColumn],
        imageRootURL: URL,
        imageDestinationURL: URL,
        csv: URL,
        maxImageCount: Int
    ) throws -> Int {
        let imageIndex = try findImageColumnIndex(in: columns)
        let categoryIndices = findCategoryColumnIndices(in: columns)
        guard !categoryIndices.isEmpty else { throw ImageDistributionError.noCategories }
        
        // Get picker file access
        try CSVParser.getPermissionForFileAccess(csv, crud: .read)
        defer { CSVParser.stopPermissionForFileAccess(csv)  }
        
        
        let lines = try readAndShuffleCSVLines(from: csv)
        
        return try distributeImages(
            lines: lines,
            imageIndex: imageIndex,
            categoryIndices: categoryIndices,
            columns: columns,
            imageRootURL: imageRootURL,
            imageDestinationURL: imageDestinationURL,
            maxImageCount: maxImageCount
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func findImageColumnIndex(in columns: [CsvColumn]) throws -> Int {
        guard let index = columns.firstIndex(where: { $0.purpose == .images }) else {
            throw ImageDistributionError.noImageColumn
        }
        return index
    }
    
    private func findCategoryColumnIndices(in columns: [CsvColumn]) -> [Int] {
        columns.enumerated()
            .filter { $0.element.purpose == .category }
            .map { $0.offset }
    }
    
    private func readAndShuffleCSVLines(from url: URL) throws -> [String.SubSequence] {
        
        let content = try String(contentsOf: url, encoding: .utf8)
        var lines = content.split(separator: "\r\n")
        guard lines.count > 1 else { throw ImageDistributionError.insufficientData }
        
        lines.removeFirst() // Remove header
        lines.shuffle()
        return lines
    }
    
    private func distributeImages(
        lines: [String.SubSequence],
        imageIndex: Int,
        categoryIndices: [Int],
        columns: [CsvColumn],
        imageRootURL: URL,
        imageDestinationURL: URL,
        maxImageCount: Int
    ) throws -> Int {
        var imageCnt = 0
        var catCnt: [String: Int] = [:]
        
        try CSVParser.getPermissionForFileAccess(imageRootURL, crud: .read)
        defer {  CSVParser.stopPermissionForFileAccess(imageRootURL) }
        try CSVParser.getPermissionForFileAccess(imageDestinationURL, crud: .create)
        defer {  CSVParser.stopPermissionForFileAccess(imageDestinationURL) }
        
        for (lineIndex, line) in lines.enumerated() {
            let columnValues = line.split(separator: ",").map(String.init)
            let imagePath = columnValues[imageIndex]
            let imageSourcePath = imageRootURL.appending(path: imagePath)
            let newImageFileName = String(format: "%08d_", lineIndex) + URL(fileURLWithPath: imagePath).lastPathComponent
            
            try processCategories(
                categoryIndices: categoryIndices,
                columnValues: columnValues,
                columns: columns,
                imageSourcePath: imageSourcePath,
                newImageFileName: newImageFileName,
                imageDestinationURL: imageDestinationURL,
                catCnt: &catCnt,
                imageCnt: &imageCnt,
                maxImageCount: maxImageCount
            )
        }
        
        return imageCnt
    }
    
    private func processCategories(
        categoryIndices: [Int],
        columnValues: [String],
        columns: [CsvColumn],
        imageSourcePath: URL,
        newImageFileName: String,
        imageDestinationURL: URL,
        catCnt: inout [String: Int],
        imageCnt: inout Int,
        maxImageCount: Int
    ) throws {
        for categoryIndex in categoryIndices {
            let subCategory = columnValues[categoryIndex]
            let subCatLongID = columns[categoryIndex].categoryName + subCategory
            
            catCnt[subCatLongID] = (catCnt[subCatLongID] ?? 0) + 1
            guard catCnt[subCatLongID]! <= maxImageCount else { continue }
            
            let destinationDir = imageDestinationURL
                .appending(path: columns[categoryIndex].categoryName)
                .appending(path: subCategory)
            
            try copyImageIfDestinationExists(
                from: imageSourcePath,
                to: destinationDir.appendingPathComponent(newImageFileName),
                imageCnt: &imageCnt )
        }
    }
    
    private func copyImageIfDestinationExists(
        from source: URL,
        to destination: URL,
        imageCnt: inout Int
    ) throws {
        guard fileManager.fileExists(atPath: destination.deletingLastPathComponent().path) else { return }
        
        do {
            try fileManager.copyItem(at: source, to: destination)
            imageCnt += 1
        } catch {
            print("Error copying images: \(error.localizedDescription)")
            throw ImageDistributionError.fileCopyError(
                source: source.path,
                destination: destination.path,
                error: error
            )
        }
    }
}

// Wrapper function to maintain the original interface
func doDistributeImages(
    columns: [CsvColumn],
    imageRootURL: URL,
    imageDestinationURL: URL,
    csv: URL,
    maxImageCount: Int
) throws -> Int {
    let distributor = ImageDistributor()
    return try distributor.doDistributeImages(
        columns: columns,
        imageRootURL: imageRootURL,
        imageDestinationURL: imageDestinationURL,
        csv: csv,
        maxImageCount: maxImageCount
    )
}

