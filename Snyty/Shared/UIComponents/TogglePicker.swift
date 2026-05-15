import SwiftUI

struct TogglePicker: View {
    @Binding var isOn: Bool
    @State private var x: CGFloat = 0
    @State private var represatableOn = false
    @State private var isInteracting = false
    
    private var tintColor: Color {
        return represatableOn ? .appPrimary : .appSecondary }
    
    private var secondaryColor: Color {
        return represatableOn ? .appSecondary : .textSecondary }
    
    private var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { val in
                self.isInteracting = true
                let loc = min(max(val.location.x - 15, 0), 30)
                self.x = loc
                represatableOn = loc > 15
            }
            .onEnded { val in
                isInteracting = false
                toggle(to: val.location.x > 15)
            }
    }
    
    var body: some View {
        Circle()
            .fill(secondaryColor)
            .padding(isInteracting ? 2 : 4)
            .offset(x: x)
            .frame(width: 60, height: 30, alignment: .leading)
            .background(tintColor)
            .clipShape(.rect(cornerRadius: 30))
            .glassEffect(.regular.interactive())
            .animation(.bouncy, value: isInteracting)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: represatableOn)
            .onTapGesture {
                toggle()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            .gesture(drag)
            .onAppear {
                toggle(to: isOn)
            }
            .onChange(of: represatableOn) {
                if isInteracting {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .onChange(of: isOn) {
                toggle(to: isOn)
            }
    }
    
    func toggle(to: Bool? = nil) {
        if to == nil {
            isOn.toggle()
        }
        let state = to ?? isOn
        
        x = state == true ? 30 : 0
        isOn = state
        represatableOn = state
    }
}

#Preview {
    @Previewable @State var ison = true
    TogglePicker(isOn: $ison)
    Toggle("", isOn: $ison).labelsHidden().tint(.appPrimary)
    Text(ison ? "on" : "off")
}
