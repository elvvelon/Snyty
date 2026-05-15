import SwiftUI

enum AccentSection {
    case alarms, naps
}

struct HomePageView: View {
    @State private var vm = CalculatorViewModel()
    @State private var tip: SleepTip = SleepTip.randomTip
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                TabPicker(selection: $vm.pageSection, tinted: true, animation: .bouncy)
                    .card(padding: 6)
                
                Group {
                    switch vm.pageSection {
                    case .dashboard:
                        dashboardSection
                    case .sleep:
                        sleepSection
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: .appBackground, location: 0.6)])
        )
        .background(StarfieldView().background(.appBackground).ignoresSafeArea(edges: .top))
    }
    
    var dashboardSection: some View {
        VStack(spacing: 28) {
            TipView(tip: tip).onAppear { tip = SleepTip.randomTip }
            BiorhythmView().card()
            
            if let nextAlarm = AlarmScheduleProvider.shared.nextAlarm {
                TimelineView(.everyMinute) { _ in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Наступний будильник")
                            .subtitle2()
                        Text(nextAlarm.scheduledTimeFormated)
                            .timeStyle(fontSize: 40)
                        Text("\(nextAlarm.cyclesLeftFormated)  •  \(nextAlarm.timeLeftFormated)")
                            .description3()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .card()
                }
            }
            
            section("Аналіз сну") {
                Text("Скоро...")
                    .title2()
                    .padding(.vertical, 60)
                    .frame(maxWidth: .infinity)
                    .card()
            }
        }
    }
    
    var sleepReminde: some View {
        VStack {
            
        }
    }
    
    var sleepSection: some View {
        VStack(spacing: 28) {
            section("Розрахувати") {
                VStack(spacing: 18) {
                    TabPicker(selection: $vm.calculationMode, animation: .bouncy)
                    
                    Group {
                        if vm.calculationMode == .targetWakeUp {
                            TimePicker(.hm($vm.selectedHour, $vm.selectedMinute), .light)
                            .transition(.move(edge: .leading))
                        } else {
                            VStack(spacing: 20) {
                                Text("Цього разу мені потрібно на засинаня:")
                                    .description1()
                                
                                SlidePicker(value: Binding(get: {Double(vm.customFallAsleepDuration)}, set: {vm.customFallAsleepDuration = Int($0)}), bounds: 0...60)
                                
                                Text("\(vm.customFallAsleepDuration) хв")
                                    .timeStyle()
                            }
                            .padding(.horizontal)
                            .transition(.move(edge: .trailing))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    NavigationLink {
                        ResultsView(vm: vm)
                            .toolbarVisibility(.hidden, for: .tabBar)
                    } label: {
                        Text("Розрахувати")
                            .frame(maxWidth: .infinity)
                            .buttonLabel()
                    }
                    .tint(.appPrimary)
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 20))
                    
                }
                .card(padding: 20, radius: 32, lineWidth: 0.8)
            }
            
            section("Швидкий сон" ) {
                HStack(spacing: 18) {
                    ForEach(NapType.allCases, id: \.imageName) { nap in
                        napSelection(nap)
                    }
                }
            }
        }
    }
    @ViewBuilder
    private func section(_ title: LocalizedStringResource,
                         @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 18) {
            Text(title).subtitle3()
            content()
        }
    }
    
    @ViewBuilder
    private func napSelection(_ nap: NapType) -> some View {
        NavigationLink {
            NapView(nap: nap)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: nap.imageName)
                    .icon(color: nap.color)
                
                Text(nap.title)
                    .subtitle2()
                
                Text(nap.note)
                    .caption2()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }
    }
}

#Preview {
    NavigationStack {
        HomePageView()
            .navigationBarTitleDisplayMode(.inline)
    }
}
