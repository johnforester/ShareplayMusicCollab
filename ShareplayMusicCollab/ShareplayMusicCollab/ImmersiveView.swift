//
//  ImmersiveView.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import CoreMIDI

#if os(visionOS)
struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
      
    @State var sax: Entity?
    @State var guitar: Entity?
    @State var piano: Entity?

    @State var saxEmitter: Entity?
    @State var guitarEmitter: Entity?
    @State var pianoEmitter: Entity?

    
    var body: some View {
        let noteCollection = Entity()
        
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
                
                immersiveContentEntity.enumerateHierarchy { entity, stop in
                    print(entity.name)
                    if entity.name == "Saxophone" {
                        self.sax = entity
                        
                        entity.enumerateHierarchy { child, stop in
                            if child.name == "Emitter" {
                                self.saxEmitter = child
                                child.isEnabled = false
                            }
                        }
                    }
                    
                    if entity.name == "Guitar" {
                        self.guitar = entity
                        
                        entity.enumerateHierarchy { child, stop in
                            if child.name == "Emitter" {
                                self.guitarEmitter = child
                                child.isEnabled = false
                            }
                        }
                    }
                    
                    if entity.name == "Piano" {
                        self.piano = entity
                        
                        entity.enumerateHierarchy { child, stop in
                            if child.name == "Emitter" {
                                self.pianoEmitter = child
                                child.isEnabled = false
                            }
                        }
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
                    cube.name = "NoteCube_\(x)_\(z)"
                    noteCollection.addChild(cube)
                }
            }
//            // Add the noteCollection to the RealityKit scene content
            content.add(noteCollection)
        }.onChange(of: appModel.sharePlayMidiMessage) {
            triggerRandomCube(noteCollection: noteCollection)
        }.onChange(of: appModel.localMidiMessage) {
            if appModel.localMidiMessage?.noteOn == true {
                if appModel.localMidiMessage?.sampleName == SampleName.Guitar.rawValue {
                    guitarEmitter?.isEnabled = true
                } else if appModel.localMidiMessage?.sampleName == SampleName.Sax.rawValue {
                    saxEmitter?.isEnabled = true
                } else if appModel.localMidiMessage?.sampleName == SampleName.Piano.rawValue {
                    pianoEmitter?.isEnabled = true
                }
                // When the MIDI message changes, trigger a random cube
                triggerRandomCube(noteCollection: noteCollection)
            } else if appModel.localMidiMessage?.noteOn == false  {
                if appModel.localMidiMessage?.sampleName == SampleName.Guitar.rawValue {
                    guitarEmitter?.isEnabled = false
                } else if appModel.localMidiMessage?.sampleName == SampleName.Sax.rawValue {
                    saxEmitter?.isEnabled = false
                } else if appModel.localMidiMessage?.sampleName == SampleName.Piano.rawValue {
                    pianoEmitter?.isEnabled = false
                }
            }
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
    cube.physicsBody = PhysicsBodyComponent() // Set initial physics properties
    return cube
}

// Function to trigger a random cube's physics
func triggerRandomCube(noteCollection: Entity) {
    // Get all the children (cubes) from the noteCollection
    let cubes = noteCollection.children.compactMap { $0 as? ModelEntity }
    
    // Select a random cube
    if let randomCube = cubes.randomElement() {
        // Log the name of the triggered cube
        print("Triggered cube: \(randomCube.name)")
        
        // Apply dynamic physics to the randomly selected cube
        randomCube.physicsBody = PhysicsBodyComponent(
            massProperties: .default,
            material: .generate(friction: 0.1, restitution: 0.5),
            mode: .dynamic
        )
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}

#endif
