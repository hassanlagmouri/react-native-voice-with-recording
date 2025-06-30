import { EmitterSubscription } from 'react-native';
interface VoiceWithRecordingInterface {
    startVoiceRecording(): Promise<void>;
    stopVoiceRecording(): Promise<string>;
}
declare const _default: VoiceWithRecordingInterface;
export default _default;
export declare const onTranscript: (callback: (text: string) => void) => EmitterSubscription;
export type { EmitterSubscription };
