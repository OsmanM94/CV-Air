
import Foundation


enum CVTemplateType: String, CaseIterable, Identifiable {
    case original = "Original"
    case modernMinimalist = "Modern Minimalist"
    case classicProfessional = "Classic Professional"
    case compactEfficient = "Compact and Efficient"
    
    var id: String { self.rawValue }
    
    var productId: String {
        switch self {
        case .original: return ""
        case .modernMinimalist: return "template2"
        case .classicProfessional: return "template3"
        case .compactEfficient: return "template4"
        }
    }
}
