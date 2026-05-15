import SwiftUI

protocol TabItem: Hashable, CaseIterable {
    var title: LocalizedStringResource? { get }
    var icon: String? { get }
}

struct TabPicker<T: TabItem>: View {
    @Binding var selection: T
    
    var tinted: Bool = false
    var animation: Animation = .default
    
    @State private var width: CGFloat = .zero
    @State private var x: CGFloat = 0
    @State private var isInteracting = false
    
    private var scale: CGFloat {
        if isInteracting {
            return 1.1
        }
        return 1.0
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { val in
                withAnimation(.bouncy) { isInteracting = true }
                
                let halfWidth = width / 2
                let totalWidth = width * CGFloat(T.allCases.count)
                
                let loc = min(max(val.location.x - halfWidth, 0), totalWidth - width) / scale
                
                self.x = loc
            }
            .onEnded { val in
                withAnimation(.bouncy) { isInteracting = false }
                
                let rawIndex = Int(val.location.x / width)
                let safeIndex = min(max(0, rawIndex), T.allCases.count - 1)
                
                let newSelection = Array(T.allCases)[safeIndex]
                setMode(newSelection)
            }
    }
    
    
    var body: some View {
        HStack {
            ForEach(Array(T.allCases), id: \.self) { item in
                Button(action: { setMode(item) }) { label(item.title, icon: item.icon) }
            }
        }
        .background (
            GeometryReader { geometry in
                Color.clear
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onAppear {
                        width = geometry.size.width / CGFloat(T.allCases.count)
                        x = width * CGFloat((Array(T.allCases).firstIndex(of: selection) ?? 0))
                    }
                    .onChange(of: geometry.size.width) {
                        width = geometry.size.width / CGFloat(T.allCases.count)
                        x = width * CGFloat((Array(T.allCases).firstIndex(of: selection) ?? 0))
                    }
            }
        )
        .frame(maxWidth: .infinity)
        .overlay(alignment: .leading) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(tinted ? .appPrimary : .appSecondary)
                    .stroke(tinted ? .appPrimary.mix(with: .white, by: 0.4) : Color.appSecondary.mix(with: .white, by: 0.1), lineWidth: 0.8)
                    .frame(width: width)
                    .offset(x: x)
                    .gesture(drag)
                    .scaleEffect(scale)
                
                HStack {
                    ForEach(Array(T.allCases), id: \.self) { item in
                        label(item.title, icon: item.icon,
                              color: tinted ? .appBackground : .textPrimary)
                    }
                }
                .allowsHitTesting(false)
                .mask(alignment: .leading) {
                    Rectangle()
                        .frame(width: width)
                        .offset(x: x)
                        .scaleEffect(scale)
                }
            }
        }
    }
    
    private func setMode(_ target: T) {
        let index = Array(T.allCases).firstIndex(of: target) ?? 0
        withAnimation(animation) {
            selection = target
            x = CGFloat(index) * width
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @ViewBuilder
    private func label(_ text: LocalizedStringResource?,
                       icon iconName: String? = nil,
                       color: Color = .textSecondary) -> some View {
        VStack(spacing: 8) {
            if let iconName {
                Image(systemName: iconName)
                    .font(.system(size: 24))
            }
            if let text {
                Text(text)
//                    .lineLimit(1)
            }
        }
        .font(.system(size: 16, weight: .semibold))
        .padding(12)
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 4)
    }
}

enum SomeCases: TabItem {
    case first, second, third, fourth
    
    var title: LocalizedStringResource? {
        switch self {
        case .first:
            "First"
        case .second:
            "Second"
        case .third:
            "Thirddddd"
        case .fourth:
            "4"
        }
//        return nil
    }
    
    var icon: String? { return "clock.fill" }
}

#Preview {
    @Previewable @State var someOtherMode: SomeCases = .third
    
    VStack {
        TabPicker(
            selection: $someOtherMode,
            tinted: true
        )
        .card(padding: 6)
        Text("\(someOtherMode.title ?? "")")
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appBackground)
}
