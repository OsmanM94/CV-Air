
import Foundation

func generatePDF(for cv: CV, using templateType: CVTemplateType) async -> Data {
    switch templateType {
    case .original:
        return await OriginalTemplate.generatePDF(for: cv)
    case .modernMinimalist:
        return await ModernMinimalistTemplate.generatePDF(for: cv)
    case .classicProfessional:
        return await ClassicProfessionalTemplate.generatePDF(for: cv)
    case .compactEfficient:
        return await CompactEfficientTemplate.generatePDF(for: cv)
    }
}
