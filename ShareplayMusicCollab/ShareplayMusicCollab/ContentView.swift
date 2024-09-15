//
//  ContentView.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

#if os(visionOS)
struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        TabView {
            InstrumentSelectAndShareplayView()
                .tabItem {
                    Label("Select your flavoure", systemImage: "guitars")
                }
            
            // Show MIDI Monitor View after instrument is selected
            MIDIMonitorView()
                .tabItem {
                    Label("MIDI monitor", systemImage: "music.quarternote.3")
                }
        }
        .padding()
        .environment(appModel)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
#endif
