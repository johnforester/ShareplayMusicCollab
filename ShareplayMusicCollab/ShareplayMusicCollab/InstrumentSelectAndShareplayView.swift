//
//  InstrumentSelectView.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/14/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import GroupActivities
import Combine

struct InstrumentSelectAndShareplayView: View {
    @Environment(AppModel.self) private var appModel
    @StateObject private var groupStateObserver = GroupStateObserver()
    var onInstrumentSelected: () -> Void  // Closure to notify when instrument is selected
        
    var body: some View {
        VStack {
            HStack {
                Button {
                    appModel.sampleFilename = .Sax
                    print("Sax Selected")
                    onInstrumentSelected()  // Notify parent view of the selection
                } label: {
                    Model3DView(modelName: "Saxophone")
                    .frame(width: 200, height: 200)
//                    Text("Sax")
                }
                
                
                Button {
                    appModel.sampleFilename = .Guitar
                    print("Guitar Selected")
                    onInstrumentSelected()  // Notify parent view of the selection
                } label: {
                    Model3DView(modelName: "Guitar")
                    .frame(width: 200, height: 200)
//                    Text("Guitar")
                }
                
                
                Button {
                    appModel.sampleFilename = .Piano
                    print("Piano Selected")
                    onInstrumentSelected()  // Notify parent view of the selection
                } label: {
                    Model3DView(modelName: "Piano")
                    .frame(width: 200, height: 200)
//                    Text("Piano")
                }
                
            }
            .padding()
            Button {
                print("Starting as SharePlay", groupStateObserver.isEligibleForGroupSession)
                
                Task {
                    do {
                        try await appModel.startSession()
                    } catch {
                        print("SharePlay session failure", error)
                    }
                }
            } label: {
                Label {
                    Text("Shareplay")
                        .frame(maxWidth: .infinity)
                } icon: {
                    Image(systemName: "shareplay")
                }
            }
            .labelStyle(.iconOnly)
            .disabled(!groupStateObserver.isEligibleForGroupSession)
        }
    }
    
}
