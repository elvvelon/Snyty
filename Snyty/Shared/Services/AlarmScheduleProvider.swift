import SwiftUI
import AlarmKit
import ActivityKit

nonisolated struct TimerData: AlarmMetadata { }

@MainActor
@Observable
class AlarmScheduleProvider {
    static let shared = AlarmScheduleProvider()
    private var manager = AlarmManager.shared
    
    var scheduled: [CycleAlarm] = [] {
        didSet { saveAlarmsData() }
    }
    
    var isAuthorized: Bool = false
    
    private let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("scheduled_alarms.json")
    
    private init() {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.scheduled = [CycleAlarm(id: UUID(), hour: 7, minute: 30, isUsersAlarm: true, snoozeEnabled: true), CycleAlarm(id: UUID(), hour: 10, minute: 0, isUsersAlarm: true, snoozeEnabled: false), CycleAlarm(id: UUID(), hour: 7, minute: 30, isUsersAlarm: true, soundName: .pendulum, snoozeEnabled: true, snoozeDuration: 2)]
        } else {
            Task {
                if await checkForAuthorization() {
                    isAuthorized = true
                    await loadAlarmsData()
                    syncAlarmsData()
                }
            }
        }
    }

    private func loadAlarmsData() async {
        let targetURL = fileURL
        await Task.detached(priority: .userInitiated) {
            guard FileManager.default.fileExists(atPath: targetURL.path),
                  let data = try? Data(contentsOf: targetURL),
                  let decodedAlarms = try? JSONDecoder().decode([CycleAlarm].self, from: data)
            else { return }
            
            await MainActor.run {
                self.scheduled = decodedAlarms
            }
        }.value
    }

    private func syncAlarmsData() {
        Task {
            guard let systemAlarmsIDs = try? Set(manager.alarms.map({ $0.id })) else { return }
            scheduled.removeAll { !(systemAlarmsIDs.contains($0.id) || $0.isPaused) }
        }
    }

    private func saveAlarmsData() {
        let alarmsToSave = scheduled
        let targetURL = fileURL
        
        Task.detached(priority: .background) {
            if let data = try? JSONEncoder().encode(alarmsToSave) {
                try? data.write(to: targetURL, options: [.atomic])
            }
        }
    }
    
    func checkForAuthorization() async -> Bool {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            do {
                let state = try await AlarmManager.shared.requestAuthorization()
                return state == .authorized
            } catch {
                return false
            }
        case .authorized: return true
        case .denied: return false
        @unknown default: return false
        }
    }
    
    var nextAlarm: CycleAlarm? {
        scheduled.filter{ !$0.isPaused }.min { a, b in
            let timeA = ((a.timeLeft.0 ?? 24) * 60) + (a.timeLeft.1 ?? 60)
            let timeB = ((b.timeLeft.0 ?? 24) * 60) + (b.timeLeft.1 ?? 60)
            return timeA < timeB
        }
    }
    
    func scheduleAlarm(_ alarm: CycleAlarm, updateIndex: Int? = nil) async {
        let isSnoozeAllowed = alarm.snoozeEnabled ?? AppPresetsManager.shared.allowSnooze
        let snoozeDuration = alarm.snoozeDuration ?? AppPresetsManager.shared.snoozeDuration
        let alarmSoundName = alarm.soundName?.rawValue ?? AppPresetsManager.shared.alarmSound.rawValue
        let alarmName = alarm.name
        
        let time = Alarm.Schedule.Relative.Time(hour: alarm.hour, minute: alarm.minute)
        let relativeSchedule = Alarm.Schedule.Relative(time: time, repeats: .never)
        let schedule = Alarm.Schedule.relative(relativeSchedule)
        
        let snoozeButton = isSnoozeAllowed ? AlarmButton(text: "Відкласти", textColor: .white, systemImageName: "moon.stars.fill") : nil
        let snoozeBehavior: AlarmPresentation.Alert.SecondaryButtonBehavior? = isSnoozeAllowed ? .countdown : nil
        
        let alert = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: "Час бадьорості!"),
            secondaryButton: snoozeButton,
            secondaryButtonBehavior: snoozeBehavior
        )
        
        let presentation = AlarmPresentation(alert: alert)
        
        let attributes = AlarmAttributes(
            presentation: presentation,
            metadata: TimerData(),
            tintColor: .appYellow
        )
        
        let countdownDuration = Alarm.CountdownDuration(
            preAlert: nil,
            postAlert: TimeInterval(snoozeDuration * 60)
        )
        
        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: countdownDuration,
            schedule: schedule,
            attributes: attributes,
            stopIntent: AlarmStopIntent(alarmID: alarm.id),
            sound: .named(alarmSoundName + ".wav")
        )
        
        _ = try? await manager.schedule(id: alarm.id, configuration: configuration)
        
        let updatedAlarm = (CycleAlarm(
            id: alarm.id, hour: alarm.hour, minute: alarm.minute,
            isUsersAlarm: alarm.isUsersAlarm,
            soundName: AlarmSound(rawValue: alarmSoundName),
            snoozeEnabled: isSnoozeAllowed, snoozeDuration: snoozeDuration,
            name: alarmName)
        )
        
        if let index = updateIndex {
            self.scheduled[index] = updatedAlarm
        } else {
            self.scheduled.append(updatedAlarm)
        }
    }
    
    func cancelAlarm(id: UUID) {
        scheduled.removeAll(where: { $0.id == id })
        try? manager.cancel(id: id)
    }
    
    func updateAlarm(config alarm: CycleAlarm) {
        Task {
            if !alarm.isPaused {
                cancelAlarm(id: alarm.id)
            } else {
                self.scheduled.removeAll(where: { $0.id == alarm.id })
            }
            await scheduleAlarm(alarm)
        }
    }
    
    func presetAllAlarms(_ setting: PresetAlarmSetting) {
        Task {
            for var alarm in scheduled {
                switch setting {
                case .sound:
                    alarm.soundName = AppPresetsManager.shared.alarmSound
                case .snoozeAllowed:
                    alarm.snoozeEnabled = AppPresetsManager.shared.allowSnooze
                case .snoozeDuration:
                    alarm.snoozeDuration = AppPresetsManager.shared.snoozeDuration
                }
                
                if !alarm.isPaused {
                    updateAlarm(config: alarm)
                } else {
                    guard let index = scheduled.firstIndex(where: { $0.id == alarm.id }) else { return }
                    scheduled[index] = alarm
                }
            }
        }
    }
    
    func toggleAlarm(_ alarm: CycleAlarm) {
        Task {
            guard let index = scheduled.firstIndex(where: { $0.id == alarm.id }) else { return }
            if alarm.isPaused {
                scheduled[index].isPaused = true
                try? manager.cancel(id: alarm.id)
            } else {
                await scheduleAlarm(alarm, updateIndex: index)
            }
        }
    }
    
    func isAlarmScheduled(_ alarm: CycleAlarm) -> Bool {
        return scheduled.contains(where: { $0.hour == alarm.hour && $0.minute == alarm.minute })
    }
}

