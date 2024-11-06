//
//  ShowPurposeView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

struct ShowPurposeView: View {
    let purpose: ColumnPurpose
    let colName: String
    
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        
        HStack {
            
            categoryButtonView(.images)
                .accessibilityIdentifier("ColumnPurpose-\(colName)\(ColumnPurpose.images.rawValue)")
            categoryButtonView(.category)
                .accessibilityIdentifier("ColumnPurpose-\(colName)\(ColumnPurpose.category.rawValue)")
            categoryButtonView(.ignore )
                .accessibilityIdentifier("ColumnPurpose-\(colName)\(ColumnPurpose.ignore.rawValue)")
            
            Text(purpose.rawValue)
                .accessibilityIdentifier("ColumnPurposeDescription-\(colName)")
            
        }
        .padding(.vertical, 10)
    }
    
    func categoryButtonView(_ displayPurpose: ColumnPurpose) -> some View {

            Button(action: {withAnimation {
                updatePurposeLocal(displayPurpose)
            }})
                {
                    buttonImage(button:     displayPurpose.displayIcon(),
                                matched:    purpose == displayPurpose,
                                colName:    colName)
                }
            .disabled(purpose == displayPurpose)
        
    }
    
    struct buttonImage: View {
        let button:     String
        let matched:    Bool
        let colName:    String
        
        var body: some View {
            Image(systemName: button)
                .slideButtonBorder(matched, colName)
                .animation(.easeInOut, value: true)
        }
    }
    
    func updatePurposeLocal(_ purpose: ColumnPurpose) {
        appEnvironment.updatePurposeIntent(purpose, colName: colName)
    }
}

extension View {
    func slideButtonBorder(_ show: Bool, _ colName: String) -> some View {
        modifier(showButtonBorder(show: show, colName: colName))
    }
}


struct showButtonBorder: ViewModifier {
    let show:       Bool
    let colName:    String
    
    func body(content: Content) -> some View {
        if show {
            
            content
                .foregroundColor(.accentColor)
                .scaleEffect(2.0).bold()
        } else {
            content
                .scaleEffect(2.0)
        }
    }
}


#Preview {
    ShowPurposeView(purpose: ColumnPurpose.images, colName: "Images")
        .fullPreview()
}
