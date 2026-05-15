import SwiftUI

enum CardStyle {
    case light, standard, dark
    
    var backgroundColor: Color {
        switch self {
        case .light: .appSecondary
        case .standard: .appContext
        case .dark: .appBackground.opacity(0.6)
        }
    }
    
    var strokeColor: Color {
        switch self {
        case .light: .appSecondary.mix(with: .white, by: 0.1)
        case .standard: .appSecondary
        case .dark: .appBackground
        }
    }
}

extension View {
    // MARK: - Titles
    
    /// Primary 24, bold, multilineAlignment: center
    func title1() -> some View {
        self.foregroundStyle(.textPrimary)
            .font(.system(size: 24, weight: .bold))
            .multilineTextAlignment(.center)
    }
    
    /// Primary 20, semibold, multilineAlignment: center
    func title2() -> some View {
        self.foregroundStyle(.textPrimary)
            .font(.system(size: 20, weight: .semibold))
            .multilineTextAlignment(.center)
    }
    
    /// Primary 16, semibold, multilineAlignment: leading
    func title3() -> some View {
        self.foregroundStyle(.textPrimary)
            .font(.system(size: 16, weight: .semibold))
            .multilineTextAlignment(.leading)
    }
    
    // MARK: - Subtitles
    
    /// Primary 18, bold, uppercase, multilineAlignment: center
    func subtitle1() -> some View {
        self.textCase(.uppercase)
            .foregroundStyle(.textPrimary)
            .font(.system(size: 18, weight: .bold))
            .multilineTextAlignment(.center)
    }
    
    /// Primary 18, semibold
    func subtitle2() -> some View {
        self.foregroundStyle(.textPrimary)
            .font(.system(size: 18, weight: .semibold))
    }
    
    /// Secondary 16, bold, uppercase, padding: horizontal, width: infinity
    func subtitle3() -> some View {
        self.textCase(.uppercase)
            .foregroundStyle(.textSecondary)
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    // MARK: - Descriptions
    
    /// Secondary, multilineAlignment: center
    func description1() -> some View {
        self.foregroundStyle(.textSecondary)
            .multilineTextAlignment(.center)
    }
    
    /// Secondary 16, padding: horizontal
    func description2() -> some View {
        self.foregroundStyle(.textSecondary)
            .font(.system(size: 16))
            .padding(.horizontal)
    }
    
    /// Secondary 16
    func description3() -> some View {
        self.foregroundStyle(.textSecondary)
            .font(.system(size: 16))
    }
    
    // MARK: - Captions
    
    /// Secondary 18, multilineAlignment: center
    func caption1() -> some View {
        self.font(.system(size: 18))
            .foregroundStyle(.textSecondary)
            .multilineTextAlignment(.center)
    }
    
    /// Secondary 14
    func caption2() -> some View {
        self.foregroundStyle(.textSecondary)
            .font(.system(size: 14))
    }
    
    ///  Primary 30, heavy, rounded
    func timeStyle(fontSize: CGFloat = 30) -> some View {
        self.font(.system(size: fontSize, weight: .heavy, design: .rounded))
            .foregroundStyle(.textPrimary)
    }
    
    /// Small image in in circle
    func icon(color: Color = .appPrimary) -> some View {
        self.foregroundStyle(color)
            .font(.system(size: 18, weight: .semibold))
            .padding(8)
            .background(color.opacity(0.2))
            .clipShape(.circle)
    }
    
    // MARK: - Cards
    
    func card<V, S>(padding: CGFloat = 20, radius: CGFloat = 24, lineWidth: CGFloat = 0.8,
                      @ViewBuilder background: () -> V = { Color.appContext },
                      stroke: () -> S = { Color.appSecondary }
    ) -> some View where V: View, S: ShapeStyle {
        self.padding(padding)
            .background {
                background()
            }
            .clipShape(.rect(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(stroke(), lineWidth: lineWidth)
            }
            .shadow(radius: 8, y: 4)
    }
    
    func card<S>(padding: CGFloat = 20, radius: CGFloat = 24, lineWidth: CGFloat = 0.8,
                    background: S = .appContext,
                      stroke: S = .appSecondary
    ) -> some View where S: ShapeStyle {
        self.padding(padding)
            .background(background)
            .clipShape(.rect(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(stroke, lineWidth: lineWidth)
            }
            .shadow(radius: 8, y: 4)
    }
    
    func card(padding: CGFloat = 20, radius: CGFloat = 24, lineWidth: CGFloat = 0.8, cardStyle: CardStyle = .standard) -> some View {
        self.padding(padding)
            .background(cardStyle.backgroundColor)
            .clipShape(.rect(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(cardStyle.strokeColor, lineWidth: lineWidth)
            }
            .shadow(radius: 8, y: 4)
    }
    
    /// Background 18, bold
    func buttonLabel(padding: CGFloat = 20) -> some View {
        self.font(.system(size: 18, weight: .bold))
            .foregroundStyle(.appBackground)
            .padding(padding)
    }
}
