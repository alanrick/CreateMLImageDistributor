//
//  TargetDirPickerView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI
import UniformTypeIdentifiers


struct TargetDirPickerView: View {
    
    @Environment(AppEnvironment.self) private var appEnvironment
 
    var body: some View {
        HStack {
            DirectoryPickerView(pickAFile: false,
                                filetypes: [UTType.directory],
                                symbol: "scope",
                                doProcessing: appEnvironment.identifyImageRootDirectoryIntent  )
            
            ShowDirectory( url: appEnvironment.trainData.fullGoalPath,
                           instructions: "Select target directory to copy images into",
                           resultAbbrev: "(Target)")
            Spacer()
        }
    }
}

#Preview {
    TargetDirPickerView()
        .fullPreview()
}
