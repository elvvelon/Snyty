import AppIntents
import Snytysia

struct AlarmStopIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Stop"
    
    @Parameter(title: "alarmID")
    var alarmID: String
    
    init(alarmID: UUID) {
        self.alarmID = alarmID.uuidString
    }
    
    init() {
        self.alarmID = ""
    }
    
    func perform() throws -> some IntentResult {
        guard let id = UUID(uuidString: alarmID) else { throw NSError() }
        
        Task { @MainActor in
            let alarmProvider = AlarmScheduleProvider.shared
            
            if let index = alarmProvider.scheduled.firstIndex(where: { $0.id == id }),
               alarmProvider.scheduled[index].isUsersAlarm {
                
                alarmProvider.scheduled[index].isPaused = true
            }
            else {
                alarmProvider.cancelAlarm(id: id)
            }
            
            _ = Snytysia.classifier.stopTracking()
        }
        
        return .result()
    }
}
