import SwiftUI
import AVFoundation
import Snytysia

extension SleepEvent {
    var durationFormated: String {
        duration?.durationFormated ?? "0 с"
    }
    
    var audioURL: URL? {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found")
            return nil
        }
        
        guard let audioFileName else {
            print("No audio file name")
            return nil
        }
        
        return documentsURL.appendingPathComponent("SleepRecordings")
                           .appendingPathComponent(audioFileName)
    }
    
    var amplitudes: [Float]? {
        guard let audioURL else { return nil }
        guard let file = try? AVAudioFile(forReading: audioURL) else { return nil }
        
        let format = file.processingFormat
        let frameCount = UInt32(file.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        
        try? file.read(into: buffer)
        
        guard let floatChannelData = buffer.floatChannelData else { return nil }
        
        let channelData = floatChannelData[0]
        let samplesPerBar = Int(frameCount) / 36
        var resultAmplitudes: [Float] = []
        
        for i in 0..<36 {
            let startSample = i * samplesPerBar
            var sum: Float = 0
            
            for j in 0..<samplesPerBar {
                let sample = channelData[startSample + j]
                sum += abs(sample)
            }
            
            let average = sum / Float(samplesPerBar)
            resultAmplitudes.append(average)
        }
        
        let maxAmplitude = resultAmplitudes.max() ?? 1.0
        return resultAmplitudes.map { maxAmplitude > 0 ? $0 / maxAmplitude : 0.0 }
    }
    
    var volumeInDb: Float { max(0, (volume ?? -200) + 95) }
}
