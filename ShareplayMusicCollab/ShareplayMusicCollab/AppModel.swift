//
//  AppModel.swift
//  ShareplayMusicCollab
//
//  Created by John Forester on 9/13/24.
//

import SwiftUI
import Observation
import GroupActivities
import Combine

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    /// current immersive state
    var immersiveSpaceState = ImmersiveSpaceState.open
    
    /// Holds the current instrument, could be optional as a part of the flow...
    /// - note: it could also be persisted in a userdefault or something like that, for UX considerations
    var instrument: Instrument?
    
    /// SharePlay Connection
    var session: GroupSession<MusicCollabShareplay>? = nil
    private var subscriptions = Set<AnyCancellable>()
    var reliableMessenger: GroupSessionMessenger?
    var unreliableMessenger: GroupSessionMessenger?
    var activity: MusicCollabShareplay?
    var sessionState: GroupSession<MusicCollabShareplay>.State?
    
    /// SharePlay Message Sync
    var sharePlayMidiMessage: MidiNoteMessage?
    var localMidiMessage: MidiNoteMessage?
        
#if os(visionOS)
    var coordinator: SystemCoordinator?
#endif
    
    func configureGroupSessions() {
        Task {
            for await newSession in MusicCollabShareplay.sessions() {
                print("New GroupActivities session", newSession)
                
                session = newSession
                
#if os(visionOS)
                
                // Spatial coordination.
                if let coordinator = await newSession.systemCoordinator {
                    var config = SystemCoordinator.Configuration()
                    config.spatialTemplatePreference = .conversational
                    config.supportsGroupImmersiveSpace = true
                    coordinator.configuration = config
                    
                    Task.detached { @MainActor in
                        for await state in coordinator.localParticipantStates {
                            if state.isSpatial {
                              
                                print("Spatial Sharing Available")
                            } else {
                                print("Spatial Sharing Not Available")
                            }
                        }
                    }
                    
                    self.coordinator = coordinator
                }
#endif
                
                newSession.$activeParticipants
                    .sink {
                        if $0.count == 1 {
                            print("one participant")
                            Task {
                                try? await Task.sleep(for: .seconds(0.45))
                            }
                        } else {
                            print("\($0.count) participants")
                        }
                    }
                    .store(in: &self.subscriptions)
                
                reliableMessenger = GroupSessionMessenger(session: newSession, deliveryMode: .reliable)
                unreliableMessenger = GroupSessionMessenger(session: newSession, deliveryMode: .unreliable)
                
                print("messengers created")
                
                newSession.$state.sink { [self] state in
                    //TODO handle other state changes?
                    
                    print("shareplay state: \(state)")
                    
                    if case .invalidated = state {
                        // TODO reset viewModel?
                        
                        print("shareplay invalidated")
                        reliableMessenger = nil
                        session = nil
                    }
                    
                    self.sessionState = state
                }
                .store(in: &subscriptions)
                
                // Handle switching selected model in SharePlay
                Task {
                    guard let reliableMessenger = reliableMessenger else {
                        print("unable to get reliable messenger")
                        return
                    }
                    
                    // receive midi data
                    for await (message, _) in reliableMessenger.messages(of: MidiNoteMessage.self) {
                        print("shareplay message received: \(message)")
                        self.sharePlayMidiMessage = message
                    }
                }
                
                newSession.join()
            }
        }
    }
    
    func startSession() async throws {
        activity = MusicCollabShareplay()
        let activationSuccess = try await activity?.activate()
        print("Group Activities session activation: ", activationSuccess ?? "unknown status")
    }
    
    public func sendMidiMessage(message: MidiNoteMessage) {
        print("shareplay attemtping sending midi message")
        
        if let session = session, let reliableMessenger = reliableMessenger {
            let everyoneElse = session.activeParticipants.subtracting([session.localParticipant])
            
            print("shareplay sending message: \(message) to \(everyoneElse)")
            
            reliableMessenger.send(message, to: .only(everyoneElse)) { error in
                if let error = error { print("Message failure:", error) }
            }
        }
    }
    
    
    let immersiveSpaceID = "ImmersiveSpace"
    
    /// List of valid immersive spaces..
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
}
