
import SwiftUI

protocol CVTemplate {
    static func generatePDF(for cv: CV) async -> Data
}

struct OriginalTemplate: CVTemplate {
    static func generatePDF(for cv: CV) async -> Data {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = createPDFRenderer(for: cv)
                
                let data = renderer.pdfData { context in
                    var currentYOffset: CGFloat = 0
                    
                    context.beginPage()
                    
                    currentYOffset = addTitle(cv.personalInfo.name, pageRect: context.pdfContextBounds)
                    currentYOffset = addPersonalInfo(cv.personalInfo, pageRect: context.pdfContextBounds, yOffset: currentYOffset)
                    
                    if !cv.summary.isEmpty {
                        currentYOffset = addSection(title: "Summary", content: [cv.summary], pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context)
                    }
                    
                    if !cv.professionalHistory.isEmpty {
                        currentYOffset = addHistorySection(title: "Professional History", history: cv.professionalHistory, pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context)
                    }
                    
                    if !cv.educationalHistory.isEmpty {
                        currentYOffset = addHistorySection(title: "Educational History", history: cv.educationalHistory, pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context)
                    }
                    
                    if !cv.projects.isEmpty {
                        currentYOffset = addProjects(cv.projects, pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context)
                    }
                    
                    if !cv.skills.isEmpty {
                        currentYOffset = addSection(title: "Skills", content: [cv.skills.joined(separator: " • ")], pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context)
                    }
                }
                
                continuation.resume(returning: data)
            }
        }
    }
    
    private static func createPDFRenderer(for cv: CV) -> UIGraphicsPDFRenderer {
        let pdfMetaData = [
            kCGPDFContextCreator: "CV Maker App",
            kCGPDFContextAuthor: cv.personalInfo.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        return UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    }
    
    private static func addTitle(_ title: String, pageRect: CGRect) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 24.0, weight: .bold)
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleStringSize = attributedTitle.size()
        let titleStringRect = CGRect(x: 36, y: 36, width: pageRect.width - 72, height: titleStringSize.height)
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringSize.height + 10
    }
    
    private static func addPersonalInfo(_ info: PersonalInfo, pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        var yPosition = yOffset
        
        let firstLineString = "\(info.address) • \(info.phoneNumber)"
        let firstLineAttributed = NSAttributedString(string: firstLineString, attributes: attributes)
        let firstLineRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
        firstLineAttributed.draw(in: firstLineRect)
        yPosition += 20
        
        let emailString = "\(info.email)"
        let emailAttributed = NSAttributedString(string: emailString, attributes: attributes)
        let emailRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
        emailAttributed.draw(in: emailRect)
        yPosition += 20
        
        if let website = info.website, !website.isEmpty {
            let websiteString = "Website: \(website)"
            let websiteAttributed = NSAttributedString(string: websiteString, attributes: attributes)
            let websiteRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
            websiteAttributed.draw(in: websiteRect)
            yPosition += 20
        }
        
        return yPosition + 10
    }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        let contentFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        let contentAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: contentFont]
        
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleSize = attributedTitle.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        var yPosition = yOffset
        
        if title == "Skills" {
            yPosition += 10
        }
        
        if yPosition + titleSize.height + 30 > pageRect.height - 72 {
            context.beginPage()
            yPosition = 36
        }
        
        let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: titleSize.height)
        attributedTitle.draw(in: titleRect)
        yPosition += titleSize.height + 10
        
        for line in content {
            let attributedContent = NSAttributedString(string: line, attributes: contentAttributes)
            let contentSize = attributedContent.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            if yPosition + contentSize.height > pageRect.height - 72 {
                context.beginPage()
                yPosition = 36
            }
            
            let contentRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: contentSize.height)
            attributedContent.draw(in: contentRect)
            yPosition += contentSize.height + 5
        }
        
        return yPosition + 10
    }
    
    private static func addHistorySection(title: String, history: [HistoryEntry], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        let entryTitleFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        let entryTitleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: entryTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: detailsFont]
        
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleSize = attributedTitle.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        var yPosition = yOffset
        
        if yPosition + titleSize.height + 60 > pageRect.height - 72 {
            context.beginPage()
            yPosition = 36
        }
        
        let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: titleSize.height)
        attributedTitle.draw(in: titleRect)
        yPosition += titleSize.height + 10
        
        for entry in history {
            if yPosition > pageRect.height - 72 {
                context.beginPage()
                yPosition = 36
            }
            
            let entryTitleText = "\(entry.title), \(entry.subtitle)"
            let dateText = formatYearRange(start: entry.startYear, end: entry.endYear)
            
            let attributedEntryTitle = NSAttributedString(string: entryTitleText, attributes: entryTitleAttributes)
            let attributedDate = NSAttributedString(string: dateText, attributes: detailsAttributes)
            
            let entryTitleSize = attributedEntryTitle.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            let dateSize = attributedDate.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            let entryTitleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: entryTitleSize.height)
            let dateRect = CGRect(x: 36, y: yPosition + entryTitleSize.height, width: pageRect.width - 72, height: dateSize.height)
            
            attributedEntryTitle.draw(in: entryTitleRect)
            attributedDate.draw(in: dateRect)
            
            yPosition += entryTitleSize.height + dateSize.height + 10
            
            for detail in entry.details {
                if yPosition > pageRect.height - 72 {
                    context.beginPage()
                    yPosition = 36
                }
                
                let bulletPoint = "• \(detail)"
                let attributedBullet = NSAttributedString(string: bulletPoint, attributes: detailsAttributes)
                let bulletSize = attributedBullet.boundingRect(with: CGSize(width: pageRect.width - 82, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                let bulletRect = CGRect(x: 46, y: yPosition, width: pageRect.width - 82, height: bulletSize.height)
                attributedBullet.draw(in: bulletRect)
                yPosition += bulletSize.height + 5
            }
            
            yPosition += 10
        }
        
        return yPosition
    }
    
    private static func addProjects(_ projects: [Project], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        let projectTitleFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        let projectTitleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: projectTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: detailsFont]
        
        let title = "Projects"
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleSize = attributedTitle.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        var yPosition = yOffset
        
        if yPosition + titleSize.height + 60 > pageRect.height - 72 {
            context.beginPage()
            yPosition = 36
        }
        
        let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: titleSize.height)
        attributedTitle.draw(in: titleRect)
        yPosition += titleSize.height + 10
        
        for project in projects {
            if yPosition > pageRect.height - 72 {
                context.beginPage()
                yPosition = 36
            }
            
            let attributedProjectTitle = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
            let titleSize = attributedProjectTitle.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: titleSize.height)
            attributedProjectTitle.draw(in: titleRect)
            yPosition += titleSize.height + 5
            
            if yPosition > pageRect.height - 72 {
                context.beginPage()
                yPosition = 36
            }
            let attributedDetails = NSAttributedString(string: project.details, attributes: detailsAttributes)
            let detailsSize = attributedDetails.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            let detailsRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: detailsSize.height)
            attributedDetails.draw(in: detailsRect)
            yPosition += detailsSize.height + 10
        }
        
        return yPosition
    }
}

