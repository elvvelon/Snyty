import SwiftUI
import Snytysia

struct SnytysiaWidgetView: View {
    @Environment(SnytysiaObserver.self) private var classifier
    @State private var recAnimate = false
    @State private var showAnalizer = false
    
    var body: some View {
        VStack(spacing: 16) {
            headerView.onTapGesture { showAnalizer = true }
            
            trackerButtonView
            
            if let session = classifier.lastSession {
                Divider()
                
                showLastSessionView(session)
            }
        }
        .navigationDestination(isPresented: $showAnalizer) {
            TrackerView()
        }
        .frame(maxWidth: .infinity)
        .card()
    }
    
    
    // MARK: - UI Components
    private var headerView: some View {
        HStack(spacing: 16) {
            Image(systemName: "moon.stars")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.appPrimary)
                .frame(width: 60, height: 60)
                .background(.appPrimary.opacity(0.2))
                .clipShape(.rect(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Аналізатор сну")
                    .title2()
                Text("Дізнайтеся, що відбувається, поки ви спите")
                    .caption2()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var trackerButtonView: some View {
        Button {
            if case .inactive = classifier.trackingState {
                classifier.toggleRecording()
            }
            showAnalizer = true
        } label: {
            Group {
                switch classifier.trackingState {
                case .inactive:
                    HStack {
                        Image(systemName: "microphone")
                        Text("Почати запис")
                    }
                    .frame(maxWidth: .infinity)
                case .delayed(let startDate, let delay):
                    let fireDate = startDate.addingTimeInterval(delay)
                    delayedButtonLabel(fireDate: fireDate)
                        .foregroundStyle(.textPrimary)
                case .tracking:
                    trackingButtonLabel
                }
            }
            .buttonLabel()
        }
        .tint( {
            switch classifier.trackingState {
            case .inactive: return .appPrimary
            case .delayed: return .appSecondary
            case .tracking: return .textPrimary
            } }()
        )
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.roundedRectangle(radius: 20))
    }
    
    private var trackingButtonLabel: some View {
        HStack(spacing: 12) {
            Circle().fill(.appRed).frame(width: 10)
                .opacity(recAnimate ? 1 : 0.5)
            Text("Триває запис")
        }
        .navigationMark()
        .onAppear {
            withAnimation(.snappy(duration: 0.5).repeatForever()) {
                recAnimate = true
            }
        }
    }
    
    private func delayedButtonLabel(fireDate: Date) -> some View {
        HStack(alignment: .lastTextBaseline) {
            TimelineView(.everyMinute) { context in
                let timeRemaining = fireDate.timeIntervalSince(context.date)
                let minutesLeft = Int(ceil(timeRemaining / 60.0))
                
                HStack {
                    if minutesLeft > 0 {
                        Text("Старт за \(minutesLeft) хв")
                    } else {
                        Text("Незабаром почнемо")
                    }
                }
            }
            
            LoadingDotsView()
        }
        .navigationMark()
    }
    
    @ViewBuilder
    private func showLastSessionView(_ session: SleepSession) -> some View {
        let dateString = session.startDate.formatted(
            Date.FormatStyle()
                .month(.wide)
                .day(.twoDigits)
                .hour(.defaultDigits(amPM: .abbreviated))
                .minute(.twoDigits)
        )
        
        let description: (LocalizedStringKey, Color) = {
            switch session.avarageNoiseVolume ?? -1 {
            case 0..<35: ("Тихо", .appGreen)
            case 36..<60: ("Помірний шум", .appYellow)
            case 61...100: ("Доволі гучно", .orange)
            default: ("Аналіз", .appPrimary)
            }
        }()
        
        NavigationLink {
            SleepSessionView(session: session)
        } label: {
            VStack(spacing: 16) {
                HStack {
                    Text("Останній запис:\n\(dateString)")
                        .multilineTextAlignment(.leading)
                        .caption2()
                    
                    Spacer()
                    
                    Text(description.0)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(description.1)
                        .padding(.horizontal, 6)
                        .padding(6)
                        .background(description.1.opacity(0.2))
                        .clipShape(.capsule)
                }
                .frame(minHeight: 40)
                
                Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                    GridRow {
                        sleepData(iconName: "clock", metric: session.duration ?? "0 год 0 хв", description: "Тривалість")
                        
                        sleepData(iconName: "speaker.wave.3", metric: "\(max(0, (session.avarageNoiseVolume ?? -200) + 95)) дБ", description: "Шум")
                    }
                    GridRow {
                        sleepData(iconName: "wind", metric: "\(session.coughCount)", description: "Кашель / чхання")
                        
                        sleepData(iconName: "waveform", metric: "\(session.snoreCount + session.talkCount)", description: "Сомнілоквія")
                        
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func sleepData(iconName: String, metric: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: iconName)
                .foregroundStyle(.appPrimary)
                .fontWeight(.semibold)
            Text(metric)
                .title2()
            Text(description)
                .caption2()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 14, cardStyle: .light)
    }
}

#Preview {
    NavigationStack {
        SnytysiaWidgetView()
            .padding()
    }
    .environment(SnytysiaObserver())
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appBackground)
}
