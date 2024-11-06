//
//  ImageSourcePickerView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI
import UniformTypeIdentifiers


struct ImageSourcePickerView: View {
    
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        HStack {
            DirectoryPickerView(pickAFile: false,
                                filetypes: [UTType.directory],
                                symbol: "photo.on.rectangle",
                                doProcessing: appEnvironment.identifyImageSourceDirectoryIntent  )
            
            ShowDirectory( url:             appEnvironment.trainData.imageSourcePath,
                           instructions:    "Select directory to copy images from",
                           resultAbbrev:    "(Images)")
            .accessibilityIdentifier("Image source picked")
            Spacer()
        }
    }
}

#Preview {
    ImageSourcePickerView()
        .fullPreview()
}
