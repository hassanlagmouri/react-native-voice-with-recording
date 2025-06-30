package com.voicerecording;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Locale;

public class VoiceWithRecordingModule extends ReactContextBaseJavaModule {
    private static final String TAG = "VoiceWithRecording";
    private static final String EVENT_NAME = "onTranscript";
    
    private final ReactApplicationContext reactContext;
    private SpeechRecognizer speechRecognizer;
    private AudioRecord audioRecord;
    private File audioFile;
    private FileOutputStream audioFileOutputStream;
    private boolean isRecording = false;
    
    // Audio recording parameters
    private static final int SAMPLE_RATE = 16000;
    private static final int CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO;
    private static final int AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT;
    private static final int BUFFER_SIZE = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT);

    public VoiceWithRecordingModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    @NonNull
    public String getName() {
        return "VoiceWithRecordingModule";
    }

    @ReactMethod
    public void startVoiceRecording(Promise promise) {
        try {
            if (isRecording) {
                promise.reject("ALREADY_RECORDING", "Voice recording is already in progress");
                return;
            }

            // Check permissions
            if (!hasPermission(Manifest.permission.RECORD_AUDIO)) {
                promise.reject("PERMISSION_DENIED", "RECORD_AUDIO permission is required");
                return;
            }

            // Initialize audio file
            audioFile = new File(reactContext.getFilesDir(), "recorded_audio.pcm");
            audioFileOutputStream = new FileOutputStream(audioFile);

            // Initialize AudioRecord
            audioRecord = new AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE,
                CHANNEL_CONFIG,
                AUDIO_FORMAT,
                BUFFER_SIZE
            );

            if (audioRecord.getState() != AudioRecord.STATE_INITIALIZED) {
                promise.reject("AUDIO_INIT_ERROR", "Failed to initialize AudioRecord");
                return;
            }

            // Initialize SpeechRecognizer on main thread
            if (SpeechRecognizer.isRecognitionAvailable(reactContext)) {
                reactContext.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(reactContext);
                            speechRecognizer.setRecognitionListener(new RecognitionListener() {
                                @Override
                                public void onReadyForSpeech(Bundle bundle) {
                                    Log.d(TAG, "Speech recognizer ready");
                                }

                                @Override
                                public void onBeginningOfSpeech() {
                                    Log.d(TAG, "Speech beginning");
                                }

                                @Override
                                public void onRmsChanged(float v) {
                                    // Optional: handle volume changes
                                }

                                @Override
                                public void onBufferReceived(byte[] bytes) {
                                    // Optional: handle buffer
                                }

                                @Override
                                public void onEndOfSpeech() {
                                    Log.d(TAG, "Speech ended");
                                }

                                @Override
                                public void onError(int error) {
                                    Log.e(TAG, "Speech recognition error: " + error);
                                    // Restart recognition if it's not a permanent error
                                    if (isRecording && error != SpeechRecognizer.ERROR_NO_MATCH) {
                                        startSpeechRecognition();
                                    }
                                }

                                @Override
                                public void onResults(Bundle bundle) {
                                    ArrayList<String> results = bundle.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                                    if (results != null && !results.isEmpty()) {
                                        String transcript = results.get(0);
                                        sendTranscriptEvent(transcript);
                                    }
                                    
                                    // Restart recognition for continuous listening
                                    if (isRecording) {
                                        startSpeechRecognition();
                                    }
                                }

                                @Override
                                public void onPartialResults(Bundle bundle) {
                                    // Optional: handle partial results
                                }

                                @Override
                                public void onEvent(int i, Bundle bundle) {
                                    // Optional: handle events
                                }
                            });

                            // Start recording
                            audioRecord.startRecording();
                            startSpeechRecognition();
                            isRecording = true;

                            // Start audio recording thread
                            startAudioRecordingThread();

                            promise.resolve(null);
                        } catch (Exception e) {
                            Log.e(TAG, "Error starting voice recording", e);
                            promise.reject("START_ERROR", "Failed to start voice recording: " + e.getMessage());
                        }
                    }
                });
            } else {
                promise.reject("SPEECH_NOT_AVAILABLE", "Speech recognition is not available on this device");
                return;
            }
        } catch (Exception e) {
            Log.e(TAG, "Error starting voice recording", e);
            promise.reject("START_ERROR", "Failed to start voice recording: " + e.getMessage());
        }
    }

    @ReactMethod
    public void stopVoiceRecording(Promise promise) {
        try {
            if (!isRecording) {
                promise.reject("NOT_RECORDING", "No voice recording in progress");
                return;
            }

            isRecording = false;

            // Stop speech recognition on main thread
            if (speechRecognizer != null) {
                reactContext.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            speechRecognizer.stopListening();
                            speechRecognizer.destroy();
                            speechRecognizer = null;
                        } catch (Exception e) {
                            Log.e(TAG, "Error stopping speech recognizer", e);
                        }
                    }
                });
            }

            // Stop audio recording
            if (audioRecord != null) {
                audioRecord.stop();
                audioRecord.release();
                audioRecord = null;
            }

            // Close audio file
            if (audioFileOutputStream != null) {
                audioFileOutputStream.close();
                audioFileOutputStream = null;
            }

            String filePath = audioFile.getAbsolutePath();
            promise.resolve(filePath);
        } catch (Exception e) {
            Log.e(TAG, "Error stopping voice recording", e);
            promise.reject("STOP_ERROR", "Failed to stop voice recording: " + e.getMessage());
        }
    }

    private void startSpeechRecognition() {
        if (speechRecognizer != null) {
            reactContext.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        android.content.Intent intent = new android.content.Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
                        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
                        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault());
                        intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
                        intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1);
                        speechRecognizer.startListening(intent);
                    } catch (Exception e) {
                        Log.e(TAG, "Error starting speech recognition", e);
                    }
                }
            });
        }
    }

    private void startAudioRecordingThread() {
        new Thread(() -> {
            byte[] buffer = new byte[BUFFER_SIZE];
            
            while (isRecording && audioRecord != null && audioRecord.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING) {
                int readSize = audioRecord.read(buffer, 0, buffer.length);
                if (readSize > 0 && audioFileOutputStream != null) {
                    try {
                        audioFileOutputStream.write(buffer, 0, readSize);
                    } catch (IOException e) {
                        Log.e(TAG, "Error writing audio data", e);
                        break;
                    }
                }
            }
        }).start();
    }

    private void sendTranscriptEvent(String transcript) {
        WritableMap params = Arguments.createMap();
        params.putString("text", transcript);
        
        reactContext
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(EVENT_NAME, params);
    }

    private boolean hasPermission(String permission) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return ActivityCompat.checkSelfPermission(reactContext, permission) == PackageManager.PERMISSION_GRANTED;
        }
        return true;
    }
} 