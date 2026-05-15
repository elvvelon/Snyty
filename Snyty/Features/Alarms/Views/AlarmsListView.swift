import SwiftUI

struct AlarmsListView: View {
    @State private var manager = AlarmScheduleProvider.shared
    private var state: AlarmsState {
        if !manager.isAuthorized {
            return .accessDenied
        } else if manager.scheduled.isEmpty {
            return .empty
        } else {
            return .represent
        }
    }
    
    var body: some View {
        Group {
            switch state {
            case .accessDenied:
                showPlaceholder(
                    imageName: "clock.badge.xmark",
                    title: "Доступ до будильників вимкнено",
                    description: "Щоб ми могли вчасно вас розбудити, дозвольте застосунку керувати будильниками в Налаштуваннях."
                )
                
            case .empty:
                showPlaceholder(imageName: "clock", title: "Тут поки що тихо...", description: "Ваші будильники з’являться тут, щойно ви оберете ідеальний час для сну.")
                
            case .represent:
                TimelineView(.everyMinute) { _ in
                    List {
                        ForEach(
                            manager.scheduled.sorted(
                                using: [KeyPathComparator(\.hour, order: .forward),
                                        KeyPathComparator(\.minute, order: .forward)])
                        ) { alarm in
                            ScheduledAlarmView(alarm: alarm)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        AlarmScheduleProvider.shared.cancelAlarm(id: alarm.id)
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.textPrimary)
                                    }
                                    .tint(.appRed)
                                }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 9, leading: 18, bottom: 9, trailing: 18))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            case .none: Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .task {
            manager.isAuthorized = await manager.checkForAuthorization()
        }
    }
    
    @ViewBuilder
    private func showPlaceholder(imageName: String, title: LocalizedStringResource, description: LocalizedStringResource) -> some View {
        VStack(spacing: 12) {
            Image(systemName: imageName)
                .font(.system(size: 50))
                .foregroundStyle(.textSecondary)
            
            Text(title).title2()
            
            // MARK: -
            Text(description).caption1()
        }
        .containerRelativeFrame(.vertical, count: 4, span: 3, spacing: 10.0)
        .multilineTextAlignment(.center)
        .padding(40)
    }
}

enum AlarmsState {
    case accessDenied, empty, represent, none
}

struct ScheduledAlarmView: View {
    @State var alarm: CycleAlarm
    @State private var internalPause: Bool
    @State private var isPresented = false
    
    init(alarm: CycleAlarm) {
        self.alarm = alarm
        self.internalPause = !alarm.isPaused
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.name ?? "Будильник")
                    .description3()
                
                Text(alarm.scheduledTimeFormated)
                    .timeStyle(fontSize: 40)
                
                Text("\(alarm.cyclesLeftFormated)  •  \(alarm.timeLeftFormated)")
                    .foregroundStyle(.textPrimary)
            }
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    AlarmEditSheet(alarm) { alarm in
                        internalPause = true
                        AlarmScheduleProvider.shared.updateAlarm(config: alarm)
                    } destruct: { id in
                        Task { withAnimation(.bouncy(duration: 0.3)) {
                            AlarmScheduleProvider.shared.cancelAlarm(id: alarm.id)
                        } }
                    }
                }
            }
            .opacity(alarm.isPaused ? 0.6 : 1)
            Spacer()
            TogglePicker(isOn: $internalPause)
        }
        .card()
        .animation(.smooth(duration: 0.3), value: alarm.isPaused)
        .onChange(of: internalPause) {
            alarm.isPaused = !internalPause
            AlarmScheduleProvider.shared.toggleAlarm(alarm)
        }
        .onTapGesture {
            isPresented.toggle()
        }
    }
}

#Preview {
    NavigationStack {
        AlarmsListView()
            .navigationBarTitleDisplayMode(.inline)
    }
}
