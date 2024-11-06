//
//  DirectoryPickerView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI
import UniformTypeIdentifiers


struct DirectoryPickerView: View {
    let pickAFile: Bool
    let filetypes: [UTType]
    let symbol: String
    let doProcessing: (_ url: URL) -> Void

    @State private var showFilePicker = false
    
    var body: some View {
        
        HStack {
            let accessibilityLabel = "dirButton-" + symbol
           
            Button(action: {showFilePicker = true } ) {Image(systemName: symbol) }
                .accessibilityIdentifier(accessibilityLabel)
                .fileImporter(
                    isPresented: $showFilePicker,
                    allowedContentTypes: filetypes,
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            doProcessing(url)
                        }
                        
                    case .failure(let error):
                        print("Error picking file: \(error.localizedDescription)")
                    }
                }
        }
    }
}


struct      ShowDirectory: View {
        let url: URL?
        let instructions: LocalizedStringResource
        let resultAbbrev: LocalizedStringResource
    
    var body: some View {
        Text("\(url == nil ? instructions : "\(url!.path) \(resultAbbrev)" )")

    }
}


 #Preview {
     HStack {
 
         DirectoryPickerView( pickAFile: true,
                              filetypes: [.commaSeparatedText],
                              symbol: "folder",
                              doProcessing: doNothingForPreview)
         ShowDirectory(url: nil, instructions: "Pick the csv file", resultAbbrev: "(CSV)")
     }
     .fullPreview()
                      
 }

func doNothingForPreview(_ url: URL ) {
}

 
