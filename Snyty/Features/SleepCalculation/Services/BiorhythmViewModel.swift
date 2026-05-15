import Foundation
import SwiftUI

struct Hormone: Identifiable {
    var id: String { "\(time.timeIntervalSince1970)-\(type.rawValue)" }
    let time: Date
    let level: Double
    let type: HormoneType
}

enum HormoneType: String {
    case melatonin = "Мелатонін"
    case cortisol = "Кортизол"
    
    var color: Color {
        switch self {
        case .melatonin: .appPrimary
        case .cortisol: .appYellow
        }
    }
}

@MainActor
@Observable
class BiorhythmViewModel {
    var chartData: [Hormone] = []
    var snapTargetDate: Date {
        Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date()
    }
    
    var snapTargetComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day, .hour], from: snapTargetDate)
    }
    
    var descrintion: LocalizedStringResource {
        let offsetDate = Calendar.current.date(byAdding: .hour, value: -Int(AppPresetsManager.shared.biorhythmOffset), to: Date())
        let hour = Calendar.current.component(.hour, from: offsetDate ?? Date())
        
        switch hour {
        case 22...24, 0...5:
            return "Оптимальний час для глибокого відновлення та сну"
        case 6...9:
            return "Організм прокидається, рівень кортизолу зростає"
        case 10...14:
            return "Пік продуктивності та фокусу, найкращий час для складних завдань"
        case 15...18:
            return "Природний спад енергії, добре підходить для рутинної роботи"
        case 19...21:
            return "Час сповільнюватися, організм готується до сну"
        default:
            return "Підтримуйте природний ритм"
        }
    }
    
    init() {
        chartData = calculateLevels()
    }
    
    func calculateLevels(hoursBack: Int = -30, hoursForward: Int = 30) -> [Hormone] {
        var data: [Hormone] = []
        let calendar = Calendar.current
        let now = Date()
        
        for step in hoursBack...hoursForward {
            guard let time = calendar.date(byAdding: .hour, value: step, to: now) else { continue }
            
            let hour = calendar.component(.hour, from: time)
            let minute = calendar.component(.minute, from: time)
            let timeInHours = Double(hour) + Double(minute) / 60.0
            
            // Melatonin
            var melatoninLevel = 10.0
            for dayOffset in [-24.0, 0.0, 24.0] {
                let peakTime = 3.0 + dayOffset + AppPresetsManager.shared.biorhythmOffset
                let diff = timeInHours - peakTime
                melatoninLevel += 90.0 * exp(-pow(diff, 2) / 12.0)
            }
            
            // Cortisol
            var cortisolLevel = 10.0
            for dayOffset in [-24.0, 0.0, 24.0] {
                let peakTime = 8.0 + dayOffset + AppPresetsManager.shared.biorhythmOffset
                let diff = timeInHours - peakTime
                let variance = diff < 0 ? 10.0 : 35.0
                cortisolLevel += 90.0 * exp(-pow(diff, 2) / variance)
            }
            
            data.append(Hormone(time: time, level: min(melatoninLevel, 100.0), type: .melatonin))
            data.append(Hormone(time: time, level: min(cortisolLevel, 100.0), type: .cortisol))
        }
        
        return data
    }
}
