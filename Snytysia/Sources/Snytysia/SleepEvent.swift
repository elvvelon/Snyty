import Foundation

public enum SleepEventType: String, Codable {
    case snoring, sleepTalk, coughSneeze, noise, rustling
}

public struct SleepEvent: Codable, Identifiable {
    public let id: UUID
    public let type: SleepEventType
    public let timestamp: Date
    public let duration: TimeInterval?
    public let audioFileName: String?
    public let volume: Float?
    
    public init(
        id: UUID = UUID(), type: SleepEventType, timestamp: Date, duration: TimeInterval? = nil,
        audioFileName: String? = nil, volume: Float? = nil
    ) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.duration = duration
        self.audioFileName = audioFileName
        self.volume = volume
    }
}
