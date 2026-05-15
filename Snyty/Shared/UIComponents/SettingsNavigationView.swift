import SwiftUI

struct SettingsNavigation: View {
    let title: LocalizedStringResource
    var note: LocalizedStringResource? = nil
    var style: ValueChangeStyle
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if case .list(let listConfig, let action) = style {
                    ListView(title: listConfig.title ?? title, options: listConfig.options, selection: listConfig.selection, action: action)
                        .card(padding: 0, background: {})
                }
                
                if case .timePicker(let timePickerStyle) = style {
                    TimePicker(timePickerStyle)
                        .frame(maxWidth: .infinity)
                }
                
                if let note {
                    Text(note)
                        .description2()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(.appBackground)
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(title)
                    .subtitle1()
            }
        }
    }
}

struct ListView: View {
    let title: LocalizedStringResource
    let options: [any AppSetting]
    @Binding var selection: any AppSetting
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.hashValue) { option in
                Button {
                    selection = option
                    action()
                } label: {
                    HStack(spacing: 16) {
                        if option.hashValue == selection.hashValue {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.textSecondary)
                                .font(.system(size: 20))
                                .frame(width: 18, height: 20)
                                .clipped()
                            
                        } else {
                            Spacer()
                                .frame(width: 18, height: 20)
                        }
                        
                        Text(option.displayName)
                            .title3()
                        
                        Spacer()
                    }
                }
                .padding()
            }
            .background(.appContext)
            .border(.appSecondary, width: 0.7)
        }
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(title)
                    .subtitle1()
            }
        }
    }
}

#Preview {
    @Previewable @State var sound: AlarmSound = .ascent
    
    NavigationStack {
        SettingsNavigation(
            title: "Alarm sound",
            note: "Some note here.",
            style: .list(
                ListConfig(
                    title: "List config title",
                    options: AlarmSound.allCases,
                    selection: Binding(
                        get: { sound },
                        set: { sound = $0 as! AlarmSound}
                    )
                ), {}
            )
        )
    }
    .navigationBarTitleDisplayMode(.inline)
}
