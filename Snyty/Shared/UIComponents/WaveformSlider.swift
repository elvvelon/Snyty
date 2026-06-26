import SwiftUI

struct WaveformSlider: View {
    let amplitudes: [Float]
    @Binding var progress: Double
    @State private var internalProgress: Double = 0
    @State private var isSliding = false
    var didUpdateProgress: () -> Void = {}
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            ZStack(alignment: .leading) {
                waveform
                    .foregroundColor(.appPrimary.opacity(0.1))
                
                waveform
                    .foregroundColor(.appPrimary)
                    .mask(
                        Rectangle()
                            .size(width: width * CGFloat(internalProgress), height: geometry.size.height)
                    )
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isSliding = true
                        updateProgress(with: value.location.x, in: width)
                    }
                    .onEnded { _ in
                        isSliding = false
                        progress = internalProgress
                        didUpdateProgress()
                    }
            )
        }
        .onAppear {
            internalProgress = progress
        }
        .onChange(of: progress) {
            if !isSliding {
                internalProgress = progress
            }
        }
    }
    
    private var waveform: some View {
        HStack(spacing: 3) {
            ForEach(0..<amplitudes.count, id: \.self) { index in
                let amplitude = amplitudes[index]
                
                Capsule()
                    .frame(height: CGFloat(amplitude) * 25 + 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
    }
    
    private func updateProgress(with locationX: CGFloat, in totalWidth: CGFloat) {
        let calculatedProgress = Double(locationX / totalWidth)
        internalProgress = max(0.0, min(calculatedProgress, 1.0))
    }
}

#Preview {
    @Previewable @State var progress: Double = 0.0
    
    VStack {
        let amplitudes: [Float] = {
            var amplitudes: [Float] = []
            for _ in 1...30 {
                amplitudes.append(Float.random(in: 0.2...0.8))
            }
            return amplitudes
        }()
        WaveformSlider(amplitudes: amplitudes, progress: $progress) {}
        Text("\(progress)")
    }
    .frame(maxHeight: 80)
    .card()
    .padding()
}
