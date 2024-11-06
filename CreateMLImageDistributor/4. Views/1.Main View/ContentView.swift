//
//  ContentView.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

struct ContentView: View {
    let appEnvironment: AppEnvironment

    var body: some View {
        VStack {
            ZStack{
                Background(readyToGo: appEnvironment.trainData.readyToGo)
                
                VStack {
                    
                    ShowSelection(maxCount: Bindable(appEnvironment).trainData.maxCount)
                    DistributeCommand(appEnvironment: appEnvironment)

                    DeleteDirectoriesView(appEnvironment: appEnvironment)
                }
                .padding()
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
    
    struct Background: View {
        let readyToGo: Bool
        
        var body: some View {
          
            
            Rectangle()
                .fill(readyToGo ? Color.green : Color.white)
                .opacity(readyToGo ? 0.2 : 0.0)
                .border(readyToGo ? .green : .white, width: 10)
        }
    }

}





#Preview {
    ContentView(appEnvironment: AppEnvironment())
        .fullPreview()
}
