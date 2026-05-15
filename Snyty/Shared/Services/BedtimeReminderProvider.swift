import UserNotifications

@MainActor
@Observable
class BedtimeReminderProvider {
    static let shared = BedtimeReminderProvider()
    private var alarms: [CalculatedSleep] = []
    
    init() {
        self.requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                return
            } else if let error = error {
                // MARK: - ERROR here
                print(error.localizedDescription)
            }
        }
    }
    
    func schedule(for alarm: CalculatedSleep, wakeUpAt: String) async {
        if !isScheduled(alarm: alarm) {
            let content = UNMutableNotificationContent()
            content.title = "Час лягати спати ✨"
            content.subtitle = alarm.formatedInfo
            content.body = "Щоб прокинутися бадьорим о \(wakeUpAt), варто заснути протягом наступних \(AppPresetsManager.shared.fallAsleepDuration) хв."
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = alarm.time.hour
            dateComponents.minute = alarm.time.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: alarm.time.formatedTime, content: content, trigger: trigger)
            
            try? await UNUserNotificationCenter.current().add(request)
            
            alarms.append(alarm)
            Task {
                try? await Task.sleep(nanoseconds: UInt64(((AppPresetsManager.shared.fallAsleepDuration) * 60 * 1_000_000_000)))
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [alarm.time.formatedTime])
            }
        }
    }
    
    func remove(alarm: CalculatedSleep) {
        if isScheduled(alarm: alarm) {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [alarm.time.formatedTime])
            center.removeDeliveredNotifications(withIdentifiers: [alarm.time.formatedTime])
            
            alarms.removeAll(where: { $0.time.formatedTime == alarm.time.formatedTime })
        }
    }
    
    func isScheduled(alarm: CalculatedSleep) -> Bool {
        return alarms.contains(where: { $0.time.formatedTime == alarm.time.formatedTime })
    }
}
