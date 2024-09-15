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
      
    @State var sax: Entity?
    @State var guitar: Entity?
    @State var piano: Entity?

    @State var saxEmitter: Entity?
    @State var guitarEmitter: Entity?
    @State var pianoEmitter: Entity?

    
    var body: some View {
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
        }.onChange(of: appModel.sharePlayMidiMessage) {
            if appModel.sharePlayMidiMessage?.noteOn == true {
                if appModel.sharePlayMidiMessage?.sampleName == SampleName.Guitar.rawValue {
                    guitarEmitter?.isEnabled = true
                } else if appModel.sharePlayMidiMessage?.sampleName == SampleName.Sax.rawValue {
                    saxEmitter?.isEnabled = true
                } else if appModel.sharePlayMidiMessage?.sampleName == SampleName.Piano.rawValue {
                    pianoEmitter?.isEnabled = true
                }
            } else if appModel.sharePlayMidiMessage?.noteOn == false  {
                if appModel.sharePlayMidiMessage?.sampleName == SampleName.Guitar.rawValue {
                    guitarEmitter?.isEnabled = false
                } else if appModel.sharePlayMidiMessage?.sampleName == SampleName.Sax.rawValue {
                    saxEmitter?.isEnabled = false
                } else if appModel.sharePlayMidiMessage?.sampleName == SampleName.Piano.rawValue {
                    pianoEmitter?.isEnabled = false
                }
            }
        }.onChange(of: appModel.localMidiMessage) {
            if appModel.localMidiMessage?.noteOn == true {
                if appModel.localMidiMessage?.sampleName == SampleName.Guitar.rawValue {
                    guitarEmitter?.isEnabled = true
                } else if appModel.localMidiMessage?.sampleName == SampleName.Sax.rawValue {
                    saxEmitter?.isEnabled = true
                } else if appModel.localMidiMessage?.sampleName == SampleName.Piano.rawValue {
                    pianoEmitter?.isEnabled = true
                }
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

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}

#endif
