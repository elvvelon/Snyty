import SwiftUI
import Snytysia

extension SleepSession {
    var formatStartDate: String {
        let calendar = Calendar.current
        
        let startOfTargetDate = calendar.startOfDay(for: startDate)
        let startOfToday = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: startOfTargetDate, to: startOfToday)
        let daysDifference = components.day ?? 0
        
        if daysDifference == 0 {
            return String(localized: "Сьогодні")
        } else if daysDifference == 1 {
            return  String(localized: "Вчора")
        } else if daysDifference < 7 && daysDifference > 0 {
            return startDate.formatted(.dateTime.weekday(.wide))
        } else {
            return startDate.formatted(date: .numeric, time: .omitted)
        }
    }
    
    var durationFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    var duration: String? { durationFormatter.string(from: (endDate ?? Date()).timeIntervalSince(startDate)) }
    
    var avarageNoiseVolume: Int? {
        guard noiseSamplesCount > 0 else { return nil }
        
        return Int(noiseVolumeSum / Float(noiseSamplesCount))
    }
}
