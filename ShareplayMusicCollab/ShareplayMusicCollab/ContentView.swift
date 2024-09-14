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
        VStack {
            // Show MIDI Monitor View after instrument is selected
            MIDIMonitorView()
                .environment(appModel)
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
