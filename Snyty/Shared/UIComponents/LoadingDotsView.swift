import SwiftUI

struct LoadingDotsView: View {
    @State private var wave = false
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 3)
                    .scaleEffect(wave ? 1.2 : 0.8)
                    .opacity(wave ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: wave
                    )
            }
        }
        .onAppear {
            wave = true
        }
    }
}

#Preview {
    LoadingDotsView()
}
