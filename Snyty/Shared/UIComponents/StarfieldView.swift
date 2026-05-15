import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    let pulseSpeed: Double
}

struct StarfieldView: View {
    @State private var stars: [Star] = (0..<120).map { _ in
        Star(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 1...3),
            opacity: Double.random(in: 0.4...1.0),
            pulseSpeed: Double.random(in: 1...3)
        )
    }
    
    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    for star in stars {
                        let flicker = (sin(time * star.pulseSpeed) + 1) / 2
                        let currentOpacity = star.opacity * (0.3 + 0.7 * flicker)
                        
                        let rect = CGRect(x: star.x * size.width,
                                          y: star.y * size.height,
                                          width: star.size,
                                          height: star.size)
                        
                        context.opacity = currentOpacity
                        context.fill(Path(ellipseIn: rect), with: .color(.white))
                    }
                }
            }
        }
    }
}

#Preview {
    StarfieldView()
}
