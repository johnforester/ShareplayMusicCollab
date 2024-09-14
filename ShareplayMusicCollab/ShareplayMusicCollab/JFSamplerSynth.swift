//
//  JFSamplerSynth.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/13/24.
//

import Foundation
import AudioKit
import Tonic
import DunneAudioKit
import AVFoundation
import AVFAudio
import CDunneAudioKit

class JFSamplerSynth: ObservableObject {
    let engine = AudioEngine()
    let sampler = Sampler()
    
    func noteOn(note: MIDINoteNumber) {
        sampler.play(noteNumber: note, velocity: 127)
    }
    
    func noteOff(note: MIDINoteNumber) {
        sampler.stop(noteNumber: note)
    }
        
    let wavFilesAndMIDINotes: [(audioName: String, midiNoteNumber: Int32, frequency: Float)] = [

        ("C", 53, 174.61), // F
        ("C", 54, 185.00),
        ("C", 55, 196),
        ("C", 56, 207.65), // Ab
        ("C", 57, 220.0),
        ("C", 58, 233.08), // Bb
        ("C", 59, 246.94),
        ("C", 60, 261.63),
        ("C", 61, 277.18), // Db
        ("C", 62, 293.66),
        ("C", 63, 311.13), // Eb
        ("C", 64, 329.63),
        ("C", 65, 349.23), // F
        ("C", 66, 369.99),
        ("C", 67, 391.995),
        ("C", 68, 415.3), // Ab
        ("C", 69, 440.00),
        ("C", 70, 466.16), // Bb
        ("C", 71, 493.88),
        ("C", 72, 523.25),
        ("C", 73, 554.37), // Db
        ("C", 74, 587.33),
        ("C", 75, 622.25), // Eb
        ("C", 76, 659.25),
        ("C", 77, 698.46), // F
        ("C", 78, 739.989),
        ("C", 79, 783.99),
        ("C", 80, 830.61), // Ab
        ("C", 81, 880),
        ("C", 82, 932.23) // Bb
    ]
    
    func loadWAVs() {
        var filesAndSamplerData = [(sampleDescriptor: SampleDescriptor, file: AVAudioFile)]()
        
        for (audioName, midiNoteNumber, frequency) in wavFilesAndMIDINotes {
            do {
                if let fileURL = Bundle.main.url(forResource: audioName, withExtension: "wav") {
                    let audioFile = try AVAudioFile(forReading: fileURL)
                    
                    let fileAndSamplerData =
                    (SampleDescriptor(noteNumber: midiNoteNumber, noteFrequency: frequency, minimumNoteNumber: midiNoteNumber, maximumNoteNumber: midiNoteNumber, minimumVelocity: 0, maximumVelocity: 127, isLooping: false, loopStartPoint: 9, loopEndPoint: 1000, startPoint: 0.0, endPoint: 44100.0 * 1.0), audioFile)
                    filesAndSamplerData.append(fileAndSamplerData)
                }
            } catch {
                print("problem loading file")
            }
        }
        
        let sampleData = SamplerData(filesWithSampleDescriptors: filesAndSamplerData)
        sampleData.buildKeyMap()
                    
        sampler.update(data: sampleData)
        
        sampler.masterVolume = 0.5
        engine.output = sampler
        try! engine.start()
    }
    
    func playTest() {
        sampler.masterVolume = 0.2
        engine.output = sampler
        try! engine.start()
        
        noteOn(note: 79)
    }

    func stopTest() {
        sampler.stop(noteNumber: 69)
    }

    init() {
        loadWAVs()
    }
}
