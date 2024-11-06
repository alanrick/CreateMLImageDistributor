//
//  ObsoleteViews.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI

struct DetermineCategories: View {
    
    @Environment(AppEnvironment.self) private var appEnvironment
    
    var body: some View {
        
        HStack {
            Button(action: {
                Task {
                    await appEnvironment.findUniquePotsIntent()
                }
            }, label: {
                HStack {
                    Image(systemName: "figure.golf").imageScale(.large)
                }
            })
            .disabled(appEnvironment.trainData.columns == nil || appEnvironment.trainData.columns!.count(where: { $0.purpose == ColumnPurpose.category }) == 0 )
            
            Spacer()
        }
    }
}


struct CreateDirectoriesView: View {
    @Environment(AppEnvironment.self) private var appEnvironment
    
    @State var createDirError = false
    @State var errorText = ""
    
    var body: some View {
        
        HStack {
            Button( action: {
                do { try appEnvironment.createDirectoriesIntent()
                } catch {
                    print("Error Creating direcotries: \(error.localizedDescription)")
                }
            } , label: {Image(systemName: "folder").imageScale(.large) })
            .disabled(appEnvironment.trainData.goalRootPath == nil || appEnvironment.trainData.uniquePots.count == 0)
            Spacer()
        }
        .alert("Creating Directories ",
               isPresented: $createDirError,
               actions: { Button("Cancel", role: .cancel, action: {} ) },
               message: {Text(errorText)} )
    }
}


struct ButtonDistributePhotos: View {
    let  photoCount: Int
    
    @Environment(AppEnvironment.self) private var appEnvironment
    
    
    var body: some View {
        HStack {
            
            Button( action: {
                Task {
                    do { try await appEnvironment.distributeImagesIntent()
                    }
                }
            } , label: {Image(systemName: "document.on.document").imageScale(.large) })
            
            .disabled(appEnvironment.trainData.goalRootPath == nil || appEnvironment.trainData.uniquePots.count == 0)
            
            if photoCount > 0 {
                Text("\(photoCount) images were distributed in \(appEnvironment.trainData.uniquePots.count) folders")
            }
            Spacer()
        }
    }
}

#Preview {
    CreateDirectoriesView()
        .fullPreview()
}

#Preview {
    DetermineCategories()
        .fullPreview()
}

#Preview {
    ButtonDistributePhotos(photoCount: 1000)
        .fullPreview()
}
