//
//  SpreadSheetProcessingViews.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI


struct ShowSelection: View {
    @Binding var maxCount: Int
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
//            CategoryTableView()
              CategoryListView()       // Equivalent to CatagoryTableView but doesn't crash
            
            DirectoryChoiceView()
            
            HStack {
                Text("Max images in each folder")
                    .accessibilityIdentifier("labelMaxImagesInEachFolder")
                
                TextField("", value: $maxCount, format: .number)
                    .accessibilityIdentifier("maxImagesInEachFolder")
                    .frame(maxWidth: 100.0)
         
            }
        }
    }
}


#Preview {
    ShowSelection(maxCount: .constant(1001))
        .fullPreview()
}

