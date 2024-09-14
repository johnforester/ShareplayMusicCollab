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
                } label: {
                    Text( "Sax")
                }
                Button {
                } label: {
                    Text( "Guitar")
                }
                Button {
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
