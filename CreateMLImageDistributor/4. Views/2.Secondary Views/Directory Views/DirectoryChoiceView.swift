//
//  DirectoryChoiceView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

struct DirectoryChoiceView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
        
            CsvPickerView()
            ImageSourcePickerView()
            TargetDirPickerView()
        }
    }
}

#Preview {
    DirectoryChoiceView()
        .fullPreview()
}

