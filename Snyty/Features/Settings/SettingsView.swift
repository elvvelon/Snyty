import SwiftUI

public enum SettingsSectionStyle {
    case cards, row
}

indirect enum ValueChangeStyle {
    case toggle(Binding<Bool>), timePicker(TimePickerStyle), list(ListConfig, () -> Void), navigation(ValueChangeStyle), textField(Binding<String>)
}

struct ListConfig {
    var title: LocalizedStringResource? = nil
    let options: [any AppSetting]
    let selection: Binding<any AppSetting>
}

struct SettingsView: View {
    @State private var soundManager = AudioPlaybackService()
    @State private var presets = AppPresetsManager.shared
    
    private var chronotypeName: LocalizedStringResource {
        switch presets.biorhythmOffset {
        case -3..<0:  return "Жайворонок"
        case 0..<3:   return "Голуб"
        case 3...5:   return "Сова"
        default:      return "Інший"
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 34) {
                SettingsStack(
                    .cards,
                    "Розрахунки сну",
                    "Ці параметри будуть враховані під час наступних розрахунків."
                ) {
                    // MARK: - Налаштувати оновлення нагадувань про те, що час спати
                    SettingCard(
                        title: "Час на засинання",
                        subtitle: "Зазвичай 15 хв",
                        iconName: "clock",
                        color: .appPrimary,
                        style: .navigation(.timePicker(.range($presets.fallAsleepDuration, 0..<91, "хвилини"))),
                        representedValue: "\(presets.fallAsleepDuration) хв",
                        note: "Зазвичай людям потрібно 15 хвилин на те, щою заснути, проте, якщо у вас це зазвичай займає інший час – ви можете визначити його та ми врахуємо нове значення під час наступних розрахунків."
                    )
                    
                    SettingCard(
                        title: "Тривалість циклу",
                        subtitle: "Зазвичай 90 хв",
                        iconName: "moon",
                        color: .accent,
                        style: .navigation(.timePicker(.range($presets.cycleDuration, 60..<121, "хвилини"))),
                        representedValue: "\(presets.cycleDuration) хв",
                        note: "Будьте обережними зі зміною цього значення!\nЗазвичай повний цикл сну триває близько 90 хвилин. Цього часу достатньо, щоб організм послідовно пройшов усі стадії: від легкого сну до глибокого відновлення тканин та фази сновидінь (REM), яка відповідає за обробку інформації.\nКорегуйте цей параметр лише за умови, що ви точно знаєте тривалість своїх циклів (наприклад, на основі даних трекерів), оскільки помилка в розрахунках навіть у 5–10 хвилин може призвести до пробудження посеред глибокої фази, що спричинить відчуття сильної втоми протягом дня."
                    )
                    
                    
                    SettingCard(
                        title: "Хронотип",
                        iconName: "sun.horizon",
                        color: .appYellow,
                        style: .navigation(.timePicker(.h(
                            Binding(get: { Int(presets.biorhythmOffset + 8) },
                                    set: { presets.biorhythmOffset = Double($0) - 8 }
                                   )))),
                        representedValue: chronotypeName,
                        note: "Вкажіть час вашого пробудження, щоб ми налаштували графік циркадних ритмів саме під вас. Це допоможе програмі підказувати ідеальні моменти для активності та відпочинку, спираючись на ваш персональний біологічний годинник."
                    )
                }
                
                SettingsStack(
                    .row,
                  "Будильники",
                  "Зміна цих налаштувань також вплине на всі вже заведені будильники."
                ) {
                    SettingRow(
                        title: "Звук",
                        iconName: "speaker.wave.2",
                        style: .list(
                            ListConfig(
                                title: "Звук будильника",
                                options: AlarmSound.allCases,
                                selection: Binding(
                                    get: { presets.alarmSound },
                                    set: { presets.alarmSound = $0 as! AlarmSound }
                                )
                            ), {
                                soundManager.playSound(presets.alarmSound.rawValue, ".wav")
                            }
                        ),
                        representedValue: presets.alarmSound.displayName
                    ) {
                        soundManager.stopSound()
                        AlarmScheduleProvider.shared.presetAllAlarms(.sound)
                    }
                    
                    SettingRow(
                        title: "Дозволити відкладання",
                        iconName: "moon.haze",
                        style: .toggle($presets.allowSnooze)
                    )
                    .onChange(of: presets.allowSnooze) {
                        AlarmScheduleProvider.shared.presetAllAlarms(.snoozeAllowed)
                    }
                    
                    if presets.allowSnooze {
                        SettingRow(
                            title: "На скільки відкладати",
                            iconName: "timer",
                            style: .timePicker(.range($presets.snoozeDuration, 1..<31, "хвилин")),
                            representedValue: "\(presets.snoozeDuration) хв"
                        )
                        .onChange(of: presets.snoozeDuration) {
                            AlarmScheduleProvider.shared.presetAllAlarms(.snoozeDuration)
                        }
                    }
                }
                
//                SettingsStack(.row, "Вигляд застосунку") {
//                    SettingRow(
//                        title: "Мова",
//                        iconName: "textformat",
//                        style: .list(
//                            ListConfig(
//                                options: AppLanguage.allCases,
//                                selection: Binding(get: { presets.appLanguage }, set: { presets.appLanguage = $0 as! AppLanguage })
//                            )
//                        ),
//                        representedValue: presets.appLanguage.displayName.key
//                    )
//                
//                    SettingRow(
//                        title: "Формат часу",
////                        iconName: "24.square",
////                        iconName: "globe.badge.clock",
////                        iconName: "textformat.numbers",
//                        iconName: "app.badge.clock",
//                        style: .list(ListConfig(options: TimeFormat.allCases, selection: Binding(get: { presets.timeFormat }, set: { presets.timeFormat = $0 as! TimeFormat }))),
//                        representedValue: String(localized: presets.timeFormat.displayName)
//                    )
//                }
                
                footerView
            }
            .padding()
        }
        .animation(.bouncy(duration: 0.3), value: presets.allowSnooze)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
    }
    
    var footerView: some View {
        VStack(spacing: 6) {
            Text("Snyty v1.0.0")
                .font(.system(size: 14))
                .foregroundStyle(.textSecondary)
            
            Text("ЗРОБЛЕНО ДЛЯ ВАШОГО СНУ")
                .font(.system(size: 12))
                .foregroundStyle(.textSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .navigationBarTitleDisplayMode(.inline)
    }
}
