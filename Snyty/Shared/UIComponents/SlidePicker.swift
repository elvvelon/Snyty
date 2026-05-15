import SwiftUI

struct SlidePicker<V>: View where V: BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
    @Binding var value: V
    var bounds: ClosedRange<V> = 0...1
    var tint: Color = .appPrimary
    
    @State private var isInteracting = false
    @State private var width: CGFloat = 0
    
    private var location: CGFloat {
        let range = CGFloat(bounds.upperBound - bounds.lowerBound)
        guard range > 0 else { return 0 }
        let progress = CGFloat(value - bounds.lowerBound) / range
        return progress * width
    }
    
    private var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { val in
                self.isInteracting = true
                updateValue(with: val.location.x)
            }
            .onEnded { _ in
                isInteracting = false
            }
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.appSecondary)
                .frame(height: 6)
            Capsule()
                .fill(tint)
                .frame(width: location, height: 6)
                .glassEffect()
            Circle()
                .fill(.textPrimary)
                .glassEffect(.clear.interactive())
                .opacity(isInteracting ? 0.4 : 1)
                .frame(height: 20)
                .offset(x: location - 8)
                .gesture(drag)
        }
        .background {
            GeometryReader { geo in
                Color.clear
                    .onAppear { width = geo.size.width }
                    .onChange(of: geo.size.width) { _, new in width = new }
            }
        }
    }
    
    private func updateValue(with xLocation: CGFloat) {
        let clampedX = min(max(0, xLocation), width)
        let progress = clampedX / width
        let range = bounds.upperBound - bounds.lowerBound
        let newValue = bounds.lowerBound + V(progress) * range
        
        value = newValue
    }
}

#Preview {
    @Previewable @State var selection: Double = 0
    VStack {
        SlidePicker(value: $selection, bounds: -5...10)
            .padding(50)
        Text("\(selection)")
    }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
}
