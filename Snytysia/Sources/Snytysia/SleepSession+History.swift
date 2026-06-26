import Foundation
import Combine

public struct SleepSession: Codable, Identifiable {
    public let id: UUID
    public let startDate: Date
    public var endDate: Date?
    
    public var coughCount: Int = 0
    public var snoreCount: Int = 0
    public var talkCount: Int = 0
    public var noiseVolumeSum: Float = 0.0
    public var noiseSamplesCount: Int = 0
    public var events: [SleepEvent] = []
    
    public init(id: UUID = UUID(), startDate: Date = Date()) {
        self.id = id
        self.startDate = startDate
    }
}

@MainActor
public final class SleepHistory {
    public static var lastSession: SleepSession? = { loadAllSessions().first }()
    
    private static var sessionsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("SleepSessions")
        
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    static func save(_ session: SleepSession) throws {
        let fileURL = sessionsDirectory.appendingPathComponent("\(session.id.uuidString).json")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(session)
        try data.write(to: fileURL)
        
        lastSession = session
    }
    
    public static func loadAllSessions() -> [SleepSession] {
        guard let files = try? FileManager.default.contentsOfDirectory(at: sessionsDirectory, includingPropertiesForKeys: nil) else { return [] }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return files
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(SleepSession.self, from: data)
            }
            .sorted { $0.startDate > $1.startDate }
    }
    
    public static func deleteSession(session: SleepSession) {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found")
            return
        }
        
        for event in session.events {
            guard let fileName = event.audioFileName else { continue }
            let fileURL = documentsURL
                .appending(path: "SleepRecordings", directoryHint: .isDirectory)
                .appending(path: fileName)
            deleteFile(fileURL)
        }
        
        let fileURL = documentsURL
            .appending(path: "SleepSessions", directoryHint: .isDirectory)
            .appending(path: "\(session.id.uuidString).json")
        deleteFile(fileURL)
    }
    
    private static func deleteFile(_ fileURL: URL) {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error deleting file: \(error.localizedDescription)")
            }
        } else {
            print("File not found")
        }
    }
}
