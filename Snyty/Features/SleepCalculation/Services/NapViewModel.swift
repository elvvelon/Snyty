import SwiftUI

@MainActor
@Observable
class NapViewModel {
    let napID = UUID()
    var formattedTime = ""
    
    func scheduleNap(_ nap: NapType, fallAsleepDuration: Int, cycleDuration: Int) async {
        let napDuration = nap == .shortest ? 20 : cycleDuration
        
        guard let alarmTime = Calendar.current.date(byAdding: .minute, value: napDuration + fallAsleepDuration, to: Date()) else { return }
        
        self.formattedTime = alarmTime.formatedTime
        
        let alarm = CycleAlarm(id: napID, hour: alarmTime.hour, minute: alarmTime.minute, isUsersAlarm: false)
        await AlarmScheduleProvider.shared.scheduleAlarm(alarm)
    }

    func cancelNap() {
        AlarmScheduleProvider.shared.cancelAlarm(id: napID)
    }
}
