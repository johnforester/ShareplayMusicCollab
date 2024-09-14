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
                    appModel.sampleFilename = "SaxC3"
                    print("Sax Selected")
                    onInstrumentSelected()  // Notify parent view of the selection
                } label: {
                    Text("Sax")
                }
                
                Button {
                    appModel.sampleFilename = "GuitarC3"
                    print("Guitar Selected")
                    onInstrumentSelected()  // Notify parent view of the selection
                } label: {
                    Text("Guitar")
                }
                
                Button {
                    appModel.sampleFilename = "PianoC3"
                    print("Piano Selected")
                    onInstrumentSelected()  // Notify parent view of the selection
                } label: {
                    Text("Piano")
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
