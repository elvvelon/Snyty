import Foundation
import SwiftUI

struct SnytyLogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        var strokePath2 = Path()
        var strokePath4 = Path()
        strokePath4.move(to: CGPoint(x: 0.19851*width, y: 0.09228*height))
        strokePath4.addCurve(to: CGPoint(x: 0.1373*width, y: 0.03832*height), control1: CGPoint(x: 0.19851*width, y: 0.09228*height), control2: CGPoint(x: 0.16383*width, y: 0.04263*height))
        strokePath4.addCurve(to: CGPoint(x: 0.05861*width, y: 0.1576*height), control1: CGPoint(x: 0.10233*width, y: 0.03264*height), control2: CGPoint(x: 0.0661*width, y: 0.06672*height))
        strokePath4.addCurve(to: CGPoint(x: 0.09119*width, y: 0.29833*height), control1: CGPoint(x: 0.05584*width, y: 0.19117*height), control2: CGPoint(x: 0.0616*width, y: 0.2546*height))
        strokePath4.addCurve(to: CGPoint(x: 0.16765*width, y: 0.44877*height), control1: CGPoint(x: 0.11617*width, y: 0.33524*height), control2: CGPoint(x: 0.16031*width, y: 0.38763*height))
        strokePath4.addCurve(to: CGPoint(x: 0.09119*width, y: 0.64118*height), control1: CGPoint(x: 0.17889*width, y: 0.54248*height), control2: CGPoint(x: 0.1524*width, y: 0.6355*height))
        strokePath4.addCurve(to: CGPoint(x: 0.01489*width, y: 0.56938*height), control1: CGPoint(x: 0.04474*width, y: 0.64549*height), control2: CGPoint(x: 0.01489*width, y: 0.56938*height))
        path.addPath(strokePath4)
        strokePath2.move(to: CGPoint(x: 0.20037*width, y: 0.38404*height))
        strokePath2.addCurve(to: CGPoint(x: 0.23263*width, y: 0.32118*height), control1: CGPoint(x: 0.20037*width, y: 0.38404*height), control2: CGPoint(x: 0.21495*width, y: 0.33716*height))
        strokePath2.addCurve(to: CGPoint(x: 0.21898*width, y: 0.64975*height), control1: CGPoint(x: 0.28768*width, y: 0.27144*height), control2: CGPoint(x: 0.21898*width, y: 0.64975*height))
        strokePath2.addCurve(to: CGPoint(x: 0.30955*width, y: 0.3269*height), control1: CGPoint(x: 0.21898*width, y: 0.64975*height), control2: CGPoint(x: 0.24727*width, y: 0.38069*height))
        strokePath2.addCurve(to: CGPoint(x: 0.35918*width, y: 0.37833*height), control1: CGPoint(x: 0.3294*width, y: 0.30975*height), control2: CGPoint(x: 0.35546*width, y: 0.3069*height))
        strokePath2.addCurve(to: CGPoint(x: 0.34553*width, y: 0.64404*height), control1: CGPoint(x: 0.36347*width, y: 0.46059*height), control2: CGPoint(x: 0.32626*width, y: 0.61868*height))
        strokePath2.addCurve(to: CGPoint(x: 0.40385*width, y: 0.60975*height), control1: CGPoint(x: 0.3629*width, y: 0.6669*height), control2: CGPoint(x: 0.38983*width, y: 0.64404*height))
        strokePath2.addCurve(to: CGPoint(x: 0.47333*width, y: 0.32118*height), control1: CGPoint(x: 0.45487*width, y: 0.48492*height), control2: CGPoint(x: 0.47333*width, y: 0.32118*height))
        strokePath2.addCurve(to: CGPoint(x: 0.45223*width, y: 0.46975*height), control1: CGPoint(x: 0.47333*width, y: 0.32118*height), control2: CGPoint(x: 0.4634*width, y: 0.35833*height))
        strokePath2.addCurve(to: CGPoint(x: 0.46092*width, y: 0.64975*height), control1: CGPoint(x: 0.44099*width, y: 0.58198*height), control2: CGPoint(x: 0.44231*width, y: 0.63547*height))
        strokePath2.addCurve(to: CGPoint(x: 0.52916*width, y: 0.55261*height), control1: CGPoint(x: 0.49505*width, y: 0.67595*height), control2: CGPoint(x: 0.51823*width, y: 0.595*height))
        strokePath2.addCurve(to: CGPoint(x: 0.58002*width, y: 0.32118*height), control1: CGPoint(x: 0.55273*width, y: 0.46118*height), control2: CGPoint(x: 0.58002*width, y: 0.32118*height))
        strokePath2.addCurve(to: CGPoint(x: 0.51551*width, y: 0.85833*height), control1: CGPoint(x: 0.58002*width, y: 0.32118*height), control2: CGPoint(x: 0.54032*width, y: 0.68118*height))
        strokePath2.addCurve(to: CGPoint(x: 0.44355*width, y: 0.9469*height), control1: CGPoint(x: 0.50248*width, y: 0.95134*height), control2: CGPoint(x: 0.46588*width, y: 0.98404*height))
        strokePath2.addCurve(to: CGPoint(x: 0.46092*width, y: 0.78975*height), control1: CGPoint(x: 0.41749*width, y: 0.90357*height), control2: CGPoint(x: 0.4237*width, y: 0.8269*height))
        strokePath2.addCurve(to: CGPoint(x: 0.60732*width, y: 0.54118*height), control1: CGPoint(x: 0.51766*width, y: 0.73314*height), control2: CGPoint(x: 0.56103*width, y: 0.63559*height))
        strokePath2.addCurve(to: CGPoint(x: 0.75868*width, y: 0.09261*height), control1: CGPoint(x: 0.68926*width, y: 0.37408*height), control2: CGPoint(x: 0.80086*width, y: -0.13693*height))
        strokePath2.addCurve(to: CGPoint(x: 0.69913*width, y: 0.64975*height), control1: CGPoint(x: 0.74504*width, y: 0.1669*height), control2: CGPoint(x: 0.69913*width, y: 0.64975*height))
        strokePath2.addCurve(to: CGPoint(x: 0.6768*width, y: 0.5069*height), control1: CGPoint(x: 0.69913*width, y: 0.64975*height), control2: CGPoint(x: 0.7004*width, y: 0.4982*height))
        strokePath2.addCurve(to: CGPoint(x: 0.65447*width, y: 0.57833*height), control1: CGPoint(x: 0.66154*width, y: 0.51252*height), control2: CGPoint(x: 0.64265*width, y: 0.5554*height))
        strokePath2.addCurve(to: CGPoint(x: 0.76861*width, y: 0.57833*height), control1: CGPoint(x: 0.67804*width, y: 0.62404*height), control2: CGPoint(x: 0.72628*width, y: 0.61449*height))
        strokePath2.addCurve(to: CGPoint(x: 0.86414*width, y: 0.31832*height), control1: CGPoint(x: 0.83885*width, y: 0.51833*height), control2: CGPoint(x: 0.86414*width, y: 0.31832*height))
        strokePath2.addCurve(to: CGPoint(x: 0.83933*width, y: 0.4869*height), control1: CGPoint(x: 0.86414*width, y: 0.31832*height), control2: CGPoint(x: 0.84926*width, y: 0.3823*height))
        strokePath2.addCurve(to: CGPoint(x: 0.86042*width, y: 0.64118*height), control1: CGPoint(x: 0.83472*width, y: 0.53547*height), control2: CGPoint(x: 0.82196*width, y: 0.61833*height))
        strokePath2.addCurve(to: CGPoint(x: 0.93114*width, y: 0.54404*height), control1: CGPoint(x: 0.88829*width, y: 0.65774*height), control2: CGPoint(x: 0.90932*width, y: 0.62717*height))
        strokePath2.addCurve(to: CGPoint(x: 0.97333*width, y: 0.31832*height), control1: CGPoint(x: 0.9634*width, y: 0.42118*height), control2: CGPoint(x: 0.97333*width, y: 0.31832*height))
        strokePath2.addCurve(to: CGPoint(x: 0.91129*width, y: 0.84975*height), control1: CGPoint(x: 0.97333*width, y: 0.31832*height), control2: CGPoint(x: 0.93734*width, y: 0.64393*height))
        strokePath2.addCurve(to: CGPoint(x: 0.85174*width, y: 0.9469*height), control1: CGPoint(x: 0.90064*width, y: 0.9339*height), control2: CGPoint(x: 0.86929*width, y: 0.95522*height))
        strokePath2.addCurve(to: CGPoint(x: 0.84305*width, y: 0.7869*height), control1: CGPoint(x: 0.80955*width, y: 0.9269*height), control2: CGPoint(x: 0.80831*width, y: 0.8269*height))
        strokePath2.addCurve(to: CGPoint(x: 0.98325*width, y: 0.61833*height), control1: CGPoint(x: 0.90237*width, y: 0.7186*height), control2: CGPoint(x: 0.925*width, y: 0.73833*height))
        path.addPath(strokePath2)
        return path
    }
}

