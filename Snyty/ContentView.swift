import SwiftUI
import AlarmKit

enum AppRoute: @MainActor TabItem {
    case mainPage, alarms, settings
    
    var title: LocalizedStringResource? { return nil }
    var icon: String? {
        switch self {
        case .mainPage:
            "house.fill"
        case .alarms:
            "alarm.fill"
        case .settings:
            "person.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppRoute = .mainPage
    @State var isPresented = false
    private var navigationTitle: String {
            switch selectedTab {
            case .settings: return "Налаштування"
            case .mainPage: return ""
            case .alarms: return "Будильники"
            }
        }
    
    private var greeting: LocalizedStringResource {
        let hour = Date().hour
        switch hour {
        case 0...5: return "Доброї ночі!"
        case 6...11: return "Доброго ранку!"
        case 12...17: return "Добрий день!"
        case 18...23: return "Добрий вечір!"
        default: return "Вітаємо!"
        }
    }

    private var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, dMMMM")

        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        if AppPresetsManager.shared.isOnboarded {
            NavigationStack {
                VStack {
                    Group {
                        switch selectedTab {
                        case .mainPage: HomePageView()
                        case .alarms:   AlarmsListView()
                        case .settings: SettingsView()
                        }
                    }
                }
                .safeAreaPadding(.bottom)
                .safeAreaInset(edge: .bottom) {
                    TabPicker(selection: $selectedTab, tinted: true)
                        .card(padding: 6)
                        .padding(.horizontal, 48)
                }
                .toolbar {
                    switch selectedTab {
                    case .settings:
                        ToolbarItem(placement: .title) {
                            Text("Налаштування")
                                .textCase(.uppercase)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.textPrimary)
                        }
                        
                    case .mainPage:
                        ToolbarItem(placement: .topBarLeading) {
                            SnytyLogoView()
                                .frame(width: 100, height: 40)
                                .padding(.top, 14)
                        }
                        .sharedBackgroundVisibility(.hidden)
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            VStack(alignment: .trailing) {
                                Text(greeting)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.appPrimary)
                                
                                Text(date)
                                    .foregroundStyle(.textSecondary)
                            }
                            .font(.system(size: 16))
                        }
                        .sharedBackgroundVisibility(.hidden)
                        
                    case .alarms:
                        if AlarmScheduleProvider.shared.isAuthorized {
                            ToolbarItem {
                                Button {
                                    isPresented.toggle()
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundStyle(.textPrimary)
                                }
                            }
                        }
                        
                        ToolbarItem(placement: .title) {
                            Text("Будильники")
                                .textCase(.uppercase)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.textPrimary)
                        }
                    }
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .tint(.appPrimary)
                .tabBarMinimizeBehavior(.never)
                .sheet(isPresented: $isPresented) {
                    NavigationStack {
                        AlarmEditSheet() { alarm in
                            Task {
                                await AlarmScheduleProvider.shared.scheduleAlarm(alarm)
                            }
                        }
                        .toolbarVisibility(.hidden, for: .bottomBar)
                    }
                }
            }
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
