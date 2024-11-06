//
//  ColumnHeaderView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

struct ColumnHeaderView: View {
    
    var body: some View {
        HStack {
            Image(systemName: "target").scaleEffect(2.0)
                .frame(alignment: .leading).padding(.trailing).opacity(0.01)
            
            Text("CSV Column name")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Category name")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Example data")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Specifying")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


#Preview {
    ColumnHeaderView()
}
