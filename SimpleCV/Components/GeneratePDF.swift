
import Foundation

func generatePDF(for cv: CV, using templateType: CVTemplateType, fontSize: CVFontSize, spacing: CVSpacing) async -> Data {
    switch templateType {
    case .original:
        return await OriginalTemplate.generatePDF(for: cv, fontSize: fontSize, spacing: spacing)
    case .modernMinimalist:
        return await ModernMinimalistTemplate.generatePDF(for: cv, fontSize: fontSize, spacing: spacing)
    case .classicProfessional:
        return await ClassicProfessionalTemplate.generatePDF(for: cv, fontSize: fontSize, spacing: spacing)
    case .compactEfficient:
        return await CompactEfficientTemplate.generatePDF(for: cv, fontSize: fontSize, spacing: spacing)
    }
}

