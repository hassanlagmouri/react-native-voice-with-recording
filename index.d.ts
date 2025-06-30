import { EmitterSubscription } from 'react-native';

declare interface VoiceWithRecordingInterface {
  startVoiceRecording(): Promise<void>;
  stopVoiceRecording(): Promise<string>;
}

declare const VoiceWithRecordingModule: VoiceWithRecordingInterface;

export default VoiceWithRecordingModule;

export declare function onTranscript(callback: (text: string) => void): EmitterSubscription;
export { EmitterSubscription }; 