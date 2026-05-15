import Foundation
import AVFoundation

@Observable
class AudioPlaybackService {
    var audioPlayer: AVAudioPlayer?

    func playSound(_ name: String, _ ext: String) {
        if let path = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: path)
                audioPlayer?.play()
            } catch {
                stopSound()
            }
        } else {
            stopSound()
            return
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
    }
}
