//
//  CategoryView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

struct CategoryView: View {
    let column: CsvColumn
    
    @Environment(AppEnvironment.self) private var appEnvironment
    @State var tempText: String = ""
    
    var body: some View {
        
        HStack {
            Image(systemName: column.purpose.displayIcon()).scaleEffect(2.0)
                .frame(alignment: .leading).padding(.trailing)
                .opacity(column.purpose == .ignore ? 0 : 1)
                
            
            Text(column.colName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .accessibilityIdentifier("ColumnName-\(column.colName)")
            
            if column.purpose == .category {
                ZStack(alignment: .leading) {
                    Text(column.categoryName)
                        .accessibilityIdentifier("ColumnCat-\(column.categoryName)")
                    TextField("", text: $tempText )
                        .frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.placeholder)
                        .onChange(of: tempText , {
                            appEnvironment.updateCategoryNameIntent(column.id, to: tempText)
                        })
                        .accessibilityIdentifier("ColumnCatEdit-\(column.categoryName)")
                }
                .foregroundColor(columnColour(column.purpose))
            } else {
                Text(column.categoryName)
                    .foregroundColor(columnColour(column.purpose))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .opacity(0.01)
                    .accessibilityIdentifier("ColumnCat-\(column.categoryName)")
            }
            
            Text(column.firstValue)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
                .accessibilityIdentifier("ColumnFirstVal-\(column.firstValue)")
            
            ShowPurposeView(purpose: column.purpose, colName: column.colName)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("categoryView")
    }
    
    
    func columnColour(_ purpose: ColumnPurpose) -> Color {
        switch purpose {
        case .category:
            return .accentColor
        case .images:
            return .primary
        default:
            return .gray
        }
    }
}


#Preview {
    CategoryView(column: CsvColumn(colName: "First", firstValue: "photo.jpg", categoryName: "Ranking"))
        .fullPreview()
}

