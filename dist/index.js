import { NativeModules, NativeEventEmitter } from 'react-native';
const { VoiceWithRecordingModule } = NativeModules;
const eventEmitter = new NativeEventEmitter(VoiceWithRecordingModule);
export default VoiceWithRecordingModule;
export const onTranscript = (callback) => {
    return eventEmitter.addListener('onTranscript', callback);
};
