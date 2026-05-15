import SwiftUI

struct NapView: View {
    let nap: NapType
    @State private var isAnimating = false
    @State private var vm = NapViewModel()
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle().stroke(.appSecondary.opacity(0.4), lineWidth: isAnimating ? 1.6 : 2)
                    .frame(width: 230)
                    .scaleEffect(isAnimating ? 1.06 : 0.94)
                
                Circle().stroke(.appSecondary.opacity(0.3), lineWidth: isAnimating ? 1.2 : 1.6)
                    .frame(width: 250)
                    .scaleEffect(isAnimating ? 1.04 : 0.96)
                
                VStack(spacing: 12) {
                    Image(systemName: nap.imageName)
                        .foregroundStyle(.appPrimary)
                        .font(.system(size: 60, weight: .bold))
                        .frame(width: 70, height: 70, alignment: .center)
                        .clipped()
                    
                    Text(nap.subtitle)
                        .foregroundStyle(.textPrimary)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                }
                .frame(width: 210, height: 210)
                .background(.appSecondary)
                .clipShape(.circle)
                .shadow(color: .appSecondary, radius: isAnimating ? 34 : 26)
                .scaleEffect(isAnimating ? 1.08 : 0.95)
            }
            .padding()
            .animation(.smooth(duration: 3.5).repeatForever(), value: isAnimating)
            
            Text("Бадьорих снів")
                .title1()
            
            Text("Ми врахували \(Text("\(AppPresetsManager.shared.fallAsleepDuration) хвилин")) на засинання.\nВаш будильник пролунає о \(Text(vm.formattedTime).fontWeight(.bold).foregroundStyle(.textPrimary))")
                .multilineTextAlignment(.center)
                .foregroundStyle(.textSecondary)
                .padding(40)
            
            Button {
                vm.cancelNap()
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("Відмінити")
                }
                .foregroundStyle(.textSecondary)
                .padding(8)
            }
            .tint(.appSecondary)
            .buttonStyle(.glassProminent)
            .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.appBackground)
        .onAppear {
            isAnimating = true
        }
        .task {
            await vm.scheduleNap(nap, fallAsleepDuration: AppPresetsManager.shared.fallAsleepDuration, cycleDuration: AppPresetsManager.shared.cycleDuration)
        }
        .toolbar {
            ToolbarItem(placement: .title) {
                Text("Швидкий сон")
                    .subtitle1()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NavigationLink {
            NapView(nap: .oneCycle)
        } label: {
            Text("Показати")
        }
    }
}
