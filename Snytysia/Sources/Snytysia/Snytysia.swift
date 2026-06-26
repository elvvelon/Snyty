import CoreML
import UIKit
import SoundAnalysis
import AVFoundation
import Combine
import os


public final class Snytysia: NSObject, SNResultsObserving, @unchecked Sendable {
    @MainActor public static let classifier = Snytysia()
    public let sessionPublisher = CurrentValueSubject<SleepSession?, Never>(nil)
    public let statePublisher = CurrentValueSubject<State, Never>(.inactive)
    
    // Analizing
    private var audioEngine = AVAudioEngine()
    private var analyzer: SNAudioStreamAnalyzer?
    private var request: SNClassifySoundRequest?
    private let logger = Logger(subsystem: "com.elvvelon.Snytysia", category: "ML")
    private var delayedTask: Task<Void, Never>?
    private var inputFormat: AVAudioFormat?
    
    // State & Locks
    private let lock = NSLock()
    private var activeAudioFile: AVAudioFile?
    private var audioBuffer: SleepAudioBuffer?
    private let maxRecordingDuration: TimeInterval = 300.0
    private let maxRecordingsPerSession: Int = 30
    private var savedFilesCount = 0
    
    public enum State: Equatable {
        case tracking, delayed(Date, TimeInterval), inactive
    }
    
    // Events
    private var currentSession: SleepSession?
    private var lastEventTime: Date = Date.distantPast
    private var lastCoughTime: Date = Date.distantPast
    private var lastNoiseTime: Date?
    private let counterMap: [String: WritableKeyPath<SleepSession, Int>] = ["snoring": \.snoreCount, "sleepTalk": \.talkCount]
    
