import SwiftUI
import Charts
import Snytysia

struct NoiseLevelsView: View {
    @State var data: [SleepEvent] = []
    let avarageVolume: Int
    private let volumeGradient = LinearGradient(
        colors: [.green, .yellow, .orange, .red],
        startPoint: .bottom,
        endPoint: .top
    )
    private var description: LocalizedStringResource {
        switch avarageVolume {
        case 0..<25:
            return "Зразкова тиша. Навколо було дуже спокійно, що ідеально для глибокого й здорового сну."
            
        case 25..<50:
            return "Усе чудово. Траплялися незначні звуки, але вони не заважали вам повноцінно відпочивати."
            
        case 50..<75:
            return "Помірний шум. Зафіксовані звуки могли зробити сон поверхневим — варто завісити вікна або увімкнути білий шум."
            
        case 75...100:
            return "Занадто гучно. Такий рівень звуку часто провокує мікропробудження, наступного разу краще використати беруші."
            
        default:
            return "Розраховуємо середні показники гучності за ніч..."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Рівні шуму за ніч").subtitle2()
                Text(description).caption2()
            }
            
            Chart {
                ForEach(data) { item in
                    LineMark(
                        x: .value("Час", item.timestamp),
                        y: .value("Рівень", item.volumeInDb)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .alignsMarkStylesWithPlotArea()
                    
                    AreaMark(
                        x: .value("Час", item.timestamp),
                        y: .value("Рівень", item.volumeInDb),
                        stacking: .unstacked
                    )
                    .foregroundStyle(volumeGradient)
                    .alignsMarkStylesWithPlotArea()
                    .interpolationMethod(.catmullRom)
                    .opacity(0.15)
                }
            }
            .foregroundStyle(volumeGradient)
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .chartYScale(domain: 0...100)

            .padding(.vertical)
            .frame(height: 160)
        }
    }
}

#Preview {
    @Previewable @State var animationID = UUID()
    
    let baseTime = Date()
            let mockEvents = [
                SleepEvent(id: UUID(), type: .noise, timestamp: baseTime, duration: 6.3, audioFileName: nil, volume: -90),
                SleepEvent(id: UUID(), type: .noise, timestamp: baseTime.addingTimeInterval(15), duration: 8.7, audioFileName: nil, volume: -85),
                SleepEvent(id: UUID(), type: .sleepTalk, timestamp: baseTime.addingTimeInterval(20), duration: 3.8, audioFileName: "talk.caf", volume: -60),
                SleepEvent(id: UUID(), type: .noise, timestamp: baseTime.addingTimeInterval(40), duration: 8.7, audioFileName: nil, volume: -80),
                SleepEvent(id: UUID(), type: .noise, timestamp: baseTime.addingTimeInterval(60), duration: 5.0, audioFileName: nil, volume: -70)
            ]
    
    NoiseLevelsView(data: mockEvents, avarageVolume: 10)
        .card()
        .padding()
        .frame(maxHeight: .infinity)
        .background(.appBackground)
}