struct ModernMinimalistTemplate: CVTemplate {
    static func generatePDF(for cv: CV) async -> Data {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = createPDFRenderer(for: cv)
                
                let data = renderer.pdfData { context in
                    let pageRect = context.pdfContextBounds
                    var currentYOffset: CGFloat = 0
                    
                    context.beginPage()
                    
                    currentYOffset = addHeader(cv.personalInfo, pageRect: pageRect)
                    
                    let leftColumnWidth: CGFloat = pageRect.width * 0.35
                    let rightColumnWidth: CGFloat = pageRect.width * 0.55 // Reduced from 0.60 to add padding
                    let leftColumnXOffset: CGFloat = 36
                    let rightColumnXOffset: CGFloat = leftColumnXOffset + leftColumnWidth + 20 // Increased from 10 to add more space between columns
                    
                    var leftColumnYOffset = currentYOffset
                    var rightColumnYOffset = currentYOffset
                    
                    // Right column (now starts at the top)
                    rightColumnYOffset = addSection(title: "Summary", content: [cv.summary], pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset)
                    rightColumnYOffset = addHistorySection(title: "Professional Experience", history: cv.professionalHistory, pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset, context: context)
                    rightColumnYOffset = addProjects(cv.projects, pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset, context: context)
                    
                    // Left column
                    leftColumnYOffset = addSection(title: "Skills", content: cv.skills, pageRect: pageRect, yOffset: leftColumnYOffset, width: leftColumnWidth, xOffset: leftColumnXOffset)
                    leftColumnYOffset = addHistorySection(title: "Education", history: cv.educationalHistory, pageRect: pageRect, yOffset: leftColumnYOffset, width: leftColumnWidth, xOffset: leftColumnXOffset, context: context)
                }
                
                continuation.resume(returning: data)
            }
        }
    }
    
    private static func createPDFRenderer(for cv: CV) -> UIGraphicsPDFRenderer {
        let pdfMetaData = [
            kCGPDFContextCreator: "CV Maker App",
            kCGPDFContextAuthor: cv.personalInfo.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        return UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    }
    
    private static func addHeader(_ info: PersonalInfo, pageRect: CGRect) -> CGFloat {
        let nameFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let nameAttributes: [NSAttributedString.Key: Any] = [.font: nameFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let nameString = NSAttributedString(string: info.name, attributes: nameAttributes)
        let emailString = NSAttributedString(string: info.email, attributes: detailsAttributes)
        let phoneString = NSAttributedString(string: info.phoneNumber, attributes: detailsAttributes)
        let addressString = NSAttributedString(string: info.address, attributes: detailsAttributes)
        
        nameString.draw(at: CGPoint(x: 36, y: 36))
        
        let nameBounds = nameString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let lineY = 36 + nameBounds.height + 5
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 36, y: lineY))
        linePath.addLine(to: CGPoint(x: pageRect.width - 36, y: lineY))
        UIColor.gray.setStroke()
        linePath.stroke()
        
        var currentY = lineY + 10
        
        // Draw email
        emailString.draw(at: CGPoint(x: 36, y: currentY))
        currentY += emailString.size().height + 5
        
        // Draw address
        let addressRect = addressString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        addressString.draw(in: CGRect(x: 36, y: currentY, width: pageRect.width - 72, height: addressRect.height))
        currentY += addressRect.height + 5
        
        // Draw phone number
        phoneString.draw(at: CGPoint(x: 36, y: currentY))
        currentY += phoneString.size().height + 5
        
        // Draw website if available
        if let website = info.website, !website.isEmpty {
            let websiteString = NSAttributedString(string: "Website: \(website)", attributes: detailsAttributes)
            websiteString.draw(at: CGPoint(x: 36, y: currentY))
            currentY += websiteString.size().height + 5
        }
        
        return currentY + 10 // Add some extra padding at the bottom of the header
    }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let contentFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: contentFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: xOffset, y: yOffset))
        
        var currentY = yOffset + 20
        
        for item in content {
            let itemString = NSAttributedString(string: "• \(item)", attributes: contentAttributes)
            let itemRect = itemString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            itemString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: itemRect.height))
            currentY += itemRect.height + 5
        }
        
        return currentY + 10
    }
    
    private static func addHistorySection(title: String, history: [HistoryEntry], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let entryTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let entryTitleAttributes: [NSAttributedString.Key: Any] = [.font: entryTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: xOffset, y: yOffset))
        
        var currentY = yOffset + 20
        
        for entry in history {
            let entryTitleText = "\(entry.title), \(entry.subtitle)"
            let dateText = formatYearRange(start: entry.startYear, end: entry.endYear)
            
            let entryTitleString = NSAttributedString(string: entryTitleText, attributes: entryTitleAttributes)
            let dateString = NSAttributedString(string: dateText, attributes: detailsAttributes)
            
            let titleRect = entryTitleString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            entryTitleString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: titleRect.height))
            currentY += titleRect.height + 5
            
            dateString.draw(at: CGPoint(x: xOffset, y: currentY))
            currentY += 15
            
            for detail in entry.details {
                let detailString = NSAttributedString(string: "• \(detail)", attributes: detailsAttributes)
                let detailRect = detailString.boundingRect(with: CGSize(width: width - 20, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                if currentY + detailRect.height > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                detailString.draw(in: CGRect(x: xOffset + 10, y: currentY, width: width - 20, height: detailRect.height))
                currentY += detailRect.height + 5
            }
            
            currentY += 10
        }
        
        return currentY
    }
    
    private static func addProjects(_ projects: [Project], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let projectTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let titleString = NSAttributedString(string: "Projects", attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: xOffset, y: yOffset))
        
        var currentY = yOffset + 20
        
        for project in projects {
            let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
            let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
            
            let titleRect = projectTitleString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            projectTitleString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: titleRect.height))
            currentY += titleRect.height + 5
            
            let detailsRect = detailsString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            if currentY + detailsRect.height > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            detailsString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: detailsRect.height))
            currentY += detailsRect.height + 15
        }
        
        return currentY
    }
    
    private static func drawVerticalLine(in context: UIGraphicsPDFRendererContext, pageRect: CGRect, xOffset: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: xOffset, y: 36))
        path.addLine(to: CGPoint(x: xOffset, y: pageRect.height - 36))
        UIColor.lightGray.setStroke()
        path.stroke()
    }
}

