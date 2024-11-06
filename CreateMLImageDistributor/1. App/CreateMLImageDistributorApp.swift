//
//  CreateMLImageDistributorApp.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

@main
struct CreateMLImageDistributorApp: App {
 
    @State private var appEnvironment = AppEnvironment()
    
    var body: some Scene {
        
        WindowGroup {
            ContentView(appEnvironment: appEnvironment)
                .environment(appEnvironment)
        }
    }
}
