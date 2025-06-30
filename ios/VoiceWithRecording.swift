import Foundation
import AVFoundation
import Speech
import React

@objc(VoiceWithRecordingModule)
class VoiceWithRecordingModule: RCTEventEmitter {
    
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioFile: AVAudioFile?
    private var isRecording = false
    
    override init() {
        super.init()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    }
    
    override func supportedEvents() -> [String]! {
        return ["onTranscript"]
    }
    
    @objc
    func startVoiceRecording(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if isRecording {
            reject("ALREADY_RECORDING", "Voice recording is already in progress", nil)
            return
        }
        
        // Request permissions
        requestPermissions { [weak self] granted in
            guard let self = self else { return }
            
            if !granted {
                reject("PERMISSION_DENIED", "Microphone and speech recognition permissions are required", nil)
                return
            }
            
            DispatchQueue.main.async {
                self.setupAudioSession()
                self.startRecording(resolve: resolve, rejecter: reject)
            }
        }
    }
    
    @objc
    func stopVoiceRecording(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        if !isRecording {
            reject("NOT_RECORDING", "No voice recording in progress", nil)
            return
        }
        
        isRecording = false
        
        // Stop audio engine
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        
        // Stop recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Finalize audio file
        audioFile = nil
        
        // Get the file path
        let documentsPath = NSTemporaryDirectory()
        let audioFilePath = (documentsPath as NSString).appendingPathComponent("recorded_audio.wav")
        
        resolve(audioFilePath)
    }
    
    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var microphoneGranted = false
        var speechGranted = false
        
        // Request microphone permission
        group.enter()
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            microphoneGranted = granted
            group.leave()
        }
        
        // Request speech recognition permission
        group.enter()
        SFSpeechRecognizer.requestAuthorization { status in
            speechGranted = (status == .authorized)
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(microphoneGranted && speechGranted)
        }
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true, options: [])
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func startRecording(resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            reject("SPEECH_NOT_AVAILABLE", "Speech recognition is not available on this device", nil)
            return
        }
        
        // Initialize audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            reject("AUDIO_INIT_ERROR", "Failed to initialize audio engine", nil)
            return
        }
        
        // Setup audio file
        let documentsPath = NSTemporaryDirectory()
        let audioFilePath = (documentsPath as NSString).appendingPathComponent("recorded_audio.wav")
        let audioFileURL = URL(fileURLWithPath: audioFilePath)
        
        let audioFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        
        do {
            audioFile = try AVAudioFile(forWriting: audioFileURL, settings: audioFormat.settings)
        } catch {
            reject("FILE_ERROR", "Failed to create audio file: \(error.localizedDescription)", error)
            return
        }
        
        // Setup recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            reject("RECOGNITION_ERROR", "Failed to create recognition request", nil)
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Install tap on input node
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: audioFormat) { [weak self] buffer, _ in
            guard let self = self else { return }
            
            // Write to audio file
            do {
                try self.audioFile?.write(from: buffer)
            } catch {
                print("Error writing to audio file: \(error)")
            }
            
            // Send to speech recognizer
            self.recognitionRequest?.append(buffer)
        }
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Speech recognition error: \(error)")
                return
            }
            
            if let result = result, result.isFinal {
                let transcript = result.bestTranscription.formattedString
                self.sendTranscriptEvent(transcript)
            }
        }
        
        // Start audio engine
        do {
            try audioEngine.start()
            isRecording = true
            resolve(nil)
        } catch {
            reject("START_ERROR", "Failed to start audio engine: \(error.localizedDescription)", error)
        }
    }
    
    private func sendTranscriptEvent(_ transcript: String) {
        let body: [String: Any] = ["text": transcript]
        sendEvent(withName: "onTranscript", body: body)
    }
} 