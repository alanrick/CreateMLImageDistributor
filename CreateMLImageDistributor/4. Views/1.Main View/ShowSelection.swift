//
//  ShowSelection.swift
//  CreateMLImageDistributor
//
//  Created by Alanrick on 02.11.24.
//

import SwiftUI
import UniformTypeIdentifiers


struct DeleteDirectoriesView: View {
    let appEnvironment: AppEnvironment
    
    @State var deletionInProgress = false
    @State var deleteError = false
    @State var errorText = ""
    
    var body: some View {
             
        HStack {
            
            Button( role: .destructive, action: {
                deletionInProgress = true
                Task {
                    do {try await appEnvironment.DeleteRootDirectoryIntent()
                        appEnvironment.setStatusIntent(.allSet)
                        deletionInProgress = false
                    } catch {
                        print("Error deleting directories: \(error.localizedDescription)")
                        deleteError = true
                        errorText = error.localizedDescription
                        
                    }
                    
                }
                
            } , label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .imageScale(.large)
                    
                    
                }
            })
            .accessibilityIdentifier("DeleteButton")
            .disabled( !appEnvironment.trainData.fullGoalDirExists)
            
            if deletionInProgress   {
                ProgressView()
            } else {
                
                if appEnvironment.trainData.fullGoalDirExists {
                    Text(appEnvironment.trainData.fullGoalPath?.path ?? "" )
                } else {
                    Text("(Target directory)")
                }
            }
            
            Spacer()
        }
        .alert("Deleting Directory",
               isPresented: $deleteError,
               actions: { Button("Cancel", role: .cancel, action: {} ) },
               message: {Text(errorText)} )
    }
}


struct DistributeCommand: View {
    let appEnvironment: AppEnvironment
    
    @State var isPresented: Bool = false
    @State var distributeError = false
    @State var errorText = ""
    
    var body: some View {
        let allSet =  appEnvironment.trainData.readyToGo
        
        HStack {
            
            Button(action: {
                Task {
                    appEnvironment.trainData.setStatusDirectly(.processing)
                    do { try await appEnvironment.completeChainOfGenAndDistributionIntent()
                        appEnvironment.trainData.setStatusDirectly(.finished)
                    } catch {
                        print("Error distributing images:  \(error.localizedDescription)")
                        errorText = error.localizedDescription
                        distributeError = true
                        appEnvironment.trainData.setStatusDirectly(.error)
                    }
                    
                }
            }, label: {
                PlayButton( allSet: allSet)
            })
            .accessibilityIdentifier("DistributeButton")
            .disabled(!(allSet))
            
            switch appEnvironment.trainData.currentStatus {
            case .processing:
                    ProgressView()
                    .accessibilityIdentifier("inProgress")
                
            case .finished:
                    Text("Images distributed: \(appEnvironment.trainData.imageDistributedCount)")
                        .accessibilityLabel("Images distributed: \(appEnvironment.trainData.imageDistributedCount)")
                
            default:          // Either not yet ready, or ready to rumble
                
                Text(textToDisplay(appEnvironment.trainData.currentStatus, appError: appEnvironment.trainData.appError))
                        .accessibilityLabel(appEnvironment.trainData.currentStatus.messageShow() )
                        .accessibilityIdentifier("reasonForDisabled")
                        .selectionDisabled(false)
                        .bold(allSet)
            }
            
            Spacer()
        }
        .alert("Distributing Files",
               isPresented: $distributeError,
               actions: { Button("Cancel", role: .cancel, action: {} ) },
               message: {Text(errorText)} )
    }
    
    func textToDisplay(_ currentStatus: ProcessStateEngine, appError: AppError?) -> String {
        guard let appError else {
            return currentStatus.messageShow()
        }
        
        return appError.messageShow()
    
    }
    
}



struct PlayButton: View {
    let allSet: Bool
    
    var body: some View {
        Image(systemName: allSet ? "play.fill" : "play")
                .imageScale(.large)
                .foregroundColor(allSet ? .green : .gray)
                .opacity(allSet ? 1 : 0.5)
               
    }
}

#Preview {
    DeleteDirectoriesView(appEnvironment: AppEnvironment() )
        .fullPreview()
}


#Preview {
    DistributeCommand(appEnvironment: AppEnvironment())
        .fullPreview()
}

