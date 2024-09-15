# Shareplay Music Collaboration Platform

## Project Overview

**ShareplayMusicCollab** is an innovative platform designed for musicians to collaborate remotely in real-time using augmented reality (AR). By leveraging the immersive capabilities of **Apple Vision Pro**, this platform creates an interactive music jamming experience where artists can connect and perform together, regardless of their physical locations.

### Key Features:
- **Remote Real-Time Collaboration**: Musicians can jam together seamlessly from different locations.
- **Augmented Reality (AR)**: Using Apple Vision Pro, the platform provides an engaging virtual environment for creating music.
- **Instrument Selection and MIDI Monitoring**: Allows musicians to select virtual instruments and monitor their inputs in real-time.

---

## Folder Structure

```
ShareplayMusicCollab/
│
├── ShareplayMusicCollab/
│   ├── ShareplayMusicCollabApp.swift        # Main entry point of the app
│   ├── SampleNames.swift                    # Handles the management of sound samples
│   ├── MIDIMonitorView.swift                # Provides a real-time view of MIDI inputs and activity
│   ├── JFSamplerSynth.swift                 # Synthesizer implementation for sound generation
│   ├── InstrumentSelectAndShareplayView.swift  # View for selecting instruments and initiating SharePlay
│   ├── ImmersiveView.swift                  # Main view for the immersive music collaboration experience
│   ├── Entity+Extensions.swift              # Extensions for managing entities within the app
│   ├── AppModel.swift                       # App data model and logic
│   └── ShareplayMusicCollab.entitlements    # Entitlement file for app permissions
│
├── Samples/                                 # Folder containing audio or MIDI sample files
```

---

## How to Use the Project

### 1. Prerequisites

- Xcode with support for **Swift** development
- **Apple Vision Pro** or a compatible AR device with support for **SharePlay**

### 2. Getting Started

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd ShareplayMusicCollab
   ```

2. **Open the Project in Xcode:**
   Open `ShareplayMusicCollab.xcodeproj` in Xcode to start developing.

3. **Build and Run:**
   Use Xcode's `build` command to compile and run the app on a supported AR device.

4. **SharePlay Setup:**
   In `InstrumentSelectAndShareplayView.swift`, choose an instrument and start a SharePlay session to begin collaborating with other musicians.

### 3. Key Files Breakdown

- **ShareplayMusicCollabApp.swift**: The main entry point of the app that configures and initializes the views.
- **SampleNames.swift**: Manages audio sample names for easy selection and retrieval.
- **MIDIMonitorView.swift**: Displays real-time monitoring of MIDI inputs for visual feedback.
- **JFSamplerSynth.swift**: Contains the sound generation logic, creating the foundation for virtual instruments.
- **InstrumentSelectAndShareplayView.swift**: UI view where users select instruments and initiate SharePlay sessions.
- **ImmersiveView.swift**: Provides the main AR experience where the real-time jamming session occurs.
- **AppModel.swift**: Contains the core logic and data for the application, managing user sessions and instrument selections.

---

## Contributing

We welcome contributions! To get started:

1. Fork the repository
2. Create a new feature branch
3. Submit a pull request with detailed explanations of your changes

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

