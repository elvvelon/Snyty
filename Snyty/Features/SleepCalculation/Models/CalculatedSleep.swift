import Foundation

struct CalculatedSleep: Identifiable {
    let id = UUID()
    let time: Date
    let cycles: Int
    
    var formatedInfo: String {
        let cyclesString = String(localized: "\(cycles) cycles_key")
        let hFormated = (Double(cycles) * Double(AppPresetsManager.shared.cycleDuration) / 60.0).formatted(.number.precision(.fractionLength(0...1)).locale(Locale(identifier: "en_US")))
        let hoursString = String(localized: "\(hFormated) hours_key сну")
        return "\(cyclesString) • \(hoursString)"
    }
}

extension Date {
    var formatedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: self)
        return currentTime
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
}
