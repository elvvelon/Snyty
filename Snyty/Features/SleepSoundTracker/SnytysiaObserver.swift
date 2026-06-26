import Combine
import SwiftUI
import Snytysia

@MainActor @Observable
final class SnytysiaObserver {
    var startDate: Date = Date()
    
    var coughCount: Int = 0
    var noiseCount: Int = 0
    var snoreCount: Int = 0
    var talkCount: Int = 0
    
    var events: [SleepEvent] = []
    var lastSession: SleepSession?
    var allSessions: [SleepSession] = []
    
    var trackingState: Snytysia.State = .inactive
    var isRecording: Bool = false
    
    var didSaveSession = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        allSessions = SleepHistory.loadAllSessions()
        lastSession = allSessions.first
        
        Snytysia.classifier.sessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                guard let self = self else { return }
                if let session = session {
                    self.startDate = session.startDate
                    self.noiseCount = session.noiseSamplesCount
                    self.coughCount = session.coughCount
                    self.snoreCount = session.snoreCount
                    self.talkCount = session.talkCount
                    self.events = session.events
                } else {
                    self.noiseCount = 0
                    self.coughCount = 0
                    self.snoreCount = 0
                    self.talkCount = 0
                    self.events = []
                }
            }
            .store(in: &cancellables)
        
        Snytysia.classifier.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                self.trackingState = state
                if case .tracking = trackingState {
                    isRecording = true
                } else {
                    isRecording = false
                }
            }
            .store(in: &cancellables)
    }
    
    func toggleRecording(forceStart: Bool = true) {
        didSaveSession = false
        
        switch trackingState {
        case .inactive:
            #if DEBUG
            let delay = TimeInterval(5)
            #else
            let delay = TimeInterval(AppPresetsManager.shared.fallAsleepDuration * 60)
            #endif
            Snytysia.classifier.startTracking(delay: delay)
            return
            
        case .delayed:
            _ = Snytysia.classifier.stopTracking()
            if forceStart {
                Snytysia.classifier.startTracking()
            }

        case .tracking:
            didSaveSession = Snytysia.classifier.stopTracking()
            if didSaveSession {
                allSessions = SleepHistory.loadAllSessions()
                lastSession = allSessions.first
            }
        }
    }
}
