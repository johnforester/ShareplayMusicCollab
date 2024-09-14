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
        
    var body: some View {
        VStack {
            Text("Instrument Select")
            HStack {
                Button {
                    appModel.sampleFilename = "SaxC3"
                } label: {
                    Text( "Sax")
                }
                Button {
                    appModel.sampleFilename = "GuitarC3"
                } label: {
                    Text( "Guitar")
                }
                Button {
                    appModel.sampleFilename =  "PianoC3"
                } label: {
                    Text( "Piano")
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
