import SwiftUI

struct TrackerHint: Identifiable {
    let id = UUID()
    let iconName: String
    let tint: Color
    let hint: LocalizedStringKey
}

extension TrackerHint {
    static let aboutSnytysia: [TrackerHint] = [
        TrackerHint(
            iconName: "sparkles",
            tint: .appYellow,
            hint: "**Пізнайте свій сон:** Ця функція перетворює телефон на вашого нічного асистента, щоб ви нарешті дізналися, як проходить ваш відпочинок."
        ),
        TrackerHint(
            iconName: "waveform.path.ecg",
            tint: .appPrimary,
            hint: "**Що ми аналізуємо:** Наш штучний інтелект розпізнає хропіння, розмови уві сні, кашель та шум, створюючи детальну статистику вашої ночі."
        ),
        TrackerHint(
            iconName: "waveform.and.mic",
            tint: .accent,
            hint: "**Що ми записуємо:** Ми не слухаємо тишу. Зберігаються лише найцікавіші моменти (наприклад, ваші нічні монологи!), які можна прослухати вранці."
        ),
        TrackerHint(
            iconName: "shield.lefthalf.filled",
            tint: .appGreen,
            hint: "**Повна приватність:** Уся магія нейромереж працює виключно на вашому пристрої. Ваші дані нікуди не відправляються."
        )
    ]
    
    static let preparingHints: [TrackerHint] = [
        TrackerHint(
            iconName: "battery.100percent.bolt",
            tint: .appGreen,
            hint: "**Підключіть зарядку:** Аналіз звуків в реальному часі потребує енергії, тому радимо залишити телефон підключеним до мережі."
        ),
        TrackerHint(
            iconName: "thermometer.medium",
            tint: .appRed,
            hint: "**Уникайте перегріву:** Не кладіть пристрій у ліжко чи під ковдру. Тумбочка поруч — найбезпечніше та найзручніше місце."
        ),
        TrackerHint(
            iconName: "mic.fill",
            tint: .appPrimary,
            hint: "**Направте мікрофон:** Для кращого розпізнавання покладіть телефон так, щоб його нижня частина була спрямована у ваш бік."
        ),
        TrackerHint(
            iconName: "moon.zzz.fill",
            tint: .accent,
            hint: "**Просто засинайте:** Запис почнеться автоматично, щойно завершиться таймер. Солодких снів!"
        )
    ]
    
    static let appHints: [TrackerHint] = [
        TrackerHint(
            iconName: "moon.stars.fill",
            tint: .accent,
            hint: "**Магія вже працює:** Ви можете сміливо заблокувати екран або згорнути застосунок — ми продовжуємо роботу у фоновому режимі."
        ),
        TrackerHint(
            iconName: "alarm.fill",
            tint: .appYellow,
            hint: "**Сплануйте пробудження:** Поки ми працюємо, скористайтеся нашим калькулятором сну, щоб розрахувати ідеальний час для легкого підйому."
        ),
        TrackerHint(
            iconName: "sun.max.fill",
            tint: .appPrimary,
            hint: "**До зустрічі вранці:** Ми підготуємо вашу детальну нічну статистику та цікаві деталі про ваш сон."
        )
    ]
}
