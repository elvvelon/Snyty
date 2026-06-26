import SwiftUI

enum HomePageSection: @MainActor TabItem {
    case dashboard, sleep
    
    var title: LocalizedStringResource? {
        switch self {
        case .dashboard:
            LocalizedStringResource("Огляд")
        case .sleep:
            LocalizedStringResource("Сон")
        }
    }
    
    var icon: String? { return nil }
}

enum CalculationMode: @MainActor TabItem {
    case targetWakeUp, sleepNow
    
    var title: LocalizedStringResource? {
        switch self {
        case .targetWakeUp:
            LocalizedStringResource("Я хочу прокинутися о")
        case .sleepNow:
            LocalizedStringResource("Я лягаю спати зараз")
        }
    }
    
    var icon: String? { return nil }
}

@MainActor
@Observable
class CalculatorViewModel {
    // Home UI
    var pageSection: HomePageSection = .dashboard
    var calculationMode: CalculationMode = (7...20).contains(Date().hour) ? .targetWakeUp : .sleepNow
    var selectedHour = 7
    var selectedMinute = 30
    var customFallAsleepDuration = AppPresetsManager.shared.fallAsleepDuration
    
    // Results UI
    var toolbarTitle: LocalizedStringResource { calculationMode == .sleepNow ? "Засинати о" : "Прокинутися о" }
    var iconName: String { calculationMode == .sleepNow ? "moon" : "bed.double" }
    var resultsTitle: LocalizedStringResource { calculationMode == .sleepNow ? "На добраніч!" : "Час лягати спати" }
    var resultsCaption: LocalizedStringResource { calculationMode == .sleepNow ?
        "Якщо ви ляжете зараз, краще прокинутися о:" :
        "Щоб прокинутись бадьорим, краще лягти спати о:" }
    
    var actionIconName: String { calculationMode == .sleepNow ? "plus" : "bell" }
    
    // Results
    var calculatedResults: [CalculatedSleep] = []
    var formattedTargetTime: String = ""
    
    func performCalculation() {
        let now = Date()
        var hour: Int
        var minute: Int
        var appliedFallAsleepDuration: Int
        
        switch calculationMode {
        case .targetWakeUp:
            hour = selectedHour
            minute = selectedMinute
            appliedFallAsleepDuration = AppPresetsManager.shared.fallAsleepDuration
        case .sleepNow:
            hour = Calendar.current.component(.hour, from: now)
            minute = Calendar.current.component(.minute, from: now)
            appliedFallAsleepDuration = customFallAsleepDuration
        }
        
        self.calculatedResults = calculateCycles(
            baseDate: now,
            targetHour: hour,
            targetMinute: minute,
            cycleDuration: AppPresetsManager.shared.cycleDuration,
            fallAsleepDuration: appliedFallAsleepDuration,
            calculationMode: calculationMode
        )
        
        let targetDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
        self.formattedTargetTime = targetDate.formatedTime
    }
    
    // Core Math
    func calculateCycles(baseDate: Date, targetHour: Int, targetMinute: Int,
                         cycleDuration: Int, fallAsleepDuration: Int,
                         calculationMode: CalculationMode) -> [CalculatedSleep]
    {
        let calendar = Calendar.current
        var results: [CalculatedSleep] = []
        let direction = calculationMode == .targetWakeUp ? -1 : 1
        let duration = cycleDuration * direction
        
        let targetClock = calendar.date(bySettingHour: targetHour, minute: targetMinute, second: 0, of: baseDate) ?? baseDate
        
        for i in 1...6 {
            if let alarmTime = calendar.date(byAdding: .minute, value: (duration * i) + fallAsleepDuration, to: targetClock) {
                results.append(CalculatedSleep(time: alarmTime, cycles: i))
            }
        }
        
        return calculationMode == .targetWakeUp ? results.reversed() : results
    }
    
    func isScheduled(alarm: CalculatedSleep) -> Bool {
        switch calculationMode {
        case .sleepNow:
            let cycleAlarm = CycleAlarm(id: alarm.id, hour: alarm.time.hour, minute: alarm.time.minute, isUsersAlarm: false)
            return AlarmScheduleProvider.shared.isAlarmScheduled(cycleAlarm)
            
        case .targetWakeUp:
            return BedtimeReminderProvider.shared.isScheduled(alarm: alarm)
        }
    }
    
    func schedule(alarm: CalculatedSleep) {
        Task {
            switch calculationMode {
            case .sleepNow:
                let alarmData = CycleAlarm(id: alarm.id, hour: alarm.time.hour, minute: alarm.time.minute, isUsersAlarm: false)
                await AlarmScheduleProvider.shared.scheduleAlarm(alarmData)
                
            case .targetWakeUp:
                await BedtimeReminderProvider.shared.schedule(for: alarm, wakeUpAt: formattedTargetTime)
            }
        }
    }
}
