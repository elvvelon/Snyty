import SwiftUI

struct CycleAlarm: Identifiable, Codable {
    let id: UUID
    var hour: Int
    var minute: Int
    var isUsersAlarm: Bool
    var isPaused = false
    var soundName: AlarmSound?
    var snoozeEnabled: Bool?
    var snoozeDuration: Int?
    var name: String?
}

extension CycleAlarm {
    var scheduledTimeFormated: String {
        return String(format: "%0.2d:%0.2d", hour, minute)
    }
    
    var timeLeftFormated: String {
        guard let hour = timeLeft.0, let minute = timeLeft.1 else { return String(localized: "-- хв") }
        
        if hour == 0 && minute == 0 { return String(localized: "менше хвилини") }
        
        let hoursString = hour > 0 ? String(localized: "\(hour) год") + " " : ""
        let minutesString = minute > 0 ? String(localized: "\(minute) хв") : ""
        return hoursString + minutesString
    }
    
    var timeLeft: (Int?, Int?) {
        let calendar = Calendar.current
        let now = Date()
        
        var alarmComponents = calendar.dateComponents([.year, .month, .day], from: now)
        alarmComponents.hour = self.hour
        alarmComponents.minute = self.minute
        alarmComponents.second = 0
        
        guard var alarmDate = calendar.date(from: alarmComponents) else { return (nil, nil) }
        
        if alarmDate <= now {
            alarmDate = calendar.date(byAdding: .day, value: 1, to: alarmDate) ?? alarmDate
        }
        let components = calendar.dateComponents([.hour, .minute], from: now, to: alarmDate)
        
        return (components.hour, components.minute)
    }
    
    var index: Double {
        guard let cycles = cyclesLeft else { return 0 }
        
        let i = cycles.truncatingRemainder(dividingBy: 1.0)
        return i > 0.5 ? i - 1 : i
    }
    
    var cyclesLeft: Double? {
        guard let hour = timeLeft.0, let minute = timeLeft.1 else { return nil }
        return Double(hour * 60 + minute - AppPresetsManager.shared.fallAsleepDuration) / Double(AppPresetsManager.shared.cycleDuration)
    }
    
    var cyclesLeftFormated: LocalizedStringResource {
        guard let cycles = cyclesLeft else { return "- циклів" }
        if cycles < 0 {
            return "0 циклів"
        }
        switch index {
        case -0.1...0.1: return "\(Int(cycles)) циклів"
        case -0.5...(-0.1), 0.1...0.5: return "~ \(Int(cycles)) циклів"
        case -1...(-0.5): return "> \(Int(cycles)) циклів"
        case 0.5...1: return "< \(Int(cycles + 1)) циклів"
        default: return "- циклів"
        }
    }
}
