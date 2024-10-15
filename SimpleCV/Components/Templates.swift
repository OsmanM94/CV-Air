
import Foundation

enum CVTemplateType: String, CaseIterable, Identifiable {
    case original = "Original"
    case modernMinimalist = "Modern Minimalist"
    case classicProfessional = "Classic Professional"
    case compactEfficient = "Compact and Efficient"
    
    var id: String { self.rawValue }
}
