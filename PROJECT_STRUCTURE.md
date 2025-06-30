# Project Structure

```
react-native-voice-with-recording/
├── android/                          # Android native code
│   ├── build.gradle                  # Android build configuration
│   ├── proguard-rules.pro           # ProGuard rules
│   └── src/main/
│       ├── AndroidManifest.xml      # Android permissions
│       └── java/com/voicerecording/
│           ├── VoiceWithRecordingModule.java    # Main Android module
│           └── VoiceWithRecordingPackage.java   # Android package config
├── ios/                              # iOS native code
│   ├── VoiceWithRecording.swift     # Main iOS module
│   ├── VoiceWithRecording-Bridging-Header.h    # iOS bridging header
│   └── Info.plist                   # iOS permissions
├── example/                          # Example React Native app
│   ├── App.tsx                      # Example usage
│   └── metro.config.js              # Metro configuration
├── index.ts                          # Main JavaScript interface
├── index.d.ts                        # TypeScript declarations
├── package.json                      # NPM package configuration
├── tsconfig.json                     # TypeScript configuration
├── README.md                         # Documentation
├── PROJECT_STRUCTURE.md              # This file
└── .gitignore                        # Git ignore rules
```

## Key Files Description

### JavaScript Interface
- **index.ts**: Main module interface with event emitter setup
- **index.d.ts**: TypeScript type definitions

### Android Implementation
- **VoiceWithRecordingModule.java**: Main Android module implementing simultaneous speech recognition and audio recording
- **VoiceWithRecordingPackage.java**: React Native package configuration for Android
- **AndroidManifest.xml**: Required permissions (RECORD_AUDIO, INTERNET)
- **build.gradle**: Android build configuration

### iOS Implementation
- **VoiceWithRecording.swift**: Main iOS module implementing simultaneous speech recognition and audio recording
- **VoiceWithRecording-Bridging-Header.h**: Bridging header for React Native integration
- **Info.plist**: Required permission descriptions for microphone and speech recognition

### Configuration
- **package.json**: NPM package with autolinking configuration
- **tsconfig.json**: TypeScript compiler options
- **README.md**: Comprehensive documentation and usage examples

### Example
- **example/App.tsx**: Complete React Native app demonstrating module usage
- **example/metro.config.js**: Metro bundler configuration for the example

## Native Module Features

### Android
- Uses `android.speech.SpeechRecognizer` for live transcription
- Uses `AudioRecord` for raw audio recording to `.pcm` file
- Audio format: 16kHz, mono, PCM 16-bit
- File location: `context.getFilesDir() + "/recorded_audio.pcm"`

### iOS
- Uses `SFSpeechRecognizer` for live transcription
- Uses `AVAudioEngine` with `installTap` for audio recording to `.wav` file
- Audio format: Native format from `AVAudioEngine.inputNode.outputFormat`
- File location: `NSTemporaryDirectory() + "/recorded_audio.wav"`

## API Methods

1. **startVoiceRecording()**: Promise<void>
   - Starts simultaneous recording and transcription
   - Requests permissions automatically
   - Emits transcription events via `onTranscript`

2. **stopVoiceRecording()**: Promise<string>
   - Stops recording and transcription
   - Returns path to recorded audio file

3. **onTranscript(callback)**: EmitterSubscription
   - Subscribe to real-time transcription events
   - Returns subscription for cleanup

## Installation Requirements

### For Users
1. Install via npm/yarn
2. Add permissions to AndroidManifest.xml and Info.plist
3. Run `pod install` for iOS
4. Request runtime permissions (Android 6.0+)

### For Development
1. Clone repository
2. Run `npm install` or `yarn install`
3. For iOS: `cd ios && pod install`
4. Build and test on both platforms 