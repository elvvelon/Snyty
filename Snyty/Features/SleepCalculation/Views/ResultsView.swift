import SwiftUI
import AlarmKit

struct ResultsView: View {
    var vm: CalculatorViewModel
    @State private var showAnimation = false
    
    var body: some View {
        VStack {
            headerView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(vm.calculatedResults.sorted(by: { $0.cycles > $1.cycles })) { alarm in
                        if showAnimation {
                            CalculatedAlarmView(
                                alarm: alarm,
                                targetTime: vm.formattedTargetTime,
                                iconName: vm.actionIconName,
                                isScheduled: vm.isScheduled(alarm: alarm)) {
                                    vm.schedule(alarm: alarm)
                                }
                                .transition(.push(from: .bottom))
                        }
                    }
                }
                .onAppear { animate() }
                .frame(maxWidth: .infinity)
                .padding()
                .padding(.vertical, 20)
            }
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .appBackground, location: 0.1),
                        .init(color: .appBackground, location: 0.9),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            
            footerView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground.ignoresSafeArea())
        .task {
            vm.performCalculation()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                VStack(alignment: .trailing) {
                    Text(vm.toolbarTitle)
                        .textCase(.uppercase)
                        .foregroundStyle(.textSecondary)
                    Text(vm.formattedTargetTime)
                        .timeStyle(fontSize: 20)
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
    
    func animate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.snappy(duration: 0.5, extraBounce: 0.4)) {
                showAnimation = true
            }
        }
    }
}

//MARK: - Calculations View
struct CalculatedAlarmView: View {
    let alarm: CalculatedSleep
    let targetTime: String
    let iconName: String
    var isScheduled: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Group {
                    if alarm.cycles == 5 {
                        Text("Найкращий варіант")
                            .foregroundStyle(.appPrimary)
                        
                    } else if alarm.cycles == 6 {
                        Text("Повне відновлення")
                            .foregroundStyle(.textSecondary)
                    }
                }
                .textCase(.uppercase)
                .font(.system(size: 16, weight: .bold))
                
                Text(alarm.time.formatedTime)
                    .timeStyle()
                
                Text(alarm.formatedInfo)
                    .foregroundStyle(.textSecondary)
            }
            
            Spacer()
            
            showButton()
        }
        .card(padding: 24, radius: 24) {
            alarm.cycles == 5 ? Color.appSecondary.opacity(0.8) : Color.appContext
        } stroke: {
            alarm.cycles == 5 ? .appPrimary.opacity(0.4) : .appSecondary
        }
    }
    
    @ViewBuilder
    func showButton() -> some View {
        ZStack {
            if !isScheduled {
                Button(action: { action() }) {
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.textPrimary.opacity(0.8))
                        .padding()
                }
                .glassEffect(alarm.cycles == 5 ? .clear.tint(.appPrimary.opacity(0.6)).interactive() : .clear.interactive())
                
            } else {
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.appPrimary)
                    .padding()
            }
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.snappy(duration: 0.3), value: isScheduled)
    }
}

//MARK: - UI Components
private extension ResultsView {
    var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: vm.iconName)
                .font(.system(size: 28, weight: .bold))
                .padding(10)
                .icon()
            
            Text(vm.resultsTitle).title1()
            Text(vm.resultsCaption).caption1()
        }
        .frame(maxWidth: 250)
        .padding()
    }
    
    var footerView: some View {
        HStack {
            Image(systemName: "info")
                .padding(6)
                .icon(color: .appYellow)
            
            Text("Ми врахували \(Text("\(vm.calculationMode == .targetWakeUp ? AppPresetsManager.shared.fallAsleepDuration : vm.customFallAsleepDuration) хвилин").foregroundStyle(.textPrimary).bold()) на засинання. Цей параметр можна змінити в налаштуваннях.")
                .foregroundStyle(.textSecondary)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .card(padding: 24, radius: 24, stroke: { .appSecondary.opacity(0.6) })
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var vm = CalculatorViewModel()
    NavigationStack {
        ResultsView(vm: vm)
    }
    .onAppear {
        vm.calculationMode = .targetWakeUp
    }
}