struct ClassicProfessionalTemplate: CVTemplate {
    static func generatePDF(for cv: CV) async -> Data {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = createPDFRenderer(for: cv)
                
                let data = renderer.pdfData { context in
                    let pageRect = context.pdfContextBounds
                    var currentYOffset: CGFloat = 0
                    
                    context.beginPage()
                    
                    currentYOffset = addCenteredName(cv.personalInfo.name, pageRect: pageRect)
                    currentYOffset = addContactInfo(cv.personalInfo, pageRect: pageRect, yOffset: currentYOffset)
                    
                    currentYOffset = addSection(title: "SUMMARY", content: [cv.summary], pageRect: pageRect, yOffset: currentYOffset, context: context)
                    currentYOffset = addHistorySection(title: "PROFESSIONAL EXPERIENCE", history: cv.professionalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context)
                    currentYOffset = addHistorySection(title: "EDUCATION", history: cv.educationalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context)
                    currentYOffset = addProjects(title: "PROJECTS", projects: cv.projects, pageRect: pageRect, yOffset: currentYOffset, context: context)
                    currentYOffset = addSection(title: "SKILLS", content: cv.skills, pageRect: pageRect, yOffset: currentYOffset, context: context)
                }
                
                continuation.resume(returning: data)
            }
        }
    }
    
    private static func createPDFRenderer(for cv: CV) -> UIGraphicsPDFRenderer {
        let pdfMetaData = [
            kCGPDFContextCreator: "CV Maker App",
            kCGPDFContextAuthor: cv.personalInfo.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        return UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    }
    
    private static func addCenteredName(_ name: String, pageRect: CGRect) -> CGFloat {
        let nameFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        let nameAttributes: [NSAttributedString.Key: Any] = [.font: nameFont]
        let nameString = NSAttributedString(string: name, attributes: nameAttributes)
        
        let nameBounds = nameString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let nameX = (pageRect.width - nameBounds.width) / 2
        nameString.draw(at: CGPoint(x: nameX, y: 36))
        
        let lineY = 36 + nameBounds.height + 5
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: 36, y: lineY))
        linePath.addLine(to: CGPoint(x: pageRect.width - 36, y: lineY))
        UIColor.black.setStroke()
        linePath.stroke()
        
        return lineY + 10
    }
    
    private static func addContactInfo(_ info: PersonalInfo, pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 10, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        
        let contactString = NSAttributedString(string: "\(info.email) | \(info.phoneNumber) | \(info.address)", attributes: attributes)
        let stringSize = contactString.size()
        let x = (pageRect.width - stringSize.width) / 2
        
        contactString.draw(at: CGPoint(x: x, y: yOffset))
        
        return yOffset + stringSize.height + 20
    }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let contentFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: contentFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: 36, y: yOffset))
        
        var currentY = yOffset + 25
        
        for item in content {
            let itemString = NSAttributedString(string: item, attributes: contentAttributes)
            let itemRect = itemString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            if currentY + itemRect.height > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            itemString.draw(in: CGRect(x: 36, y: currentY, width: pageRect.width - 72, height: itemRect.height))
            currentY += itemRect.height + 10
        }
        
        return currentY + 10
    }
    
    private static func addHistorySection(title: String, history: [HistoryEntry], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let entryTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let entryTitleAttributes: [NSAttributedString.Key: Any] = [.font: entryTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: 36, y: yOffset))
        
        var currentY = yOffset + 25
        
        for entry in history {
            let entryTitleText = "\(entry.title), \(entry.subtitle)"
            let dateText = formatYearRange(start: entry.startYear, end: entry.endYear)
            
            let entryTitleString = NSAttributedString(string: entryTitleText, attributes: entryTitleAttributes)
            let dateString = NSAttributedString(string: dateText, attributes: detailsAttributes)
            
            if currentY + 50 > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            entryTitleString.draw(at: CGPoint(x: 36, y: currentY))
            
            let dateSize = dateString.size()
            dateString.draw(at: CGPoint(x: pageRect.width - 36 - dateSize.width, y: currentY))
            
            currentY += 20
            
            for detail in entry.details {
                let detailString = NSAttributedString(string: "• \(detail)", attributes: detailsAttributes)
                let detailRect = detailString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                if currentY + detailRect.height > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                detailString.draw(in: CGRect(x: 46, y: currentY, width: pageRect.width - 82, height: detailRect.height))
                currentY += detailRect.height + 5
            }
            
            currentY += 15
        }
        
        return currentY
    }
    
    private static func addProjects(title: String, projects: [Project], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let projectTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: 36, y: yOffset))
        
        var currentY = yOffset + 25
        
        for project in projects {
            let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
            let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
            
            if currentY + 50 > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            projectTitleString.draw(at: CGPoint(x: 36, y: currentY))
            currentY += 20
            
            let detailsRect = detailsString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            if currentY + detailsRect.height > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            detailsString.draw(in: CGRect(x: 36, y: currentY, width: pageRect.width - 72, height: detailsRect.height))
            currentY += detailsRect.height + 15
        }
        
        return currentY
    }
}