    // Records
    private var currentRecordingStartTime: Date?
    private var currentRecordingType: SleepEventType?
    private var currentAudioFileName: String?
    private var audioRecordsDirectory: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let targetDirectory = documentsDirectory.appendingPathComponent("SleepRecordings", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: targetDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: targetDirectory, withIntermediateDirectories: true)
            } catch {
                print("Error creating directory for sleep events recordings: \(error)")
            }
        }
        
        return targetDirectory
    }
    
    // MARK: - Setup
    override init() {
        super.init()
        setupModel()
        observeAppTermination()
    }

    private func observeAppTermination() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppTermination),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    @MainActor @objc private func handleAppTermination() {
        guard currentSession != nil else { return }
        _ = stopTracking()
    }

    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuAndNeuralEngine
            config.allowLowPrecisionAccumulationOnGPU = false
            let model = try SnytysiaMLModel(configuration: config).model
            request = try SNClassifySoundRequest(mlModel: model)
        } catch {
            logger.fault("SnytysiaMLModel configuration failed: \(error)")
            // MARK: Error
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("Failed to activate audio session before start: \(error)")
            return
        }

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }
    
    // MARK: - Public API
    @MainActor public func startTracking(delay: TimeInterval = 0) {
        configureAudioSession()
        
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        self.inputFormat = format

        guard format.channelCount > 0, format.sampleRate > 0 else {
            logger.fault("Invalid audio format: ch=\(format.channelCount) sr=\(format.sampleRate). Mic permission granted?")
            return
        }
        
        let bufferSize: AVAudioFrameCount = 8192
        audioBuffer = SleepAudioBuffer(maxSeconds: 3.0, format: format, bufferSize: bufferSize)
        analyzer = SNAudioStreamAnalyzer(format: format)
        
        statePublisher.send(.inactive)
        
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { @Sendable [weak self] buffer, time in
            guard let self = self else { return }
            
            if case .tracking = self.statePublisher.value {
                self.analyzer?.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
            
            self.lock.lock()
            defer { self.lock.unlock() }
            
            if let file = self.activeAudioFile {
                try? file.write(from: buffer)
            } else {
                self.audioBuffer?.append(buffer)
            }
        }
        
        do {
            try audioEngine.start()
            
            if delay > 0 {
                delayedTask = Task {
                    do {
                        statePublisher.send(.delayed(Date(), delay))
                        try await Task.sleep(for: .seconds(delay))
                        guard !Task.isCancelled else { return }
                        
                        beginClassification(format: format, bufferSize: bufferSize)
                        logger.info("Delayed sleep analysis started")
                    } catch {
                        statePublisher.send(.inactive)
                        logger.info("Delay task was cancelled")
                    }
                }
            } else {
                Task { self.beginClassification(format: format, bufferSize: bufferSize) }
            }
        } catch {
            logger.error("Listening Error: \(error)")
        }
    }
    
    @MainActor public func stopTracking() -> Bool {
        delayedTask?.cancel()
        statePublisher.send(.inactive)
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        analyzer?.removeAllRequests()

        lock.lock()
        
        if activeAudioFile != nil {
            finishCurrentRecord()
        }
        
        currentSession?.endDate = Date()
        
        var sessionToSave: SleepSession?
        #if DEBUG
        if let currentSession, currentSession.events.count > 1, currentSession.startDate.timeIntervalSinceNow < 5 {
            sessionToSave = currentSession
        }
        #else
        if let currentSession, currentSession.events.count > 1, currentSession.startDate.timeIntervalSinceNow < 60 {
            sessionToSave = currentSession
        }
        #endif
        
        currentSession = nil
        audioBuffer?.clear()
        
        lock.unlock()
        
        if let session = sessionToSave {
            do {
                try SleepHistory.save(session)
            } catch {
                logger.fault("Saving sleep session data failed: \(error)")
                return false
            }
        }
        
        sessionPublisher.send(nil)
        return sessionToSave != nil
    }
    
    // MARK: - SNResultsObserving
    public func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let best = result.classifications.first else { return }
        
        if best.confidence > 0.7 {
            handleClassification(identifier: best.identifier)
            logger.debug("Classified: \(best.identifier, privacy: .public), confidence: \(best.confidence, privacy: .public)")
        } else {
            handleClassification(identifier: "silence")
        }
    }
    
    // MARK: - Classification Handling
    @MainActor private func beginClassification(format: AVAudioFormat, bufferSize: AVAudioFrameCount) {
        lock.lock()
        self.audioBuffer = SleepAudioBuffer(maxSeconds: 3.0, format: format, bufferSize: bufferSize)
        self.currentSession = SleepSession()
        self.savedFilesCount = 0
        lock.unlock()
        
        self.sessionPublisher.send(self.currentSession)
        
        do {
            guard let request = request else { return }
            try analyzer?.add(request, withObserver: self)
            statePublisher.send(.tracking)
            
            self.logger.info("Sleep classification session started")
        } catch {
            self.logger.error("Failed to add analyzer request: \(error)")
        }
    }
    
    private func handleClassification(identifier: String) {
        let now = Date()
        
        lock.lock()
        defer {
            lock.unlock()
            sessionPublisher.send(currentSession)
        }
        
        switch identifier {
        case "snoring", "sleepTalk":
            lastEventTime = now
            
            if currentRecordingType == nil {
                logger.info("Event started for: \(identifier, privacy: .public)")
                currentRecordingStartTime = now
                currentRecordingType = SleepEventType(rawValue: identifier)
                
                if let keyPath = counterMap[identifier] {
                    currentSession?[keyPath: keyPath] += 1
                }
                
                if savedFilesCount < maxRecordingsPerSession {
                    activeAudioFile = createAudioFile(for: identifier)
                    if let file = activeAudioFile {
                        do {
                            try audioBuffer?.flush(to: file)
                        } catch {
                            logger.error("Buffer flushing error: \(error)")
                        }
                    }
                }
            }
            
        case "coughSneeze":
            lastEventTime = now
            if now.timeIntervalSince(lastCoughTime) > 3.0 {
                currentSession?.coughCount += 1
                lastCoughTime = now
            }
            
        case "noise": lastNoiseTime = now
            
        default: break
        }
        
        
        if currentRecordingType != nil {
            let recordingDuration = now.timeIntervalSince(currentRecordingStartTime ?? now)
            let timeSinceLastEvent = now.timeIntervalSince(lastEventTime)
            
            if timeSinceLastEvent > 2.5 || recordingDuration >= maxRecordingDuration {
                finishCurrentRecord()
            }
        }
        
        if let lastNoiseTime, now.timeIntervalSince(lastNoiseTime) > 2.0 {
            self.lastNoiseTime = nil
            if let volume = audioBuffer?.calculatePeakVolume() {
                self.currentSession?.noiseVolumeSum += volume
                self.currentSession?.noiseSamplesCount += 1
                
                let duration = Date().timeIntervalSince(lastNoiseTime)
                let event = SleepEvent(
                    type: .noise,
                    timestamp: Date(),
                    duration: duration,
                    volume: volume
                )
                currentSession?.events.append(event)
            }
        }
    }
    
    private func createAudioFile(for eventName: String) -> AVAudioFile? {
        guard let format = self.inputFormat else { return nil }
//        let format = audioEngine.inputNode.outputFormat(forBus: 0)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = formatter.string(from: Date())
        
        let fileName = "\(eventName)_\(timestamp).caf"
        
        let url = audioRecordsDirectory.appendingPathComponent(fileName)
        
        do {
            let file = try AVAudioFile(forWriting: url, settings: format.settings)
            self.currentAudioFileName = fileName
            
            return file
        } catch {
            print("Error creating audio file: \(error)")
            return nil
        }
    }

    private func finishCurrentRecord() {
        guard let fileName = currentAudioFileName,
              let startTime = currentRecordingStartTime,
              let eventType = currentRecordingType else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        
        let event = SleepEvent(
            type: eventType,
            timestamp: startTime,
            duration: duration,
            audioFileName: fileName
        )
        
        currentSession?.events.append(event)
        
        if let fileName = currentAudioFileName {
            logger.info("Recording stopped and saved: \(fileName, privacy: .public)")
            savedFilesCount += 1
        }
        
        activeAudioFile = nil
        audioBuffer?.clear()
        currentAudioFileName = nil
        currentRecordingStartTime = nil
        currentRecordingType = nil
    }
}
