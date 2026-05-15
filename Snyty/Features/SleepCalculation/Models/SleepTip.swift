import Foundation
import SwiftUI

struct SleepTip: Identifiable {
    let id = UUID()
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    
    let color: Color
    let icon: String
}

extension SleepTip {
    static var randomTip: SleepTip {
        return SleepTip.data[Int.random(in: 0..<SleepTip.data.count)]
    }
    
    static let data: [SleepTip] = [
        SleepTip(
            title: "Магія темряви",
            description: "Менша кількість світла сприяє виробленню мелатоніну. Вимкніть яскраві лампи за годину до сну.",
            color: .accent,
            icon: "cloud.moon"
        ),
        
        SleepTip(
            title: "Обережно з цукром",
            description: "Солодке на ніч дає різкий прилив енергії, що змушує мозок працювати активніше замість того, щоб готуватися до спокою.",
            color: .appYellow,
            icon: "sparkles"
        ),
        
        SleepTip(
            title: "Вікно сну",
            description: "Існує ідеальний проміжок між 22:00 та 23:00, коли рівень кортизолу падає, а мелатонін зростає. Спробуйте встигнути в цей «потік».",
            color: .accent,
            icon: "moonphase.waning.gibbous.inverse"
        ),
        
        SleepTip(
            title: "Фаза швидкого сну",
            description: "Саме під час REM-фази мозок обробляє емоції та інформацію. Короткий сон (Power Nap) якраз допомагає «перезавантажитися».",
            color: .appGreen,
            icon: "progress.indicator"
        ),
        
        SleepTip(
            title: "Цифровий детокс",
            description: "Синє світло екрана обманює мозок. Спробуйте відкласти гаджет за 30 хвилин до сну.",
            color: .accent,
            icon: "iphone.slash"
        ),
        
        SleepTip(
            title: "Користь білого шуму",
            description: "Монотонні звуки дощу або вентилятора маскують різкі нічні шуми, допомагаючи мозку залишатися в стані спокою.",
            color: .accent,
            icon: "waveform.mid"
        ),
        
        SleepTip(
            title: "Режим «Не турбувати»",
            description: "Налаштуйте автоматичне увімкнення режиму «Сон» на iPhone. Навіть світло від екрана сповіщення може частково вас розбудити.",
            color: .appPrimary,
            icon: "bell.slash"
        ),
        
        SleepTip(
            title: "Night Shift",
            description: "Якщо не можете відкласти телефон, увімкніть «теплий» режим екрана. Це менше пригнічує вироблення мелатоніну.",
            color: .appYellow,
            icon: "sun.min"
        ),
        
        SleepTip(
            title: "Метод «Вивантаження»",
            description: "Якщо тривожні думки не дають заснути, випишіть список справ на завтра на папір. Це дозволить мозку «відпустити» контроль.",
            color: .appYellow,
            icon: "pencil.and.list.clipboard"
        ),
        
        SleepTip(
            title: "Розслаблення м'язів",
            description: "пробуйте по черзі напружувати та розслабляти пальці ніг, ікри, стегна. Це техніка прогресивної релаксації, що прискорює сон.",
            color: .appPrimary,
            icon: "figure.cooldown"
        ),
        
        SleepTip(
            title: "Дихання 4-7-8",
            description: "Вдих на 4 рахунки, затримка на 7, видих на 8. Ця вправа миттєво заспокоює серцебиття.",
            color: .appRed,
            icon: "heart"
        ),
        
        SleepTip(
            title: "Ритуали сну",
            description: "Однакова послідовність дій щовечора (наприклад, душ — книга — ліжко) створює в мозку стійкий рефлекс засинання.",
            color: .appPrimary,
            icon: "bed.double.badge.checkmark"
        ),
        
        SleepTip(
            title: "Правило 20 хвилин",
            description: "Короткий сон перезавантажує мозок. Головне — встати до початку фази глибокого сну.",
            color: .appGreen,
            icon: "timer"
        ),
        
        SleepTip(
            title: "Ефект бадьорості",
            description: "Якщо ви спите вдень, робіть це до 15:00, щоб не зіпсувати свій основний нічний графік.",
            color: .appGreen,
            icon: "deskclock"
        ),
        
        SleepTip(
            title: "Темні окуляри",
            description: "Для денного сну використовуйте маску. Навіть через закриті повіки мозок реагує на світло, що заважає якісному відпочинку.",
            color: .appPrimary,
            icon: "sunglasses"
        ),
        
        SleepTip(
            title: "Кофеїновий сон",
            description: "Якщо ви пʼєте каву, то зробіть це безпосередньо перед 20-хвилинним сном. Кофеїн подіє якраз тоді, коли ви прокинетеся, давши подвійний заряд енергії.",
            color: .appRed,
            icon: "cup.and.heat.waves"
        )
    ]
}
