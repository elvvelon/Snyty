import SwiftUI
import AVFAudio
import Snytysia

struct SleepSessionView: View {
    let session: SleepSession
    @State private var audioManager = AudioPlaybackManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    showStats(
                        iconName: "clock",
                        metric: session.duration ?? "0 год 0 хв",
                        name: "Тривалість сну"
                    )
                    
                    let noiseDuration = TimeInterval(
                        session.events.filter { $0.type == .noise }
                                      .reduce(0.0) { $0 + ($1.duration ?? 0.0) }
                    )
                    showStats(iconName: "ear.badge.waveform",
                              metric: "\(noiseDuration.durationFormated)",
                              name: "Тривалість шумів"
                    )
                }
                
                let noises = session.events.filter { $0.type == .noise }
                if noises.count > 1 {
                    NoiseLevelsView(data: noises, avarageVolume: session.avarageNoiseVolume ?? -1)
                        .card()
                }
                
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    GridRow {
                        showCounter(iconName: "bubble", metric: "\(session.talkCount)", name: "Розмови")
                        showCounter(iconName: "waveform", metric: "\(session.snoreCount)", name: "Хропіння")
                    }
                    
                    GridRow {
                        showCounter(
                            iconName: "wind",
                            metric: "\(session.coughCount)",
                            name: "Чхання / кашель"
                        )
                        
                        showCounter(
                            iconName: "speaker.wave.2",
                            metric: "\(max(0, (session.avarageNoiseVolume ?? -200) + 95)) дБ",
                            name: "Загальна гучність"
                        )
                    }
                }
                
                let events = session.events.filter { $0.audioFileName != nil }
                if events.count > 0 {
                    Text("Записи (\(events.count))")
                        .subtitle3()
                    
                    LazyVStack(spacing: 16) {
                        ForEach(events) { event in
                            SleepEventPlayerView(event: event)
                                .environment(audioManager)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(.appBackground)
        .onDisappear { audioManager.stop() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                VStack(alignment: .trailing) {
                    Text(session.formatStartDate)
                        .subtitle1()
                    Text("\(session.startDate.formatedTime) – \(session.endDate?.formatedTime ?? "")")
                        .description3()
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
    
    @ViewBuilder
    private func showStats(iconName: String, metric: String, name: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: iconName)
                .icon()
            Text(metric)
                .timeStyle(fontSize: 24)
            Text(name)
                .caption2()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 14)
    }
    
    @ViewBuilder
    private func showCounter(iconName: String, metric: String, name: LocalizedStringKey) -> some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .icon()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(metric)
                    .timeStyle(fontSize: 24)
                Text(name)
                    .caption2()
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 14)
    }
}

struct SleepEventPlayerView: View {
    let event: SleepEvent
    @Environment(AudioPlaybackManager.self) private var audioManager
    
    private var internalPlaying: Bool { isMyTrack && audioManager.isPlaying }
    private var isMyTrack: Bool {
        audioManager.currentTrackID == event.id
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(LocalizedStringKey(event.type.rawValue))
                    .title3()
                
                Spacer()
                
                Text(event.timestamp.formatedTime)
                    .caption2()
            }
            
            HStack {
                Button {
                    if let audioURL = event.audioURL {
                        audioManager.togglePlayback(for: event.id, fileURL: audioURL)
                    }
                } label: {
                    Image(systemName: internalPlaying ? "pause.fill" : "play.fill")
                        .foregroundStyle(internalPlaying ? .appBackground : .textPrimary)
                        .buttonLabel(padding: 6)
                }
                .tint(internalPlaying ? .appPrimary : .appSecondary)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                
                WaveformSlider(amplitudes: event.amplitudes ?? [], progress: Binding(
                    get: {
                        isMyTrack ? audioManager.playbackProgress : 0.0
                    },
                    set: { newValue in
                        if isMyTrack { audioManager.seek(to: newValue) }
                    }
                )) {
                    if isMyTrack && !audioManager.isPlaying {
                        audioManager.resume()
                    }
                }
                .frame(height: 30)
                .disabled(!isMyTrack)

                Text(event.durationFormated)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(.textSecondary)
            }
            .animation(.default, value: internalPlaying)
        }
        .card()
    }
}



extension TimeInterval {
    var durationFormated: String {
        let totalSeconds = Int(self)
        if totalSeconds <= 0 { return "0 с" }
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours == 0 && minutes == 0 { return "\(seconds) с" }
        if hours == 0 { return String(format: "%02d:%02d", minutes, seconds) }
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        if let session = SleepHistory.lastSession {
            SleepSessionView(session: session)
        }
    }
}
