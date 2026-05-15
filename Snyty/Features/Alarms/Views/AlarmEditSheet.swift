import SwiftUI

struct AlarmEditSheet: View {
    @State private var alarm: CycleAlarm
    private let save: (CycleAlarm) -> Void
    private let destruct: (UUID) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var presets = AppPresetsManager.shared
    @State private var alarmName: String
    @State private var isNew = true
    @State private var playbackService = AudioPlaybackService()
    
    init(_ alarm: CycleAlarm? = nil, save: @escaping (CycleAlarm) -> Void, destruct: @escaping (UUID) -> Void = { _ in }) {
        if alarm != nil { self.isNew = false } else { self.isNew = true }
        self.alarm = alarm ?? CycleAlarm(id: UUID(), hour: 7, minute: 30, isUsersAlarm: true, snoozeEnabled: true)
        self.save = save
        self.destruct = destruct
        self.alarmName = alarm?.name ?? ""
    }
    
    private var cycleColor: Color {
        return (-0.05...0.05).contains(alarm.index) ? .appPrimary : .accent
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                TimelineView(.everyMinute) {_ in
                    timePickerSection
                }
                
                settingsSection
                
                Spacer()
                
                .onAppear {
                    if isNew {
                        alarm.soundName = presets.alarmSound
                        alarm.snoozeEnabled = presets.allowSnooze
                        alarm.snoozeDuration = presets.snoozeDuration
                        isNew.toggle()
                    } else {
                        alarm.isUsersAlarm = true
                    }
                }
            }
            .padding()
        }
        .toolbarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.textPrimary)
                }
            }
            
            ToolbarItem(placement: .title) {
                Text("Змінити")
                    .subtitle1()
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    save(alarm)
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.textPrimary)
                }
                .tint(.accent)
                .buttonStyle(.glassProminent)
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button {
                    destruct(alarm.id)
                    dismiss()
                } label: {
                    Text("Видалити")
                }
                .tint(.appRed)
            }
        }
    }
    
    private var timePickerSection: some View {
        VStack(spacing: 24) {
            TimePicker(.hm($alarm.hour, $alarm.minute))
            
            VStack {
                HStack {
                    Circle()
                        .fill(cycleColor)
                        .mask {
                            GeometryReader { geo in
                                Circle()
                                    .offset(x: ((geo.size.width) * alarm.index * 2))
                                    .padding(2)
                            }
                        }
                        .onChange(of: alarm.index) {
                            if (-0.05...0.05).contains(alarm.index) {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            }
                        }
                        .frame(maxWidth: 50)
                        .animation(.smooth, value: alarm.index)
                        .glassEffect(.clear.tint(.appSecondary))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("На сон приблизно:")
                            .title3()
                        Text(alarm.timeLeftFormated)
                        Text(alarm.cyclesLeftFormated)
                        
                    }
                    .description3()
                }
                .frame(maxWidth: 240)
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(spacing: 16) {
            SettingsStack(.row) {
                SettingRow(
                    title: "Назва",
                    style: .textField(
                        Binding(
                            get: {alarm.name ?? ""},
                            set: {alarm.name = $0})),
                    representedValue: "Будильник"
                )
            }
            
            SettingsStack(.row) {
                SettingRow(
                    title: "Звук",
                    iconName: "speaker.wave.2",
                    style: .list(
                        ListConfig(
                            title: "Звук будильника",
                            options: AlarmSound.allCases,
                            selection: Binding(
                                get: { alarm.soundName ?? presets.alarmSound },
                                set: { alarm.soundName = $0 as? AlarmSound }
                            )
                        ), {
                            playbackService.playSound(alarm.soundName?.rawValue ?? "", "wav")
                        }
                    ),
                    representedValue: alarm.soundName?.displayName ?? presets.alarmSound.displayName
                ) {
                    playbackService.stopSound()
                }
                
                SettingRow (
                    title: "Дозволити відкладання",
                    iconName: "moon.haze",
                    style: .toggle(Binding(
                        get: { alarm.snoozeEnabled ?? presets.allowSnooze },
                        set: { alarm.snoozeEnabled = $0 } )
                    )
                )
                
                if alarm.snoozeEnabled ?? presets.allowSnooze {
                    SettingRow(
                        title: "На скільки відкладати",
                        iconName: "timer",
                        style: .timePicker(.range(Binding(
                            get: { alarm.snoozeDuration ?? presets.snoozeDuration },
                            set: {alarm.snoozeDuration = $0 } ),
                                                  1..<31, "хвилин")),
                        representedValue: "\(alarm.snoozeDuration ?? presets.snoozeDuration) хв")
                }
            }
        }
    }
}

struct PreviewableAlarm: View {
    @State var alarm: CycleAlarm
    let remove: (UUID) -> Void
    let save: (CycleAlarm) -> Void
    
    @State private var present = false
    var body: some View {
        VStack(alignment: .leading) {
            Text(alarm.scheduledTimeFormated)
                .font(.system(size: 40, weight: .heavy, design: .rounded))
            
            TimelineView(.everyMinute) { _ in
                Text(alarm.timeLeftFormated)
            }
        }
        .padding()
        .background(.appContext)
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.appSecondary)
        }
        .sheet(isPresented: $present) {
            NavigationStack {
                AlarmEditSheet(alarm) {
                    save($0)
                } destruct: {
                    remove($0)
                }
            }
        }
        .onTapGesture {
            present.toggle()
        }
    }
}

#Preview {
    @Previewable @State var isPresented: Bool = false
    @Previewable @State var alarms: [CycleAlarm] = []
    
    VStack {
        Button {
            isPresented.toggle()
        } label: {
            Text("Create new")
                .padding()
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                AlarmEditSheet() { alarm in
                    alarms.append(alarm)
                }
                .toolbarVisibility(.hidden, for: .bottomBar)
            }
        }
        .buttonStyle(.borderedProminent)
        
        VStack(spacing: 20) {
            ForEach(alarms) { alarm in
                PreviewableAlarm(alarm: alarm) { id in
                    alarms.removeAll(where: {$0.id == id})
                } save: { new in
                    alarms.removeAll(where: {$0.id == new.id})
                    alarms.append(new)
                }
            }
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appBackground)
}
