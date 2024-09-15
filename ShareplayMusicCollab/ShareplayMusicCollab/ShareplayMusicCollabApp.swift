//
//  ShareplayMusicCollabApp.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/13/24.
//

import SwiftUI

@main
struct ShareplayMusicCollabApp: App {
    @Environment(\.openWindow) var openWindow
#if os(visionOS)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
#endif
    
    @State private var appModel = AppModel()

    var body: some Scene {
#if os(visionOS)

        WindowGroup(id: "ContentView") {
            ContentView()
                .environment(appModel)
                .task {
                    appModel.configureGroupSessions()
                    await openImmersiveSpace(id: appModel.immersiveSpaceID)
                }
        }
                
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        
#else
        WindowGroup(id: "InstrumentSelect") {
            TabView {
                InstrumentSelectAndShareplayView()
                    .tabItem {
                        Label("Select your flavoure", systemImage: "guitars")
                    }
                
                MIDIMonitorView()
                    .tabItem {
                        Label("MIDI monitor", systemImage: "music.quarternote.3")
                    }

            }
            .environment(appModel)
                .task {
                    appModel.configureGroupSessions()
                }
        }
#endif
    }
}