struct SnytyIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        var strokePath2 = Path()
        strokePath2.move(to: CGPoint(x: 0.34206*width, y: 0.67354*height))
        strokePath2.addCurve(to: CGPoint(x: 0.25624*width, y: 0.59411*height), control1: CGPoint(x: 0.31168*width, y: 0.65474*height), control2: CGPoint(x: 0.28262*width, y: 0.62838*height))
        strokePath2.addCurve(to: CGPoint(x: 0.23722*width, y: 0.17501*height), control1: CGPoint(x: 0.16662*width, y: 0.47767*height), control2: CGPoint(x: 0.16462*width, y: 0.29535*height))
        strokePath2.addCurve(to: CGPoint(x: 0.4038*width, y: 0.0346*height), control1: CGPoint(x: 0.31795*width, y: 0.04117*height), control2: CGPoint(x: 0.4038*width, y: 0.0346*height))
        strokePath2.addCurve(to: CGPoint(x: 0.41901*width, y: 0.41121*height), control1: CGPoint(x: 0.4038*width, y: 0.0346*height), control2: CGPoint(x: 0.288*width, y: 0.24099*height))
        strokePath2.addCurve(to: CGPoint(x: 0.71476*width, y: 0.43865*height), control1: CGPoint(x: 0.53073*width, y: 0.55638*height), control2: CGPoint(x: 0.71476*width, y: 0.43865*height))
        strokePath2.addCurve(to: CGPoint(x: 0.67212*width, y: 0.57422*height), control1: CGPoint(x: 0.71476*width, y: 0.43865*height), control2: CGPoint(x: 0.71162*width, y: 0.50478*height))
        path.addPath(strokePath2)
        
        var strokePath8 = Path()
        strokePath8.move(to: CGPoint(x: 0.02831*width, y: 0.60777*height))
        strokePath8.addCurve(to: CGPoint(x: 0.31646*width, y: 0.67699*height), control1: CGPoint(x: 0.02831*width, y: 0.60777*height), control2: CGPoint(x: 0.15988*width, y: 0.67699*height))
        strokePath8.addCurve(to: CGPoint(x: 0.73882*width, y: 0.57214*height), control1: CGPoint(x: 0.47303*width, y: 0.67699*height), control2: CGPoint(x: 0.57303*width, y: 0.57214*height))
        strokePath8.addCurve(to: CGPoint(x: 0.97171*width, y: 0.6322*height), control1: CGPoint(x: 0.9046*width, y: 0.57214*height), control2: CGPoint(x: 0.97171*width, y: 0.6322*height))
        path.addPath(strokePath8)
        var strokePath4 = Path()
        strokePath4.move(to: CGPoint(x: 0.02831*width, y: 0.81162*height))
        strokePath4.addCurve(to: CGPoint(x: 0.30854*width, y: 0.67699*height), control1: CGPoint(x: 0.02831*width, y: 0.81162*height), control2: CGPoint(x: 0.14914*width, y: 0.67699*height))
        strokePath4.addCurve(to: CGPoint(x: 0.7079*width, y: 0.81162*height), control1: CGPoint(x: 0.46795*width, y: 0.67699*height), control2: CGPoint(x: 0.53459*width, y: 0.77537*height))
        strokePath4.addCurve(to: CGPoint(x: 0.96145*width, y: 0.77507*height), control1: CGPoint(x: 0.88121*width, y: 0.84786*height), control2: CGPoint(x: 0.96145*width, y: 0.77507*height))
        path.addPath(strokePath4)
        var strokePath6 = Path()
        strokePath6.move(to: CGPoint(x: 0.02831*width, y: 0.95531*height))
        strokePath6.addCurve(to: CGPoint(x: 0.30854*width, y: 0.82174*height), control1: CGPoint(x: 0.02831*width, y: 0.95531*height), control2: CGPoint(x: 0.14914*width, y: 0.82175*height))
        strokePath6.addCurve(to: CGPoint(x: 0.7079*width, y: 0.95531*height), control1: CGPoint(x: 0.46795*width, y: 0.82174*height), control2: CGPoint(x: 0.53459*width, y: 0.91935*height))
        strokePath6.addCurve(to: CGPoint(x: 0.96145*width, y: 0.91905*height), control1: CGPoint(x: 0.88121*width, y: 0.99127*height), control2: CGPoint(x: 0.96145*width, y: 0.91905*height))
        path.addPath(strokePath6)
        return path
    }
}

