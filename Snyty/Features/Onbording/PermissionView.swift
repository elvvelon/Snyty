import SwiftUI
import AlarmKit

enum AuthorizationState {
    case notDetermined, authorized, denied
}

struct PermissionView: View {
    @State private var notificationsState: AuthorizationState = .notDetermined
    @State private var alarmsState: AuthorizationState = .notDetermined
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 8) {
                Text("Дозвольте нам допомогти")
                    .title1()
                Text("Щоб розбудити вас у найкращий для цього час чи нагадати, що вже час йти спати, нам потрібні наступні дозволи:")
                    .caption1()
            }
            
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "bell")
                        .icon()
                    
                    VStack(alignment: .leading) {
                        Text("Сповіщення")
                            .title2()
                        
                        Text("Нагадування про сон")
                            .font(.system(size: 16))
                            .caption2()
                    }
                    
                    Spacer()
                    
                    switch notificationsState {
                    case .notDetermined:
                        Button {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
                                Task { @MainActor in
                                    withAnimation {
                                        notificationsState = success ? .authorized : .denied
                                    }
                                }
                            }
                        } label: {
                            Text("Надати")
                                .buttonLabel(padding: 6)
                        }
                        .tint(.appPrimary)
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 20))
                        
                    case .authorized:
                        Image(systemName: "checkmark")
                            .title2()
                            .padding(6)
                        
                    case .denied:
                        Button {
                            guard let url = URL(string: UIApplication.openSettingsURLString),
                                  UIApplication.shared.canOpenURL(url) else { return }
                            UIApplication.shared.open(url)
                        } label: {
                            Text("Перейти в налаштування")
                                .padding(6)
                                .font(.system(size: 16))
                        }
                        .tint(.appPrimary)
                    }
                    
                }
                .card()
                
                HStack(spacing: 12) {
                    Image(systemName: "alarm")
                        .icon()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Будильники")
                            .title2()
                        
                        Text("Щоб будити вас вчасно")
                            .font(.system(size: 16))
                            .caption2()
                    }
                    
                    Spacer()
                    
                    switch alarmsState {
                    case .notDetermined:
                        Button {
                            Task {
                                let state = try? await AlarmManager.shared.requestAuthorization()
                                withAnimation {
                                    alarmsState = state == .authorized ? .authorized : .denied
                                }
                            }
                        } label: {
                            Text("Надати")
                                .buttonLabel(padding: 6)
                        }
                        .tint(.appPrimary)
                        .buttonStyle(.glassProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 20))
                        
                    case .authorized:
                        Image(systemName: "checkmark")
                            .title2()
                            .padding(6)
                        
                    case .denied:
                        Button {
                            guard let url = URL(string: UIApplication.openSettingsURLString),
                                  UIApplication.shared.canOpenURL(url) else { return }
                            UIApplication.shared.open(url)
                        } label: {
                            Text("Перейти в налаштування")
                                .padding(6)
                                .font(.system(size: 16))
                        }
                        .tint(.appPrimary)
                    }
                    
                }
                .card()
            }
            .task {
                switch AlarmManager.shared.authorizationState {
                case .notDetermined: alarmsState = .notDetermined
                case .authorized:    alarmsState = .authorized
                case .denied:        alarmsState = .denied
                @unknown default:    alarmsState = .denied
                }
                
                let settings = await UNUserNotificationCenter.current().notificationSettings()

                switch settings.authorizationStatus {
                case .denied: notificationsState = .denied
                case .notDetermined: notificationsState = .notDetermined
                default: notificationsState = .authorized
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    PermissionView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.appBackground)
}
