//
//  MIDIMonitorView.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/13/24.
//

import AudioKit
import AudioKitEX
import CoreMIDI
import Foundation
import SwiftUI
import CoreBluetooth

// struct representing last data received of each type







struct MIDIMonitorView: View {
    @StateObject private var conductor = MIDIMonitorConductor()
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack {
            midiReceivedIndicator
            List {
                Section("Note On") {
                    HStack {
                        Text("Note Number")
                        Spacer()
                        Text("\(conductor.data.noteOn)")
                    }
                    HStack {
                        Text("Note Velocity")
                        Spacer()
                        Text("\(conductor.data.velocity)")
                    }
                }
                .foregroundColor(conductor.midiEventType == .noteOn ? .blue : .primary)
                Section("Note Off") {
                    HStack {
                        Text("Note Number")
                        Spacer()
                        Text("\(conductor.data.noteOff)")
                    }
                }
                .foregroundColor(conductor.midiEventType == .noteOff ? .blue : .primary)
                Section("Continuous Controller") {
                    HStack {
                        Text("Controller Number")
                        Spacer()
                        Text("\(conductor.data.controllerNumber)")
                    }
                    HStack {
                        Text("Continuous Value")
                        Spacer()
                        Text("\(conductor.data.controllerValue)")
                    }
                }
                .foregroundColor(conductor.midiEventType == .continuousControl ? .blue : .primary)
                Section("Program Change") {
                    HStack {
                        Text("Program Number")
                        Spacer()
                        Text("\(conductor.data.programChange)")
                    }
                }
                .foregroundColor(conductor.midiEventType == .programChange ? .blue : .primary)
                Section {
                    HStack {
                        Text("Selected MIDI Channel")
                        Spacer()
                        Text("\(conductor.data.channel)")
                    }
                }
            }
            .onAppear {
                conductor.start()
            }
            .onDisappear {
                conductor.stop()
            }
        } .onChange(of: conductor.midiEventType) {
            if conductor.midiEventType == MIDIEventType.noteOn {
                let message = MidiNoteMessage(noteNumber: Int32(conductor.data.noteOn),
                                              velocity: Int32(conductor.data.velocity),
                                              noteOn: true,
                                              sampleName: (appModel.instrument ?? Instrument.default).sampleName)
                appModel.sendMidiMessage(message: message)
                appModel.localMidiMessage = message
            }  else if conductor.midiEventType == MIDIEventType.noteOff {
                let message = MidiNoteMessage(noteNumber: Int32(conductor.data.noteOff),
                                              velocity: 0,
                                              noteOn: false,
                                              sampleName: (appModel.instrument ?? Instrument.default).sampleName)
                appModel.sendMidiMessage(message: message)
                appModel.localMidiMessage = message
            }
        }
        .onChange(of: appModel.sharePlayMidiMessage) {
            if let midiMessage = appModel.sharePlayMidiMessage {
                let noteNumber = midiMessage.noteNumber
                let noteOn = midiMessage.noteOn
                let velocity = midiMessage.velocity
                
                if let sampler = conductor.sharePlaySamplers.first(where: { $0.filename == midiMessage.sampleName }) {
                    if noteOn {
                        sampler.noteOn(note: MIDINoteNumber(noteNumber),
                                       velocity: MIDIVelocity(velocity))
                    } else {
                        sampler.noteOff(note: MIDINoteNumber(noteNumber))
                    }
                }
            }
        }
        
        .onChange(of: appModel.instrument) {
            conductor.setSampleFileName((appModel.instrument ?? Instrument.default).sampleName)
        }
    }
    
    var midiReceivedIndicator: some View {
        HStack(spacing: 15) {
            Text("MIDI In")
                .fontWeight(.medium)
            Circle()
                .strokeBorder(.blue.opacity(0.5), lineWidth: 1)
                .background(Circle().fill(conductor.isShowingMIDIReceived ? .blue : .blue.opacity(0.2)))
                .frame(maxWidth: 20, maxHeight: 20)
            Spacer()
            Text("Toggle On")
                .fontWeight(.medium)
            Circle()
                .strokeBorder(.red.opacity(0.5), lineWidth: 1)
                .background(Circle().fill(conductor.isToggleOn ? .red : .red.opacity(0.2)))
                .frame(maxWidth: 20, maxHeight: 20)
                .shadow(color: conductor.isToggleOn ? .red : .clear, radius: 5)
        }
        .padding([.top, .horizontal], 20)
        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .leading)
    }
}
