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
    var filename: String
    
    struct SampleData
    {
        let audioName: String
        let midiNoteNumber: Int32
        let minMidiNoteNumber: Int32
        let maxMidiNoteNumber: Int32
        let frequency: Float
    }
    
    init(filename: String) {
        self.filename = filename
        loadWAVs()
    }
    
    func noteOn(note: MIDINoteNumber) {
        sampler.play(noteNumber: note, velocity: 127)
    }
    
    func noteOff(note: MIDINoteNumber) {
        sampler.stop(noteNumber: note)
    }
        
    func wavFilesAndMIDINotes() -> [SampleData] {
        return [SampleData(audioName: filename,
                           midiNoteNumber: 60,
                           minMidiNoteNumber: 0,
                           maxMidiNoteNumber: 127,
                           frequency: 261.63)]
        // TODO ability to add more audio files, notes, specify instrument/note/octave
    }
    
    func loadWAVs() {
        var filesAndSamplerData = [(sampleDescriptor: SampleDescriptor, file: AVAudioFile)]()
        
        for sampleData in wavFilesAndMIDINotes() {
            do {
                if let fileURL = Bundle.main.url(forResource: sampleData.audioName, withExtension: "wav") {
                    let audioFile = try AVAudioFile(forReading: fileURL)
                    
                    let fileAndSamplerData =
                    (SampleDescriptor(noteNumber: sampleData.midiNoteNumber, noteFrequency: sampleData.frequency, minimumNoteNumber: sampleData.minMidiNoteNumber, maximumNoteNumber: sampleData.maxMidiNoteNumber, minimumVelocity: 0, maximumVelocity: 127, isLooping: false, loopStartPoint: 9, loopEndPoint: 1000, startPoint: 0.0, endPoint: 44100.0 * 1.0), audioFile)
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
}
