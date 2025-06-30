import { NativeModules, NativeEventEmitter, EmitterSubscription } from 'react-native';

const { VoiceWithRecordingModule } = NativeModules;

interface VoiceWithRecordingInterface {
  startVoiceRecording(): Promise<void>;
  stopVoiceRecording(): Promise<string>;
}

const eventEmitter = new NativeEventEmitter(VoiceWithRecordingModule);

export default VoiceWithRecordingModule as VoiceWithRecordingInterface;

export const onTranscript = (callback: (text: string) => void): EmitterSubscription => {
  return eventEmitter.addListener('onTranscript', callback);
};

export type { EmitterSubscription }; 