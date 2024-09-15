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
    @Environment(MIDIMonitorConductor.self) private var midiMonitorConductor
    
    @StateObject private var groupStateObserver = GroupStateObserver()
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Instrument.all) { instrument in
                    Button {
                        appModel.instrument = instrument
                    } label: {
                        Model3DView(modelName: instrument.usdzName)
                            .frame(width: 200, height: 200)
                        Text(instrument.title)
                    }
                    .background(appModel.instrument == instrument ? .regularMaterial : .ultraThin )
                }
                
            }
            .padding()
            .onChange(of: appModel.instrument) { _,_ in
                midiMonitorConductor.stop()
                midiMonitorConductor.start()
            }
            
            
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
                        .font(.largeTitle)
                }
                
            }
            .labelStyle(.iconOnly)
            .disabled(!groupStateObserver.isEligibleForGroupSession)
        }
    }
    
}
