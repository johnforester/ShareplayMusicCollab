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
                }
        }
        
        WindowGroup(id: "InstrumentSelect") {
            InstrumentSelectAndShareplayView()
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
        .immersionStyle(selection: .constant(.full), in: .full)
        
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
