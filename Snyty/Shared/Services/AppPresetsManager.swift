import SwiftUI

@MainActor
@Observable
class AppPresetsManager {
    static let shared = AppPresetsManager()
    
    private let fallAsleepDurationKey = "fallAsleepDurationMinutes"
    private let cycleDurationKey = "cycleDurationMinutes"
    
    private let alarmSoundNameKey = "alarmSoundName"
    private let allowSnoozeKey = "isSnoozeAllowed"
    private let snoozeDurationKey = "snoozeDurationMinutes"
    
    private let biorhythmOffsetKey = "biorhythmOffsetHours"

    private init() {
        UserDefaults.standard.register(defaults: [
            alarmSoundNameKey: "standard",
            allowSnoozeKey: true,
            snoozeDurationKey: 5,
            cycleDurationKey: 90,
            fallAsleepDurationKey: 15,
            biorhythmOffsetKey: 0.0,
            "isOnboarded": false
        ])
        
        self.alarmSound = AlarmSound(rawValue: UserDefaults.standard.string(forKey: alarmSoundNameKey) ?? "standard") ?? .standard
        self.allowSnooze = UserDefaults.standard.bool(forKey: allowSnoozeKey)
        self.snoozeDuration = UserDefaults.standard.integer(forKey: snoozeDurationKey)
        self.cycleDuration = UserDefaults.standard.integer(forKey: cycleDurationKey)
        self.fallAsleepDuration = UserDefaults.standard.integer(forKey: fallAsleepDurationKey)
        self.biorhythmOffset = UserDefaults.standard.double(forKey: biorhythmOffsetKey)
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
    }
    
    var alarmSound: AlarmSound {
        didSet { UserDefaults.standard.set(alarmSound.rawValue, forKey: alarmSoundNameKey) }
    }
    
    var allowSnooze: Bool {
        didSet { UserDefaults.standard.set(allowSnooze, forKey: allowSnoozeKey) }
    }
    
    var snoozeDuration: Int {
        didSet { UserDefaults.standard.set(snoozeDuration, forKey: snoozeDurationKey) }
    }
    
    var cycleDuration: Int {
        didSet { UserDefaults.standard.set(cycleDuration, forKey: cycleDurationKey) }
    }
    
    var fallAsleepDuration: Int {
        didSet { UserDefaults.standard.set(fallAsleepDuration, forKey: fallAsleepDurationKey) }
    }
    
    var biorhythmOffset: Double {
        didSet { UserDefaults.standard.set(biorhythmOffset, forKey: biorhythmOffsetKey) }
    }
    
    var isOnboarded: Bool {
        didSet { UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded") }
    }
}
