//
//  MIDIMonitorConductor.swift
//  ShareplayMusicCollab
//
//  Created by Per Friis on 15/09/2024.
//

import Foundation
import AudioKit
import AudioKitEX
import CoreMIDI
import CoreBluetooth
import SwiftUI
import OSLog

class MIDIMonitorConductor: NSObject, ObservableObject, MIDIListener {
    @Environment(AppModel.self) private var appModel
    
    /// Used to "prime" the BLE connection to MIDI Bluetooth devices....
    private var centralManager: CBCentralManager!
    internal let debugLog = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "\(MIDIMonitorConductor.self)")
    
    let sampler = JFSamplerSynth(filename: .Sax)
    
    let sharePlaySamplers = [JFSamplerSynth(filename: .Sax),
                             JFSamplerSynth(filename: .Guitar),
                             JFSamplerSynth(filename: .Piano)]
    
    let midi = MIDI()
    @Published var data = MIDIMonitorData()
    @Published var isShowingMIDIReceived: Bool = false
    @Published var isToggleOn: Bool = false
    @Published var oldControllerValue: Int = 0
    @Published var midiEventType: MIDIEventType = .none
    
    
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func start() {
        debugLog.info("inputNames:\(self.midi.inputNames.formatted())")
        debugLog.info("inputUUIDs:\(self.midi.inputUIDs.map{$0.description}.formatted())")
        midi.openInput(name: "Bluetooth")
        midi.openInput()
        midi.addListener(self)
    }
    
    func stop() {
        midi.closeAllInputs()
    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID _: MIDIUniqueID?,
                            timeStamp _: MIDITimeStamp?)
    {
        debugLog.info("noteNumber \(noteNumber) \(noteNumber)")
        debugLog.info("velocity \(velocity) \(velocity)")
        DispatchQueue.main.async {
            self.midiEventType = .noteOn
            self.isShowingMIDIReceived = true
            self.data.noteOn = Int(noteNumber)
            self.data.velocity = Int(velocity)
            self.data.channel = Int(channel)
            if self.data.velocity == 0 {
                withAnimation(.easeOut(duration: 0.4)) {
                    self.isShowingMIDIReceived = false
                }
            }
            
            self.sampler.noteOn(note: noteNumber, velocity: velocity)
        }
    }
    
    func setSampleFileName(_ name: String) {
        self.sampler.setFile(filename: name)
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID _: MIDIUniqueID?,
                             timeStamp _: MIDITimeStamp?)
    {
        debugLog.info("noteNumber \(noteNumber) \(noteNumber)")
        debugLog.info("velocity \(velocity) \(velocity)")
        DispatchQueue.main.async {
            self.midiEventType = .noteOff
            self.isShowingMIDIReceived = false
            self.data.noteOff = Int(noteNumber)
            self.data.velocity = Int(velocity)
            self.data.channel = Int(channel)
            
            self.sampler.noteOff(note: noteNumber)
        }
    }
    
    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        debugLog.info("controller \(controller) \(value)")
        DispatchQueue.main.async {
            self.midiEventType = .continuousControl
            self.isShowingMIDIReceived = true
            self.data.controllerNumber = Int(controller)
            self.data.controllerValue = Int(value)
            self.oldControllerValue = Int(value)
            self.data.channel = Int(channel)
            if self.oldControllerValue == Int(value) {
                // Fade out the MIDI received indicator.
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.4)) {
                        self.isShowingMIDIReceived = false
                    }
                }
            }
            // Show the solid color indicator when the CC value is toggled from 0 to 127
            // Otherwise toggle it off when the CC value is toggled from 127 to 0
            // Useful for stomp box and on/off UI toggled states
            if value == 127 {
                DispatchQueue.main.async {
                    self.isToggleOn = true
                }
            } else {
                // Fade out the Toggle On indicator.
                DispatchQueue.main.async {
                    self.isToggleOn = false
                }
            }
        }
    }
    
    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        debugLog.info("received after touch")
        DispatchQueue.main.async {
            self.data.afterTouch = Int(pressure)
            self.data.channel = Int(channel)
        }
    }
    
    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        debugLog.info("recv'd after touch \(noteNumber)")
        DispatchQueue.main.async {
            self.data.afterTouchNoteNumber = Int(noteNumber)
            self.data.afterTouch = Int(pressure)
            self.data.channel = Int(channel)
        }
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID _: MIDIUniqueID?,
                                timeStamp _: MIDITimeStamp?)
    {
        debugLog.info("midi wheel \(pitchWheelValue)")
        DispatchQueue.main.async {
            self.data.pitchWheelValue = Int(pitchWheelValue)
            self.data.channel = Int(channel)
        }
    }
    
    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID _: MIDIUniqueID?,
                                   timeStamp _: MIDITimeStamp?)
    {
        debugLog.info("Program change \(program)")
        DispatchQueue.main.async {
            self.midiEventType = .programChange
            self.isShowingMIDIReceived = true
            self.data.programChange = Int(program)
            self.data.channel = Int(channel)
            // Fade out the MIDI received indicator, since program changes don't have a MIDI release/note off.
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.4)) {
                    self.isShowingMIDIReceived = false
                }
            }
        }
    }
    
    func receivedMIDISystemCommand(_: [MIDIByte],
                                   portID _: MIDIUniqueID?,
                                   timeStamp _: MIDITimeStamp?)
    {
        //        print("sysex")
    }
    
    func receivedMIDISetupChange() {
        // Do nothing
    }
    
    func receivedMIDIPropertyChange(propertyChangeInfo _: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }
    
    func receivedMIDINotification(notification _: MIDINotification) {
        // Do nothing
    }
}


// MARK: - CBCentralManagerDelegate
extension MIDIMonitorConductor: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [Self.midiService], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        debugLog.info("Discovered \(peripheral.name ?? "Unknown")")
    }
    

    static let midiService = CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")
}
