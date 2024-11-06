import SwiftUI

struct ContentView2: View {
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isPickerPresented = false
    
    var body: some View {
        VStack {
            Button("Select Downloads Folder") {
                isPickerPresented = true
            }
        }
        .fileImporter(
            isPresented: $isPickerPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let downloadsURL = urls.first {
                    createAlanDirectory(in: downloadsURL)
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
     func createAlanDirectory(in parentURL: URL) {
        // Start accessing the parent directory
        guard parentURL.startAccessingSecurityScopedResource() else {
            errorMessage = "Failed to access the selected location"
            showError = true
            return
        }
        
        defer {
            parentURL.stopAccessingSecurityScopedResource()
        }
        let alan = "Alan"
        let fileManager = FileManager.default
        let alanDirectoryURL = parentURL.appendingPathComponent(alan)
        
        do {
            try fileManager.createDirectory(
                at: alanDirectoryURL,
                withIntermediateDirectories: false,
                attributes: nil
            )
        } catch {
            errorMessage = "Failed to create directory: \(error.localizedDescription)"
            showError = true
        }
    }
}