struct CompactEfficientTemplate: CVTemplate {
    static func generatePDF(for cv: CV) async -> Data {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = createPDFRenderer(for: cv)
                
                let data = renderer.pdfData { context in
                    let pageRect = context.pdfContextBounds
                    var currentYOffset: CGFloat = 0
                    
                    context.beginPage()
                    
                    currentYOffset = addCompactHeader(cv.personalInfo, pageRect: pageRect)
                    
                    currentYOffset = addSection(title: "Summary", content: [cv.summary], pageRect: pageRect, yOffset: currentYOffset, context: context, compactSpacing: true)
                    currentYOffset = addHistorySection(title: "Experience", history: cv.professionalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context, compactSpacing: true)
                    currentYOffset = addHistorySection(title: "Education", history: cv.educationalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context, compactSpacing: true)
                    
                    let columnWidth = (pageRect.width - 72) / 2
                    var leftColumnYOffset = currentYOffset
                    var rightColumnYOffset = currentYOffset
                    
                    leftColumnYOffset = addSection(title: "Skills", content: cv.skills, pageRect: pageRect, yOffset: leftColumnYOffset, context: context, compactSpacing: true, width: columnWidth, xOffset: 36)
                    rightColumnYOffset = addProjects(cv.projects, pageRect: pageRect, yOffset: rightColumnYOffset, width: columnWidth, xOffset: columnWidth + 46, context: context, compactSpacing: true)
                }
                
                continuation.resume(returning: data)
            }
        }
    }
    
    private static func createPDFRenderer(for cv: CV) -> UIGraphicsPDFRenderer {
        let pdfMetaData = [
            kCGPDFContextCreator: "CV Maker App",
            kCGPDFContextAuthor: cv.personalInfo.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        return UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    }
    
    private static func addCompactHeader(_ info: PersonalInfo, pageRect: CGRect) -> CGFloat {
        let nameFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        let detailsFont = UIFont.systemFont(ofSize: 9, weight: .regular)
        
        let nameAttributes: [NSAttributedString.Key: Any] = [.font: nameFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let nameString = NSAttributedString(string: info.name, attributes: nameAttributes)
        let detailsString = NSAttributedString(string: "\(info.email) | \(info.phoneNumber) | \(info.address)", attributes: detailsAttributes)
        
        nameString.draw(at: CGPoint(x: 36, y: 36))
        
        let nameBounds = nameString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        detailsString.draw(at: CGPoint(x: 36, y: 36 + nameBounds.height + 2))
        
        return 36 + nameBounds.height + detailsString.size().height + 10
    }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, compactSpacing: Bool = false, width: CGFloat? = nil, xOffset: CGFloat = 36) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        let contentFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: contentFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: xOffset, y: yOffset))
        
        var currentY = yOffset + (compactSpacing ? 15 : 20)
        
        for item in content {
            let itemString = NSAttributedString(string: "• \(item)", attributes: contentAttributes)
            let itemRect = itemString.boundingRect(with: CGSize(width: width ?? (pageRect.width - 72), height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            if currentY + itemRect.height > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            itemString.draw(in: CGRect(x: xOffset, y: currentY, width: width ?? (pageRect.width - 72), height: itemRect.height))
            currentY += itemRect.height + (compactSpacing ? 2 : 5)
        }
        
        return currentY + (compactSpacing ? 5 : 10)
    }
    
    private static func addHistorySection(title: String, history: [HistoryEntry], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, compactSpacing: Bool = false) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        let entryTitleFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let entryTitleAttributes: [NSAttributedString.Key: Any] = [.font: entryTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: 36, y: yOffset))
        
        var currentY = yOffset + (compactSpacing ? 15 : 20)
        
        for entry in history {
            let entryTitleText = "\(entry.title), \(entry.subtitle)"
            let dateText = formatYearRange(start: entry.startYear, end: entry.endYear)
            
            let entryTitleString = NSAttributedString(string: entryTitleText, attributes: entryTitleAttributes)
            let dateString = NSAttributedString(string: dateText, attributes: detailsAttributes)
            
            if currentY + 30 > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            entryTitleString.draw(at: CGPoint(x: 36, y: currentY))
            
            let dateSize = dateString.size()
            dateString.draw(at: CGPoint(x: pageRect.width - 36 - dateSize.width, y: currentY))
            
            currentY += 15
            
            for detail in entry.details {
                let detailString = NSAttributedString(string: "• \(detail)", attributes: detailsAttributes)
                let detailRect = detailString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                if currentY + detailRect.height > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                detailString.draw(in: CGRect(x: 46, y: currentY, width: pageRect.width - 82, height: detailRect.height))
                currentY += detailRect.height + (compactSpacing ? 2 : 5)
            }
            
            currentY += compactSpacing ? 5 : 10
        }
        
        return currentY
    }
    
    private static func addProjects(_ projects: [Project], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext, compactSpacing: Bool = false) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        let projectTitleFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let titleString = NSAttributedString(string: "Projects", attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: xOffset, y: yOffset))
        
        var currentY = yOffset + (compactSpacing ? 15 : 20)
        
        for project in projects {
            let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
            let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
            
            if currentY + 30 > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            projectTitleString.draw(at: CGPoint(x: xOffset, y: currentY))
            currentY += 15
            
            let detailsRect = detailsString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            if currentY + detailsRect.height > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            detailsString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: detailsRect.height))
            currentY += detailsRect.height + (compactSpacing ? 5 : 10)
        }
        
        return currentY
    }
}
