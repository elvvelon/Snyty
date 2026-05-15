import SwiftUI

protocol AppSetting: CaseIterable, Hashable {
    var displayName: LocalizedStringResource { get }
}

enum PresetAlarmSetting {
    case sound, snoozeAllowed, snoozeDuration
}

enum AlarmSound: String, AppSetting, Codable {
    case standard, ascent, cadence, clarity, enchant, expanse, genesis, idle, launch, linger, mirage, pendulum, resolve, tidings, vigor
    
    var displayName: LocalizedStringResource {
        return LocalizedStringResource(stringLiteral: self.rawValue.capitalized)
    }
}
