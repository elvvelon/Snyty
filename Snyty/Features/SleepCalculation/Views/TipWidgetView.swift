import SwiftUI

struct TipWidgetView: View {
    let tip: SleepTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: tip.icon).foregroundStyle(tip.color)
                Text(tip.title)
            }
            .subtitle2()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(tip.description)
                .description3()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card() {
            ZStack {
                LinearGradient (stops: [
                    .init(color: .appContext, location: 0.3),
                    .init(color: tip.color, location: 3.5)
                ], startPoint: .top, endPoint: .bottomTrailing)
                HStack {
                    Spacer()
                    Image(systemName: tip.icon)
                        .font(.system(size: 90, weight: .semibold))
                        .foregroundStyle(.textSecondary.opacity(0.3))
                        .rotationEffect(.degrees(-30))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .offset(x: 24, y: 24)
                }
            }
        } stroke: {
            LinearGradient (stops: [
                .init(color: .appSecondary, location: 0.3),
                .init(color: tip.color, location: 2)
            ], startPoint: .top, endPoint: .bottomTrailing)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(SleepTip.data) { tip in
                TipWidgetView(tip: tip)
            }
        }
        .padding()
    }
    .background(.appBackground)
}
