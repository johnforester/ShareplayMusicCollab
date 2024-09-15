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
        let noteCollection = Entity()
        
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
            // grid of 7 cubes across (x-axis) and 3 cubes deep (z-axis) representing 7 unique natural notes and 3 instruments
            for z in stride(from: -0.5, through: 0.5, by: 0.5) { // 3 positions: -0.5, 0.0, 0.5
                for x in stride(from: -0.75, through: 0.75, by: 0.25) { // 7 positions: -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75
                    let cube: ModelEntity = generateRandomCube()
                    cube.position.y = 1.75 // Adjust the y-position as needed
                    cube.position.x = Float(x)
                    cube.position.z = Float(z)
                    noteCollection.addChild(cube)
                }
            }
            content.add(noteCollection)
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
func getRandomColor() -> UIColor {
    let red = CGFloat.random(in: 0...1)
    let green = CGFloat.random(in: 0...1)
    let blue = CGFloat.random(in: 0...1)
    let alpha = CGFloat.random(in: 0.6...1)
    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    return color
}

func generateRandomCube() -> ModelEntity {
    // Define a random size for the cube between 0.05 and 0.09 units
    let size = Float.random(in: 0.05...0.09)
    
    // Generate the cube mesh with the random size
    let cube = ModelEntity(mesh: .generateBox(size: size))
    
    // Create a material with random color, roughness, and metallic properties
    let material = SimpleMaterial(
        color: getRandomColor(),
        roughness: MaterialScalarParameter(floatLiteral: Float.random(in: 0.0...1.0)),
        isMetallic: Bool.random()
    )
    
    // Apply the material to the cube
    cube.model?.materials = [material]
    
    // Generate collision shapes for physics interactions
    cube.generateCollisionShapes(recursive: true)
    
    // Add hover effect component (assuming HoverEffectComponent is defined elsewhere)
    cube.components.set(HoverEffectComponent())
    
    // Set input target component to handle direct and indirect inputs
    cube.components.set(
        InputTargetComponent(allowedInputTypes: [.direct, .indirect])
    )
    
    return cube
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}

#endif
