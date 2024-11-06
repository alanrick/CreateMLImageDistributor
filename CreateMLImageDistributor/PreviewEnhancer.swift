//
//  PreviewEnhancer.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI


extension View {
    func fullPreview() -> some View {
        modifier(completePreview())
    }
}

struct completePreview: ViewModifier {
    func body(content: Content) -> some View {
        preViewView(content)
    }
}


func preViewView(_ content: some View) -> some View {
   
    @Namespace var slideButtons
        
    return    content
            .environment(AppEnvironment())
}


