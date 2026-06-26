import SwiftUI
import Charts

struct BiorhythmWidgetView: View {
    @State private var vm = BiorhythmViewModel()
    @State private var appearProgress = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Гормональний баланс").subtitle2()
                Text(vm.descrintion).caption2()
            }
            
            Chart {
                RuleMark(
                    x: .value("Зараз", Date())
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .foregroundStyle(.textPrimary)
                
                ForEach(vm.chartData) { item in
                    LineMark(
                        x: .value("Час", item.time),
                        y: .value("Рівень", item.level)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(by: .value("Тип", item.type.rawValue))
                    
                    AreaMark(
                        x: .value("Час", item.time),
                        y: .value("Рівень", item.level),
                        stacking: .unstacked
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(by: .value("Тип", item.type.rawValue))
                    .opacity(0.15)
                }
            }
            .chartLegend(.hidden)
            .chartForegroundStyleScale([
                "Мелатонін": .appPrimary,
                "Кортизол": .appYellow
            ])
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...120)
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(.textSecondary.opacity(0.3))
                    
                AxisValueLabel(format: .dateTime.hour().minute())
                    .foregroundStyle(.textSecondary)
                }
            }
            .chartScrollPosition(initialX: vm.snapTargetDate)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 12 * 3600)
            
            .chartScrollTargetBehavior(
                .valueAligned(
                    matching: vm.snapTargetComponents,
                    majorAlignment: .matching(vm.snapTargetComponents)
                )
            )
            .frame(height: 180)
            .mask {
                LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.08),
                    .init(color: .black, location: 0.92),
                    .init(color: .clear, location: 1)
                ], startPoint: .leading, endPoint: .trailing)
            }
            .mask(alignment: .leading) {
                Rectangle()
                    .scaleEffect(x: appearProgress, anchor: .leading)
            }
            .onAppear {
                withAnimation(.smooth(duration: 1).delay(0.1)) {
                    appearProgress = 1.0
                }
            }
            
            HStack(spacing: 16) {
                ForEach([HormoneType.cortisol, HormoneType.melatonin], id: \.rawValue) { hormone in
                    HStack {
                        Text("●").foregroundStyle(hormone.color)
                            .opacity(0.8)
                            .font(.system(size: 10))
                        
                        Text(hormone.rawValue)
                            .caption2()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var animationID = UUID()
    
    VStack {
        BiorhythmWidgetView()
            .padding()
            .id(animationID)
        Button {
            animationID = UUID()
        } label: {
            Text("Animate again")
        }
    }
    .frame(maxHeight: .infinity)
    .background(.appBackground)
}
