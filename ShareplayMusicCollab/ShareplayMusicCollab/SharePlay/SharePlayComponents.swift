//
//  SharePlayComponents.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/14/24.
//

import GroupActivities
import SwiftUI
import RealityFoundation
import Spatial

struct MusicCollabShareplay: GroupActivity, Transferable {
    static var activityIdentifier: String = "com.musicheroes.shareplay"

    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Play music together"
        metadata.subtitle = "Let's jam"
        metadata.supportsContinuationOnTV = false
       // metadata.previewImage = UIImage(named: "App_Icon")?.cgImage

        return metadata
    }
}

/// A message that contains midi data
struct MidiNoteMessage: Codable, Equatable {
    let noteNumber: Int32
    let velocity: Int32
    let noteOn: Bool
    
    enum codingKeys: CodingKey {
        case noteNumber
        case velocity
        case noteOn
    }
}
