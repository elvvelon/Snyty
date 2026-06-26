import AVFoundation

final class SleepAudioBuffer {
    private var buffers: [AVAudioPCMBuffer] = []
    private let maxBuffersCount: Int
    
    init(maxSeconds: Double, format: AVAudioFormat, bufferSize: AVAudioFrameCount) {
        let bufferDuration = Double(bufferSize) / format.sampleRate
        self.maxBuffersCount = Int(ceil(maxSeconds / bufferDuration))
    }
    
    func append(_ buffer: AVAudioPCMBuffer) {
        guard let copiedBuffer = copyBuffer(buffer) else { return }
        buffers.append(copiedBuffer)
        
        if buffers.count > maxBuffersCount {
            buffers.removeFirst()
        }
    }
    
    func flush(to file: AVAudioFile) throws {
        for buffer in buffers {
            try file.write(from: buffer)
        }
        buffers.removeAll()
    }
    
    func clear() {
        buffers.removeAll()
    }
    
    func calculatePeakVolume() -> Float {
        var peakRMS: Float = 0.0
        
        for buffer in buffers {
            guard let channelData = buffer.floatChannelData?[0] else { continue }
            let frameLength = Int(buffer.frameLength)
            
            var sumOfSquares: Float = 0.0
            for i in 0..<frameLength {
                let sample = channelData[i]
                sumOfSquares += sample * sample
            }
            
            let rms = sqrt(sumOfSquares / Float(frameLength))
            if rms > peakRMS { peakRMS = rms }
        }
        
        guard peakRMS > 0 else { return -100.0 }
        return 20 * log10(peakRMS)
    }
    
    // MARK: - Deep Copy Helper
    private func copyBuffer(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let copy = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: buffer.frameCapacity) else { return nil }
        copy.frameLength = buffer.frameLength
        
        let channelCount = Int(buffer.format.channelCount)
        let byteSize = Int(buffer.frameLength) * MemoryLayout<Float>.size
        
        for channel in 0..<channelCount {
            guard let source = buffer.floatChannelData?[channel],
                  let destination = copy.floatChannelData?[channel] else { continue }
            
            memcpy(destination, source, byteSize)
        }
        
        return copy
    }
}
