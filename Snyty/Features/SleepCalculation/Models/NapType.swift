import SwiftUI

enum NapType: CaseIterable {
    case shortest, oneCycle
    
    var imageName: String {
        switch self {
        case .shortest:
            "cup.and.heat.waves"
        case .oneCycle:
            "moon.stars"
        }
    }
    
    var title: LocalizedStringResource {
        switch self {
        case .shortest:
            "20 хвилин"
        case .oneCycle:
            "90 хвилин"
        }
    }
    
    var subtitle: LocalizedStringResource {
        switch self {
        case .shortest:
            "20 хв"
        case .oneCycle:
            "90 хв"
        }
    }
    
    var note: LocalizedStringResource {
        switch self {
        case .shortest:
            "Легке відновлення"
        case .oneCycle:
            "Повний цикл"
        }
    }
    
    var color: Color {
        switch self {
        case .shortest:
                .accent
        case .oneCycle:
                .appYellow
        }
    }
    
//    var bacgroundColor: Color {
//        switch self {
//        case .shortest:
//                .backgroundBlue
//        case .oneCycle:
//                .backgroundYellow
//        }
//    }
}
