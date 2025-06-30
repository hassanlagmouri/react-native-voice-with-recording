# react-native-voice-with-recording

A React Native native module that provides simultaneous voice recording and live transcription using platform-native speech-to-text engines.

## Features

- **Cross-platform support**: Works on both Android and iOS
- **Simultaneous recording and transcription**: Records audio to file while providing live transcription
- **Platform-native engines**: Uses Android's `SpeechRecognizer` and iOS's `SFSpeechRecognizer`
- **Real-time events**: Emits transcription events as they become available
- **Autolinking support**: Works with React Native 0.60+ autolinking

## Installation

```bash
npm install react-native-voice-with-recording
# or
yarn add react-native-voice-with-recording
```

### iOS Setup

1. **Add permissions to Info.plist**:
   ```xml
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>This app uses speech recognition to transcribe your voice.</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>This app uses the microphone to record your voice.</string>
   ```

2. **Install pods**:
   ```bash
   cd ios && pod install
   ```

### Android Setup

1. **Add permissions to AndroidManifest.xml**:
   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

2. **Request permissions at runtime** (for Android 6.0+):
   ```javascript
   import { PermissionsAndroid } from 'react-native';
   
   const requestMicrophonePermission = async () => {
     try {
       const granted = await PermissionsAndroid.request(
         PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
         {
           title: "Microphone Permission",
           message: "This app needs access to your microphone to record audio.",
           buttonNeutral: "Ask Me Later",
           buttonNegative: "Cancel",
           buttonPositive: "OK"
         }
       );
       return granted === PermissionsAndroid.RESULTS.GRANTED;
     } catch (err) {
       console.warn(err);
       return false;
     }
   };
   ```

## Usage

```javascript
import VoiceWithRecording, { onTranscript } from 'react-native-voice-with-recording';

// Subscribe to transcription events
const subscription = onTranscript((text) => {
  console.log('Transcription:', text);
});

// Start recording and transcription
const startRecording = async () => {
  try {
    await VoiceWithRecording.startVoiceRecording();
    console.log('Recording started');
  } catch (error) {
    console.error('Failed to start recording:', error);
  }
};

// Stop recording and get audio file path
const stopRecording = async () => {
  try {
    const audioFilePath = await VoiceWithRecording.stopVoiceRecording();
    console.log('Audio saved to:', audioFilePath);
  } catch (error) {
    console.error('Failed to stop recording:', error);
  }
};

// Clean up subscription when component unmounts
useEffect(() => {
  return () => {
    subscription.remove();
  };
}, []);
```

## API Reference

### Methods

#### `startVoiceRecording(): Promise<void>`
Starts simultaneous voice recording and transcription. Returns a promise that resolves when recording starts successfully.

**Throws:**
- `ALREADY_RECORDING`: If recording is already in progress
- `PERMISSION_DENIED`: If microphone permission is not granted
- `SPEECH_NOT_AVAILABLE`: If speech recognition is not available on the device
- `AUDIO_INIT_ERROR`: If audio initialization fails

#### `stopVoiceRecording(): Promise<string>`
Stops recording and transcription. Returns a promise that resolves with the path to the recorded audio file.

**Returns:** `Promise<string>` - Path to the recorded audio file

**Throws:**
- `NOT_RECORDING`: If no recording is in progress
- `STOP_ERROR`: If stopping the recording fails

### Events

#### `onTranscript(callback: (text: string) => void): EmitterSubscription`
Subscribe to transcription events. The callback is called whenever a new final transcription is available.

**Parameters:**
- `callback`: Function that receives the transcribed text

**Returns:** `EmitterSubscription` - Subscription object that can be used to unsubscribe

## Platform Details

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

## Permissions

### Required Permissions

**Android:**
- `RECORD_AUDIO`: For microphone access
- `INTERNET`: For speech recognition (may require internet connection)

**iOS:**
- Microphone access (requested automatically)
- Speech recognition access (requested automatically)

### Permission Request Flow

The module automatically requests permissions when `startVoiceRecording()` is called. Make sure to handle permission denial gracefully in your app.

## Error Handling

```javascript
const handleRecording = async () => {
  try {
    await VoiceWithRecording.startVoiceRecording();
  } catch (error) {
    switch (error.code) {
      case 'PERMISSION_DENIED':
        // Handle permission denial
        break;
      case 'SPEECH_NOT_AVAILABLE':
        // Handle speech recognition not available
        break;
      case 'ALREADY_RECORDING':
        // Handle already recording
        break;
      default:
        // Handle other errors
        break;
    }
  }
};
```

## Troubleshooting

### Common Issues

1. **"Speech recognition not available"**
   - Ensure the device supports speech recognition
   - Check internet connectivity (Android may require internet)

2. **"Permission denied"**
   - Ensure permissions are properly configured in manifest/Info.plist
   - Request permissions at runtime before calling the module

3. **Audio file not found**
   - Check that the recording completed successfully
   - Verify the file path returned by `stopVoiceRecording()`

### Debug Logs

Enable debug logging by checking the console output. The module logs important events and errors.

## License

MIT 