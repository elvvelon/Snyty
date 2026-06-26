import SwiftUI
import Snytysia

struct SleepRecordsView: View {
    @State private var sessions = SleepHistory.loadAllSessions()
    
    var body: some View {
        Group {
            if sessions.count > 0 {
                List {
                    ForEach(sessions) { session in
                        NavigationLink {
                            SleepSessionView(session: session)
                        } label: {
                            showSession(session)
                        }
                        .card()
                        .swipeActions {
                            Button(role: .destructive) {
                                sessions.removeAll { $0.id == session.id }
                                SleepHistory.deleteSession(session: session)
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
                .scrollIndicators(.never)
            } else {
                Text("Тут поки порожньо")
                    .description1()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text("Записи сну")
                    .subtitle1()
            }
        }
    }
    
    @ViewBuilder
    private func showSession(_ session: SleepSession) -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.formatStartDate)
                    .title2()
                
                Text("\(session.startDate.formatedTime) – \(session.endDate?.formatedTime ?? "--:--")")
                    .description3()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                Text(session.duration ?? "--")
                    .title3()
                
                HStack {
                    Image(systemName: "speaker.wave.2")
                    Text("\(max(0, (session.avarageNoiseVolume ?? -200) + 95)) дБ")
                }
                .caption2()
                
                Spacer()
            }
            
            ScrollView(.horizontal) {
                HStack {
                    showCounter(metric: session.snoreCount, name: String(localized: "Хропіння"))
                    showCounter(metric: session.talkCount, name: String(localized: "Розмови"))
                    showCounter(metric: session.coughCount, name: String(localized: "Кашель"))
                }
                .padding(.horizontal, 6)
            }
            .scrollIndicators(.never)
            .mask {
                LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.04),
                    .init(color: .black, location: 0.96),
                    .init(color: .clear, location: 1)
                ], startPoint: .leading, endPoint: .trailing)
            }
            .padding(.horizontal, -6)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func showCounter(metric: Int, name: String) -> some View {
        if metric > 0 {
            Text("\(name): \(metric)")
                .foregroundStyle(.textPrimary)
                .font(.system(size: 14))
                .padding(.horizontal, 6)
                .padding(6)
                .background(.appSecondary)
                .clipShape(.capsule)
        }
    }
}

#Preview {
    NavigationStack {
        SleepRecordsView()
    }
}
