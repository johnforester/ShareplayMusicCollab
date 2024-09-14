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
    @State private var instrumentSelected = false  // Track if the instrument is selected

    var body: some View {
        VStack {
            if instrumentSelected {
                // Show MIDI Monitor View after instrument is selected
                MIDIMonitorView()
                    .environment(appModel)
            } else {
                // Show Instrument Selection first
                InstrumentSelectAndShareplayView()
            }
            //ToggleImmersiveSpaceButton()
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
#endif
