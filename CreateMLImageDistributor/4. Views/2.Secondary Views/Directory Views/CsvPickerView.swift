//
//  CsvPickerView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI


import UniformTypeIdentifiers


struct CsvPickerView: View {
    
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack {
            DirectoryPickerView(pickAFile: true,
                                filetypes:  [UTType.commaSeparatedText],
                                symbol: "tablecells.badge.ellipsis",
                                doProcessing: appEnvironment.identifyCSVDirectoryIntent )
            .accessibilityIdentifier("CSV Picker Button")
            
            ShowDirectory( url:             appEnvironment.trainData.csvFileLocation,
                           instructions:    "Select spreadsheet of images",
                           resultAbbrev:    "(CSV)")
            .accessibilityIdentifier("CSV picked")
        }
    }
}
#Preview {
    CsvPickerView()
        .fullPreview()
}
