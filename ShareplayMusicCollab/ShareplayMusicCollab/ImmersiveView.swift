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
    
    static let particleQuery = EntityQuery(where: .has(ParticleEmitterComponent.self))

    @State var saxParticleEmitter: ParticleEmitterComponent?
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
                
                immersiveContentEntity.scene?.performQuery(Self.particleQuery).forEach { entity in
                    if entity.name == "SaxExmitter" {
                        self.saxParticleEmitter = entity.components[ParticleEmitterComponent.self]
                    }
                }
            }
        }.onChange(of: appModel.sharePlayMidiMessage) {
            // TODO changes received from Shareplay
        }.onChange(of: appModel.localMidiMessage) {
            if appModel.localMidiMessage?.noteOn == true && saxParticleEmitter != nil {
                saxParticleEmitter!.burst()
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
