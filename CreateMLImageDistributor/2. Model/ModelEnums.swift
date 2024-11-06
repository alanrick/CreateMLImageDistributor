//
//  ModelEnums.swift
//  CreateMLImageDistributor
//
//  Created by alanrick on 02.11.24.
//

import Foundation

// MARK: - enums

enum ColumnPurpose: String {
    case images = "Images"
    case category = "Category"
    case ignore = "Ignore"
    
    func displayIcon() -> String {
        switch self {
        case .images:
            return "photo.artframe"
        case .category:
            return "tray"
        case .ignore:
            return "eye.slash"
        }
    }
    
}

    
enum ProcessStateEngine: String, Codable, CaseIterable, Identifiable {
    var id: String {self.rawValue}
    
    case error
    case notStarted
    case zeroFiles
    case noCSV
    case noSourceImageFolder
    case noImageColumn
    case noCategories
    case noTargetFolder
    case badSourceImageFolder
    case delTargetDir
    case allSet
    case processing
    case finished
    
    func messageShow() -> String {
        switch self {
        case .error:
            return "An error occured"
        case .notStarted:
            return "Not Started"
        case .zeroFiles:
            return "Must copy at least one file"
        case .noCSV:
            return "No CSV file has been selected"
        case .noSourceImageFolder:
            return "No source folder containing the images has been selected"
        case .noImageColumn:
            return "No image column has been selected"
        case .noCategories:
            return "No categories have been selected"
        case .noTargetFolder:
            return "No target folder has been selected"
        case .badSourceImageFolder:
            return "The image-source directory contains the wrong file types. "
        case .delTargetDir:
            return "You must delete the existing target folder"
        case .allSet:
            return "All set - ready to start"
        case .processing:
            return ""
        case .finished:
            return ""
            
        }
    }
}

enum AppError: Error {
    case problemsWithCsVFile(reason: String)
    case noFilePermission(file: String, action: String)
    case fileDoesNotExist(file: String)
    case fileNotReadable
    
    func messageShow() -> String {
        switch self {
        case .problemsWithCsVFile(let reason):
            return "Cannot find open CSV file: \(reason)"
        case .noFilePermission(let file, let action):
            return "No \(action) file permission for: \(file)"
        case .fileDoesNotExist(let file):
            return "File does not exist: \(file)"
        case .fileNotReadable:
            return "File cannot be read"
        }
    }
}

enum Crud: Int {
    case create, read, update, delete
    
    func action() -> String {
        switch self {
        case .create:
            return "Creating"
        case .read:
            return "Reading"
        case .delete:
            return "Deleting"
        case .update:
            return "Updtating"
        }
    }
}


enum ImageDistributionError: LocalizedError {
    case noImageColumn
    case noCategories
    case insufficientData
    case fileCopyError(source: String, destination: String, error: Error)
    
    var errorDescription: String? {
        switch self {
        case .noImageColumn:
            return "No image column found in the data"
        case .noCategories:
            return "No category columns found in the data"
        case .insufficientData:
            return "CSV file does not contain enough data"
        case .fileCopyError(let source, let destination, let error):
            return "Error copying file from \(source) to \(destination): \(error.localizedDescription)"
        }
    }
}
