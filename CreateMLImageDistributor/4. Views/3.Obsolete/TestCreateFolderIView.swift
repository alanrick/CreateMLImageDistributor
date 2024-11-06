//
//  TestCreateFolderIView.swift
//  CreateMLImageDistributor
//
//  Created by alanrick on 03.11.24.
//

import SwiftUI

struct TestCreateFolderIView: View {
    
    @State private var showError = false {
        didSet {
            if showError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showError = false
                }
            }
            
        }
    }
    
    @State var isPickerPresented = false
    
    var body: some View {
        
        HStack {
            Text("Select Downloads Folder")
            Button( "Select Downloads Folder") {
                isPickerPresented = true
            }
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let downloadsURL = urls.first {
                        chatGPTCreateNewDirectory(at: downloadsURL)
                        CreateTheNewDirectory(in: downloadsURL)
                       
                    }
                case .failure(let error):
                    let errorMessage = error.localizedDescription
                    showError = true
                }
                
                
                
            }
        }
    }


func CreateTheNewDirectory(in parentFolder: URL)
    {
        guard parentFolder.startAccessingSecurityScopedResource() else {
            let errorMessage = "Failed to access the selected location"
            showError = true
            return
        }
        
        defer {
            parentFolder.stopAccessingSecurityScopedResource()
        }
        let newDir = "myShinyNewDir"
        let fileManager = FileManager.default
        let newDirectoryURL = parentFolder.appendingPathComponent(newDir)
        
        do {
            try fileManager.createDirectory(
                at: newDirectoryURL,
                withIntermediateDirectories: false,
                attributes: nil
            )
        } catch {
            print("Error creating test directory: \(error.localizedDescription)")
            let errorMessage = "Failed to create directory: \(error.localizedDescription)"
            showError = true
        }
        
    }
}


func chatGPTCreateNewDirectory(at folderURL: URL) {
    let newDirectoryURL = folderURL.appendingPathComponent("shinyNewDirectory")
    
    do {
        try FileManager.default.createDirectory(at: newDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        print("Directory created at: \(newDirectoryURL.path)")
    } catch {
        print("Error creating new test directory: \(error.localizedDescription)")
        print("Failed to create directory: \(error.localizedDescription)")
    }
}

#Preview {
    TestCreateFolderIView()
}
