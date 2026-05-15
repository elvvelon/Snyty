import SwiftUI

enum Chronotype: Equatable {
    case lark, dove, owl
    
    var name: LocalizedStringKey {
        switch self {
        case .lark: return "Жайворонок"
        case .dove: return "Голуб"
        case .owl:  return "Сова"
        }
    }
    
    var imageName: String {
        switch self {
        case .lark: return "lark"
        case .dove: return "dove"
        case .owl:  return "owl"
        }
    }
    
    var color: Color {
        switch self {
        case .lark: return .appYellow
        case .dove: return .accentColor
        case .owl:  return .appPrimary
        }
    }
}

struct ChronotypeView: View {
    @State private var offset = AppPresetsManager.shared.biorhythmOffset * 2
    @State private var hoursOffset = AppPresetsManager.shared.biorhythmOffset
    @State private var showAllHours = false
    @State private var opacityDeadline = 0.0
    
    private var chronotype: Chronotype {
        switch offset {
        case ..<(-1.5):  return .lark
        case -1.5..<4.0: return .dove
        default:         return .owl
        }
    }
    
    private var timeString: String {
        let hours = Int(hoursOffset + 8)
        let minutes = Int(((hoursOffset).truncatingRemainder(dividingBy: 1)) * 60)
        return String(format: "%02d:%02d", hours, abs(minutes))
    }
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Ваш хронотип")
                    .title1()
                
                Text("О котрій ви зазвичай прокидаєтеся?")
                    .caption1()
            }
            
            VStack(spacing: 24) {
                if !showAllHours {
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(.appContext)
                                .stroke(.appSecondary, lineWidth: 0.6)
                                .frame(width: 160)
                            
                            Image(chronotype.imageName)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .foregroundStyle(chronotype.color)
                                .frame(width: 80, height: 80)
                                .id(chronotype)
                                .transition(.blurReplace)
                        }
                        
                        Text(chronotype.name).title1()
                        
                        VStack(spacing: 8) {
                            SlidePicker(value: $offset, bounds: -6.0...10.0, tint: chronotype.color)
                            
                            HStack(alignment: .top) {
                                Text("05:00")
                                
                                Text(timeString)
                                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.textPrimary)
                                    .frame(maxWidth: .infinity)
                                
                                Text("13:00")
                            }
                            .foregroundStyle(.textSecondary)
                        }
                        .padding(.horizontal, 40)
                    }
                    .animation(.smooth(duration: 0.3), value: chronotype)
                } else {
                    TimePicker(.h(
                        Binding(get: { Int(hoursOffset + 8) },
                                set: { hoursOffset = Double($0) - 8 })))
                }
                
                Button {
                    withAnimation(.bouncy) {
                        showAllHours.toggle()
                        offset = 0
                        hoursOffset = 0
                    }
                } label: {
                    Text(!showAllHours ? "Інший" : "Назад")
                    if showAllHours {
                        Image(systemName: "arrow.uturn.backward")
                    }
                }
                .font(.system(size: 16))
                .foregroundStyle(.textSecondary)
            }
            .frame(maxHeight: .infinity)
            .onChange(of: offset) {
                hoursOffset = offset.rounded() / 2
            }
        }
        .onDisappear {
            AppPresetsManager.shared.biorhythmOffset = hoursOffset
        }
    }
}

#Preview {
    ChronotypeView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(.appBackground)
}
