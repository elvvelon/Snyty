import SwiftUI

enum OnbordingPage: Int, CaseIterable {
    case welcome, about, chronotype, permissions, completed
    
    mutating func next() {
        let allCases = OnbordingPage.allCases
        let nextIndex = self.rawValue + 1
        if allCases.count > nextIndex {
            self = allCases[nextIndex]
        }
    }
    mutating func previous() {
        let allCases = OnbordingPage.allCases
        let previousIndex = self.rawValue - 1
        if 0 <= previousIndex {
            self = allCases[previousIndex]
        }
    }
}

struct OnboardingView: View {
    @State private var currentPage: OnbordingPage = .welcome
    @State private var isForwardDirection = true
    
    var body: some View {
        VStack {
            ZStack(alignment: .leadingLastTextBaseline) {
                HStack(spacing: 10) {
                    ForEach(OnbordingPage.allCases, id: \.rawValue) { page in
                        Capsule()
                            .fill(currentPage.rawValue == page.rawValue ? .appPrimary : .appSecondary)
                            .frame(maxWidth: currentPage.rawValue == page.rawValue ? 26 : 6)
                            .onTapGesture {
                                isForwardDirection = currentPage.rawValue < page.rawValue
                                withAnimation(.snappy) { currentPage = OnbordingPage(rawValue: page.rawValue) ?? currentPage }
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 6)
                Button {
                    isForwardDirection = false
                    withAnimation(.snappy) { currentPage.previous() }
                } label: {
                    Image(systemName: "chevron.backward")
                    Text("Назад")
                        .frame(alignment: .leading)
                }
                .padding(.leading)
                .caption1()
            }
            .opacity(currentPage == .welcome ? 0 : 1)
            
            Group {
                switch currentPage {
                case .welcome: welcome
                case .about: about
                case .chronotype: ChronotypeView()
                case .permissions: PermissionView()
                case .completed: completed
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.asymmetric(
                insertion: .move(edge: isForwardDirection ? .trailing : .leading),
                removal: .move(edge: isForwardDirection ? .leading : .trailing)))
            
            Button {
                isForwardDirection = true
                withAnimation(.snappy) {
                    if currentPage == .completed {
                        AppPresetsManager.shared.isOnboarded = true
                    }
                    currentPage.next()
                }
            } label: {
                HStack {
                    if currentPage == .completed {
                        Text("Розпочати")
                    } else {
                        Text("Далі")
                        Image(systemName: "chevron.forward")
                    }
                }
                .buttonLabel()
                .frame(maxWidth: .infinity)
            }
            .tint(.appPrimary)
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.roundedRectangle(radius: 20))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
    }
    
    var welcome: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon")
                .font(.system(size: 70, weight: .semibold))
                .padding(30)
                .background(.appPrimary)
                .clipShape(.circle)
                .overlay {
                    Circle().stroke(.appPrimary.mix(with: .white, by: 0.4))
                }
                .padding(.bottom, 30)
            
            SnytyLogoView(lineWidth: 5).frame(width: 140)
            Text("Ваш провідник у світ глибоких снів та бадорих ранків").caption1()
        }
    }
    
    var about: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 80, weight: .semibold))
                .foregroundStyle(.appPrimary)
                .padding(.bottom, 30)
            
            Text("Ідеальний сон").title1()
            
            Text("Головний секрет бадьорості — прокинутися в правильний момент. Snyty розраховує ідеальний графік відпочинку саме для вас. Він підкаже, о котрій лягти спати або завести будильник, щоб оминути глибокий сон і легко розпочати новий день.")
                .caption1()
        }
    }
    
    var completed: some View {
        VStack(spacing: 16) {
            SnytyIconView()
                .frame(maxWidth: 160)
                .padding(14)
                .offset(y: 10)
                .background(.appPrimary)
                .clipShape(.circle)
                .overlay {
                    Circle().stroke(.appPrimary.mix(with: .white, by: 0.4))
                }
                .padding(.bottom, 30)
            
            Text("Все готово!").title1()
            Text("Солодких снів і найбадьоріших ранків. Snyty потурбується про ваш відпочинок").caption1()
        }
    }
}

#Preview {
    OnboardingView()
}
