//
//  Instrument.swift
//  ShareplayMusicCollab
//
//  Created by Per Friis on 15/09/2024.
//

import Foundation

/// Holds all the relevant information about an instrument
struct Instrument: Identifiable, Equatable {
    var id: String { sampleName }
    var title: String
    var sampleName: String
    var usdzName: String
}


extension Instrument {
    /// List all the available instruments....
    static var all: [Instrument] = [.guitar, .piano, .saxophone]
    static let guitar = Instrument(title: "Guitar", sampleName: "GuitarC3", usdzName: "guitar")
    static let saxophone = Instrument(title: "Saxophone", sampleName: "SaxC3", usdzName: "sax")
    static let piano = Instrument(title: "Piano", sampleName: "PianoC3", usdzName: "piano")
}
