import SwiftUI
import Snytysia

struct TrackerView: View {
    @Environment(SnytysiaObserver.self) private var classifier
    @State private var isAnimating = false
    
    var body: some View {
        @Bindable var classifier = classifier
        VStack(spacing: 20) {
            microphoneAnimationView
                .fixedSize()
                .onTapGesture { classifier.toggleRecording(forceStart: false) }
            
            if case .delayed(let startDate, let delay) = classifier.trackingState {
                let endDate = startDate.addingTimeInterval(delay)
                HStack(spacing: 0) {
                    Text("Старт через: ")
                    Text(endDate, style: .timer)
                        .fontDesign(.monospaced)
                }
                .timeStyle()
            } else {
                recordingTimerView
                    .fontDesign(.monospaced)
            }
            
            if classifier.trackingState == .tracking {
                eventsCountView
            }
            
            trackerHintView
                .frame(maxHeight: .infinity, alignment: .top)
            
            if case .delayed = classifier.trackingState {
                forceCancelRecordButton
            }
            recordingButton
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .onChange(of: classifier.trackingState)  { isAnimating = classifier.isRecording }
        .onAppear { isAnimating = classifier.isRecording }
        .animation(.smooth(duration: 0.3), value: classifier.trackingState)
        .navigationDestination(isPresented: $classifier.didSaveSession) {
            SleepSessionView(session: classifier.lastSession ?? SleepSession())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text("Аналіз сну")
                    .subtitle1()
            }
        }
    }
    
    // MARK: - UI Components
    private var microphoneAnimationView: some View {
        ZStack {
            Group {
                Circle().stroke(.appSecondary.opacity(0.4), lineWidth: isAnimating ? 1.6 : 2)
                    .frame(width: 200)
                    .scaleEffect(isAnimating ? 1.06 : 0.96)
                
                Circle().stroke(.appSecondary.opacity(0.3), lineWidth: isAnimating ? 1.2 : 1.6)
                    .frame(width: 220)
                    .scaleEffect(isAnimating ? 1.04 : 0.96)
            }
            .opacity(classifier.isRecording ? 1 : 0)
            
            Image(systemName: "microphone")
                .font(.system(size: 60, weight: .semibold))
                .frame(width: 180, height: 180)
                .background(.appSecondary)
                .overlay {
                    if case .delayed(let startDate, let delayDuration) = classifier.trackingState {
                        CircularProgressBar(startDate: startDate, duration: delayDuration)
                    }
                }
                .clipShape(.circle)
                .foregroundStyle(
                    {
                       switch classifier.trackingState {
                       case .inactive : Color.textSecondary
                       case .delayed: Color.appYellow
                       case .tracking: Color.appPrimary
                       }
                    }()
                )
                .shadow(color: .appSecondary, radius: isAnimating ? 34 : 26)
        }
        .scaleEffect(
            {
               switch classifier.trackingState {
               case .inactive : 0.95
               case .delayed: 1
               case .tracking: 1.05
               }
            }()
        )
        .animation(
            classifier.isRecording ?
                .smooth(duration: 3.5).repeatForever(autoreverses: true) :
                .smooth,
            value: isAnimating
        )
    }
    
    @ViewBuilder
    private var recordingButton: some View {
        let iconName: String = {
            switch classifier.trackingState {
            case .inactive: "record.circle.fill"
            case .delayed: "play.fill"
            case .tracking: "stop.fill"
            }
        }()
        
        let label: LocalizedStringKey = {
            switch classifier.trackingState {
            case .inactive: "Почати запис"
            case .delayed: "Розпочати зараз"
            case .tracking: "Завершити запис"
            }
        }()
        
        Button {
            classifier.toggleRecording()
        } label: {
            HStack {
                Image(systemName: iconName)
                Text(label)
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(.textPrimary)
            .padding()
            .frame(maxWidth: .infinity)
        }
        .tint(classifier.isRecording ? .appRed : .appPrimary)
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.roundedRectangle(radius: 20))
    }
    
    private var forceCancelRecordButton: some View {
        Button {
            _ = Snytysia.classifier.stopTracking()
        } label: {
            HStack {
                Image(systemName: "xmark.circle")
                    .fontWeight(.regular)
                Text("Скасувати аналіз")
            }
            .font(.system(size: 18))
            .padding()
            .frame(maxWidth: .infinity)
        }
        .tint(.textPrimary)
        .buttonStyle(.glass)
        .buttonBorderShape(.roundedRectangle(radius: 20))
    }
}

//MARK: - UI Extension
extension TrackerView {
    var recordingTimerView: some View {
        HStack(spacing: 12) {
            Circle().fill(classifier.isRecording ? .appRed : .textSecondary)
                .frame(width: 10, height: 10)
                .opacity(isAnimating ? 1 : 0.5)
                .animation(
                    classifier.isRecording ?
                        .smooth(duration: 0.5).repeatForever(autoreverses: true) :
                            .smooth,
                    value: isAnimating
                )
            
            Group {
                switch classifier.trackingState {
                case .tracking:
                    TimelineView(.periodic(from: classifier.startDate, by: 1.0)) { context in
                        let elapsedTime = context.date.timeIntervalSince(classifier.startDate)
                        Text(formatTimeInterval(elapsedTime))
                    }
                default:
                    Text("00:00:00")
                }
            }
            .timeStyle()
            .monospacedDigit()
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var trackerHintView: some View {
        List {
            let hints: [TrackerHint] = {
                switch classifier.trackingState {
                case .inactive: TrackerHint.aboutSnytysia
                case .delayed: TrackerHint.preparingHints
                case .tracking: TrackerHint.appHints
                }
            }()
            
            ForEach(hints) { hint in
                hintRow(hint: hint)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollContentBackground(.hidden)
        .scrollIndicators(.never)
        .mask {
            LinearGradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.1),
                .init(color: .black, location: 0.9),
                .init(color: .clear, location: 1)
            ], startPoint: .top, endPoint: .bottom)
        }
        .padding(-18)
    }
    
    @ViewBuilder private func hintRow(hint: TrackerHint) -> some View {
        HStack(spacing: 16) {
            Image(systemName: hint.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .icon(color: hint.tint)
            Text(hint.hint)
                .foregroundStyle(.textPrimary)
                .description3()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .listRowBackground(Color.appContext)
    }
    
    @ViewBuilder var eventsCountView: some View {
        HStack(spacing: 8) {
            eventCounter(count: classifier.snoreCount, event: "Хропіння")
            eventCounter(count: classifier.talkCount, event: "Розмови")
            eventCounter(count: classifier.coughCount, event: "Кашель")
            eventCounter(count: classifier.noiseCount, event: "Шум")
        }
    }
    
    @ViewBuilder private func eventCounter(count: Int, event: LocalizedStringKey) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .title2()
            
            Text(event)
                .font(.system(size: 12))
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .card(padding: 12, radius: 19)
    }
}

#Preview {
    @Previewable @State var so = SnytysiaObserver()
    NavigationStack {
        TrackerView()
            .onAppear {
                AppPresetsManager.shared.fallAsleepDuration = 1
            }
    }
    .environment(so)
}
