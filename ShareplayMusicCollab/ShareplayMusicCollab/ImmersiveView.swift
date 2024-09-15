//
//  ImmersiveView.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

#if os(visionOS)
struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    
    @State var saxParticleEmitter: ParticleEmitterComponent?
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
                
                immersiveContentEntity.enumerateHierarchy { entity, stop in
                    print(entity.name)
                    if entity.name == "SaxEmitter" {
                        self.saxParticleEmitter = entity.components[ParticleEmitterComponent.self]
                    }
                }
            }
        }.onChange(of: appModel.sharePlayMidiMessage) {
            // TODO changes received from Shareplay
        }.onChange(of: appModel.localMidiMessage) {
            if appModel.localMidiMessage?.noteOn == true && saxParticleEmitter != nil {
                saxParticleEmitter!.simulationState = .play
            } else if saxParticleEmitter != nil {
                saxParticleEmitter!.simulationState = .stop
            }
            // TODO effect for other instruments
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}

#endif
