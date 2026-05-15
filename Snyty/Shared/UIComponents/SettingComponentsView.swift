import SwiftUI

struct SettingsStack<Content: View> : View {
    private let title: LocalizedStringResource?
    private let note: LocalizedStringResource?
    private let style: SettingsSectionStyle
    @ViewBuilder private let content: Content
    
    init(_ style: SettingsSectionStyle,
        _ title: LocalizedStringResource? = nil,
        _ note: LocalizedStringResource? = nil,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.note = note
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title { Text(title).subtitle3() }
            
            switch style {
            case .cards: content
                
            case .row:
                VStack(spacing: 0) { content }.card(padding: 0)
            }
            
            if let note {
                Text(note).caption2().padding(.horizontal, 20)
            }
        }
    }
}

struct SettingCard: View {
    let title: LocalizedStringResource
    var subtitle: LocalizedStringResource? = nil
    let iconName: String
    let color: Color
    var style: ValueChangeStyle
    var representedValue: LocalizedStringResource? = nil
    var note: LocalizedStringResource?
    
    var body: some View {
        if case .navigation(let valueChaneStyle) = style {
            NavigationLink {
                SettingsNavigation(title: title, note: note, style: valueChaneStyle)
            } label: { showContent() }
            
        } else if case .list = style {
            NavigationLink {
                SettingsNavigation(title: title, note: note, style: style)
            } label: { showContent() }
            
        } else { showContent() }
    }
    
    @ViewBuilder
    private func showContent() -> some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.2))
                .clipShape(.rect(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title).title3()
                if let description = subtitle { Text(description).caption2() }
            }
            Spacer()
            SettingValueChanger(style: style, representedValue: representedValue)
        }
        .card(padding: 16)
    }
}

struct SettingRow: View {
    let title: LocalizedStringResource
    var iconName: String? = nil
    var style: ValueChangeStyle
    var representedValue: LocalizedStringResource? = nil
    var onDisappear: () -> Void = {}
    
    @State private var showPicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            switch style {
            case .toggle, .textField:
                showContent()
                
            case .timePicker(let timePickerStyle):
                showContent()
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.3)) { showPicker.toggle() }
                    }
                
                if showPicker { TimePicker(timePickerStyle, .dark) }
                
            case .list:
                NavigationLink {
                    SettingsNavigation(title: title, style: style)
                        .onDisappear { onDisappear() }
                } label: { showContent() }
                
            case .navigation(let valueChangeStyle):
                NavigationLink {
                    SettingsNavigation(title: title, style: valueChangeStyle)
                } label: { showContent() }
            }
        }
        .padding()
        .background(.appContext)
        .border(.appSecondary, width: 0.6)
    }
    
    @ViewBuilder
    private func showContent() -> some View {
        HStack(spacing: 16) {
            if let iconName {
                Image(systemName: iconName)
                    .foregroundStyle(.textSecondary)
                    .font(.system(size: 20))
                    .frame(width: 26, height: 26)
                    .clipped()
            }
            
            Text(title).title3()
            Spacer()
            SettingValueChanger(style: style, representedValue: representedValue)
        }
    }
}

struct SettingValueChanger: View {
    var style: ValueChangeStyle
    var representedValue: LocalizedStringResource?
    
    private var iconName: String? {
        switch style {
        case .toggle, .textField: nil
        case .timePicker:         "chevron.up.chevron.down"
        case .list, .navigation:  "chevron.right"
        }
    }
    
    var body: some View {
        if case .toggle(let binding) = style {
            TogglePicker(isOn: binding)
            
        } else if case .textField(let binding) = style {
            TextField("", text: binding, prompt: Text(representedValue ?? "").foregroundStyle(.textSecondary))
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.trailing)
        } else {
            HStack(spacing: 4) {
                if let representedValue  {
                    Text(representedValue)
                        .font(.system(size: 16))
                }
                
                if let iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 14))
                        .offset(y: 1)
                }
            }
            .foregroundStyle(.textSecondary)
        }
    }
}