struct SnytyLogoView: View {
    @State private var drawingProgress: CGFloat = 0.0
    var lineWidth: CGFloat = 4
    
    var body: some View {
        SnytyLogoShape()
            .trim(from: 0.0, to: drawingProgress)
            .stroke(
                Color.textPrimary,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round,
                )
            )
            .aspectRatio(2.5, contentMode: .fit)
        .onAppear {
            animateLogo()
        }
    }
    
    func animateLogo() {
        drawingProgress = 0.0
        withAnimation(.easeInOut(duration: 1.5)) {
            drawingProgress = 1.0
        }
    }
}

struct SnytyIconView: View {
    @State private var drawingProgress: CGFloat = 0.0
    
    var body: some View {
        SnytyIconShape()
            .trim(from: 0.0, to: drawingProgress)
            .stroke(
                Color.textPrimary,
                style: StrokeStyle(
                    lineWidth: 8,
                    lineCap: .round,
                    lineJoin: .round,
                )
            )
            .aspectRatio(1.232, contentMode: .fit)
        .onAppear {
            animateLogo()
        }
    }
    
    func animateLogo() {
        drawingProgress = 0.0
        withAnimation(.easeInOut(duration: 1.5)) {
            drawingProgress = 1.0
        }
    }
}

#Preview {
    @Previewable @State var animationID = UUID()
    
    VStack(spacing: 30) {
        SnytyLogoView()
            .frame(width: 100)
            .id(animationID)
        
        SnytyIconView()
            .frame(width: 200)
            .id(animationID)
        
        Button("Animate again") {
            animationID = UUID()
        }
    }
}
