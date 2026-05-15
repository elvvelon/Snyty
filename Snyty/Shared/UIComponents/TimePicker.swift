import SwiftUI
import AudioToolbox

// MARK: - Models
enum TimePickerStyle {
    case h(Binding<Int>),m(Binding<Int>), hm(Binding<Int>, Binding<Int>), range(Binding<Int>, Range<Int>, LocalizedStringKey), custom([TimePickerColumn])
    
    var columns: [TimePickerColumn] {
        switch self {
        case .h(let hours): return [
            .init(value: hours, range: 0..<24, label: "hours_key", isInfinite: true)]
            
        case .m(let minutes): return [
            .init(value: minutes, range: 0..<60, label: "mins_key", isInfinite: true)]
            
        case .hm(let hours, let minutes): return [
            .init(value: hours, range: 0..<24, label: "hours_key", isInfinite: true),
            .init(value: minutes, range: 0..<60, label: "mins_key", isInfinite: true)]
            
        case .range(let binding, let range, let label): return [
            .init(value: binding, range: range, label: label)]
            
        case .custom(let columns): return columns
        }
    }
}

struct TimePickerColumn {
    let value: Binding<Int>
    var range: Range<Int>
    let label: LocalizedStringKey
    var isInfinite: Bool = false
}

// MARK: - Main View
struct TimePicker: View {
    private let style: TimePickerStyle
    private let cardStyle: CardStyle
    private let separator: String
    
    init(_ style: TimePickerStyle, _ cardStyle: CardStyle = .standard, separator: String = ":") {
        self.style = style
        self.cardStyle = cardStyle
        self.separator = separator
    }
    
    var body: some View {
        HStack {
            let cols = style.columns
            ForEach(0..<cols.count, id: \.self) { i in
                VStack {
                    CustomPicker(
                        selection: cols[i].value,
                        range: cols[i].range,
                        isInfinite: cols[i].isInfinite)
                    .pickerElementStyle(cardStyle: cardStyle)
                    
                    Text(cols[i].label)
                        .foregroundStyle(.textSecondary)
                }
                
                if i < cols.count - 1 {
                    Text(":")
                        .font(.system(size: 70))
                        .foregroundStyle(.textPrimary)
                        .padding(.bottom, 42)
                }
            }
            
        }
    }
}

// MARK: Picker Scroll View
struct CustomPicker: View {
    let selection: Binding<Int>
    let range: Range<Int>
    let isInfinite: Bool
    
    private let multiplier = 100
    @State private var isInteracting = false
    @State private var internalSelection: Int?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Group {
                if isInfinite {
                    LazyVStack(spacing: 0) { content }
                        .scrollTargetLayout()
                    
                } else {
                    VStack(spacing: 0) { content }
                        .scrollTargetLayout()
                }
            }
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $internalSelection)
        .onChange(of: internalSelection) { _, newValue in
            guard let newValue else { return }
            let pickedValue = isInfinite ? (newValue % range.count) : (range.lowerBound + newValue)
            
            if selection.wrappedValue != pickedValue {
                selection.wrappedValue = pickedValue
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                AudioServicesPlaySystemSound(1157)
            }
        }
        .onAppear {
            if isInfinite {
                internalSelection = (range.count * (multiplier / 2)) + selection.wrappedValue
            } else {
                internalSelection = selection.wrappedValue - range.lowerBound
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        let count = isInfinite ? range.count * multiplier : range.count
        ForEach(0..<count, id: \.self) { index in
            let actualValue = isInfinite ? (index % range.count) : (range.lowerBound + index)
            
            Text(String(format: isInfinite ? "%0.2d" : "%d", actualValue))
                .font(.system(size: 70, weight: .bold, design: .rounded))
                .foregroundStyle(.textPrimary)
                .frame(height: 100, alignment: .center)
                .padding(.horizontal)
                .id(index)
        }
    }
}

// MARK: - View Modifiers
extension View {
    func pickerElementStyle(cardStyle: CardStyle) -> some View {
        self
            .mask {
                LinearGradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.25),
                    .init(color: .black, location: 0.75),
                    .init(color: .clear, location: 1)
                ], startPoint: .top, endPoint: .bottom)
            }
            .fixedSize(horizontal: true, vertical: false)
            .frame(height: 100)
            .card(padding: 0, radius: 18, cardStyle: cardStyle)
    }
}

#Preview {
    @Previewable @State var hrs = 7
    @Previewable @State var mins = 30
    @Previewable @State var a = 100
    
    TimePicker(.hm($hrs, $mins))
    Text("\(hrs) : \(mins)")
    
    TimePicker(.range($a, 0..<200, "sd"), .light)
    Text("\(a)")
}
