import Foundation
import AVFoundation
import SwiftUI

@Observable
final class AudioPlaybackManager: NSObject, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    
    var currentTrackID: UUID? = nil
    var isPlaying: Bool = false
    var playbackProgress: Double = 0.0
    
    private var progressTimer: Timer?
    
    override init() {
        super.init()
//        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error setingup audio session: \(error)")
        }
    }
    
    func togglePlayback(for eventID: UUID, fileURL: URL) {
        if currentTrackID == eventID {
            if isPlaying {
                pause()
            } else {
                resume()
            }
        } else {
            playNew(url: fileURL, id: eventID)
        }
    }
    
    private func playNew(url: URL, id: UUID) {
        stop()
        
        setupAudioSession()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            currentTrackID = id
            isPlaying = true
            startTimer()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func resume() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        currentTrackID = nil
        isPlaying = false
        playbackProgress = 0.0
        stopTimer()
    }
    
    func seek(to progress: Double) {
        guard let player = audioPlayer else { return }
        let newTime = player.duration * progress
        player.currentTime = newTime
        playbackProgress = progress
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.playbackProgress = 0.0
            self.stopTimer()
        }
    }
    
    private func startTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                guard let player = self.audioPlayer else { return }
                self.playbackProgress = player.currentTime / player.duration
            }
        }
    }
    
    private func stopTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}
