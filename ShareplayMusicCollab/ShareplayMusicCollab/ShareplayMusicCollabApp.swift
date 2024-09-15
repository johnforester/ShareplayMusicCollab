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
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @State private var appModel = AppModel()

    var body: some Scene {
#if os(visionOS)

        WindowGroup(id: "ContentView") {
            ContentView()
                .environment(appModel)
                .onAppear {
                    openWindow(id: "InstrumentSelect")
                }
                .task {
                    appModel.configureGroupSessions()
                    await openImmersiveSpace(id: appModel.immersiveSpaceID)
                }
        }
        
        WindowGroup(id: "InstrumentSelect") {
            InstrumentSelectAndShareplayView(onInstrumentSelected: {
                // Handle instrument selection if needed
            })
            .environment(appModel)
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
            HStack {
                MIDIMonitorView()
                    .environment(appModel)
                InstrumentSelectAndShareplayView()
                    .environment(appModel)
            }
                .task {
                    appModel.configureGroupSessions()
                }
        }
#endif
    }
}
