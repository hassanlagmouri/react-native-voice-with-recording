import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  Alert,
  PermissionsAndroid,
  Platform,
} from 'react-native';
import VoiceWithRecording, { onTranscript, EmitterSubscription } from 'react-native-voice-with-recording';

const App = () => {
  const [isRecording, setIsRecording] = useState(false);
  const [transcript, setTranscript] = useState('');
  const [audioFilePath, setAudioFilePath] = useState('');

  useEffect(() => {
    // Subscribe to transcription events
    const subscription = onTranscript((text) => {
      setTranscript(text);
      console.log('New transcription:', text);
    });

    // Cleanup subscription on unmount
    return () => {
      subscription.remove();
    };
  }, []);

  const requestPermissions = async () => {
    if (Platform.OS === 'android') {
      try {
        const granted = await PermissionsAndroid.request(
          PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
          {
            title: 'Microphone Permission',
            message: 'This app needs access to your microphone to record audio.',
            buttonNeutral: 'Ask Me Later',
            buttonNegative: 'Cancel',
            buttonPositive: 'OK',
          }
        );
        return granted === PermissionsAndroid.RESULTS.GRANTED;
      } catch (err) {
        console.warn(err);
        return false;
      }
    }
    return true; // iOS handles permissions automatically
  };

  const startRecording = async () => {
    try {
      const hasPermission = await requestPermissions();
      if (!hasPermission) {
        Alert.alert('Permission Denied', 'Microphone permission is required to record audio.');
        return;
      }

      await VoiceWithRecording.startVoiceRecording();
      setIsRecording(true);
      setTranscript('');
      setAudioFilePath('');
      console.log('Recording started');
    } catch (error: any) {
      console.error('Failed to start recording:', error);
      Alert.alert('Error', `Failed to start recording: ${error.message}`);
    }
  };

  const stopRecording = async () => {
    try {
      const filePath = await VoiceWithRecording.stopVoiceRecording();
      setIsRecording(false);
      setAudioFilePath(filePath);
      console.log('Recording stopped, audio saved to:', filePath);
      Alert.alert('Success', `Audio saved to: ${filePath}`);
    } catch (error: any) {
      console.error('Failed to stop recording:', error);
      Alert.alert('Error', `Failed to stop recording: ${error.message}`);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Voice Recording with Transcription</Text>
        
        <View style={styles.statusContainer}>
          <Text style={styles.statusLabel}>Status:</Text>
          <Text style={[styles.status, { color: isRecording ? '#4CAF50' : '#F44336' }]}>
            {isRecording ? 'Recording' : 'Stopped'}
          </Text>
        </View>

        <View style={styles.transcriptContainer}>
          <Text style={styles.transcriptLabel}>Live Transcription:</Text>
          <Text style={styles.transcriptText}>
            {transcript || 'Start recording to see transcription...'}
          </Text>
        </View>

        {audioFilePath ? (
          <View style={styles.fileContainer}>
            <Text style={styles.fileLabel}>Audio File:</Text>
            <Text style={styles.filePath}>{audioFilePath}</Text>
          </View>
        ) : null}

        <TouchableOpacity
          style={[styles.button, { backgroundColor: isRecording ? '#F44336' : '#4CAF50' }]}
          onPress={isRecording ? stopRecording : startRecording}
        >
          <Text style={styles.buttonText}>
            {isRecording ? 'Stop Recording' : 'Start Recording'}
          </Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  content: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 30,
    color: '#333',
  },
  statusContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
    padding: 15,
    backgroundColor: 'white',
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statusLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginRight: 10,
    color: '#333',
  },
  status: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  transcriptContainer: {
    marginBottom: 20,
    padding: 15,
    backgroundColor: 'white',
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
    minHeight: 100,
  },
  transcriptLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 10,
    color: '#333',
  },
  transcriptText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  fileContainer: {
    marginBottom: 20,
    padding: 15,
    backgroundColor: 'white',
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  fileLabel: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 10,
    color: '#333',
  },
  filePath: {
    fontSize: 12,
    color: '#666',
    fontFamily: 'monospace',
  },
  button: {
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
  },
});

export default App; 