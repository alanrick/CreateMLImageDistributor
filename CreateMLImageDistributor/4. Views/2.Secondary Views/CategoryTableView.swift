//
//  CategoryTableView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

// MARK: - This view is not used because it causes the @Observation framework to crash when the programm is run
// several times with different spreadsheets, each having different columns. As a temporary measure CategoryListView
// is used instead.
struct CategoryTableView: View {
    
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        VStack(alignment: .leading) {
            if let columns = appEnvironment.trainData.columns {
                
   
                Table(columns) {
                    // Icon column
                    TableColumn("") { column in
                        Image(systemName: column.purpose.displayIcon())
                            .scaleEffect(2.0)
                            .opacity(column.purpose == .ignore ? 0 : 1)
                    }
                    .width(40)
                    
                    // Column Name
                    TableColumn("Column Name") { column in
                        Text(column.colName)
                            .textSelection(.enabled)
                    }
                    
                    // Category Name
                    TableColumn("Category") { column in
                        if column.purpose == .category {
                            CategoryNameCell(
                                text: Binding(
                                    get: { column.categoryName },
                                    set: { appEnvironment.updateCategoryNameIntent(column.id, to: $0) }
                                )
                            )
                        } else {
                            Text(column.categoryName)
                                .foregroundColor(columnColour(column.purpose))
                                .opacity(0.01)
                        }
                    }
                    
                    // First Value
                    TableColumn("First Value") { column in
                        Text(column.firstValue)
                            .textSelection(.enabled)
                    }
                    
                    // Purpose
                    TableColumn("Purpose") { column in
                        ShowPurposeView(purpose: column.purpose, colName: column.colName)
                    }
                }
                .accessibilityIdentifier("categoryTable")
            }
        }
    }
}


// Simplified CategoryNameCell that uses a binding
struct CategoryNameCell: View {
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text)
            
            TextField("", text: $text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.placeholder)
        }
        .foregroundColor(columnColour(ColumnPurpose.category))
    }
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

// MARK: - This view is used instead of CategoryListVew to avoid the @Observation framework crashing
struct CategoryListView: View {
    
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        
        VStack(alignment: .leading) {
            if let columns = appEnvironment.trainData.columns {
                ColumnHeaderView()
                List(columns ) { column in
                    HStack {
                        CategoryView(column: column)
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryListView()
        .fullPreview()
}

