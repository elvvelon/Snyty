import SwiftUI

struct CircularProgressBar: View {
    let startDate: Date
    let duration: TimeInterval
    var lineWidth: CGFloat = 5
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let progress = calculateProgress(at: timeline.date)
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(
                            LinearGradient(colors: [.orange, .appYellow], startPoint: .top, endPoint: .bottom),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
            }
        }
    }
    
    private func calculateProgress(at currentDate: Date) -> Double {
        let elapsed = currentDate.timeIntervalSince(startDate)
        let progress = elapsed / duration
        return min(max(progress, 0.0), 1.0)
    }
}

#Preview {
    CircularProgressBar(startDate: Date().addingTimeInterval(-10), duration: 20, lineWidth: 10)
        .frame(width: 250, height: 250)
}
