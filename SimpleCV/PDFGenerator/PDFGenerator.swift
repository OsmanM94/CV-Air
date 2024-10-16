
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
                        currentYOffset = addProjects(title: "Projects", projects: cv.projects, pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context)
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
        
//        let pageWidth = 8.5 * 72.0
//        let pageHeight = 11 * 72.0
//        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let pageWidth = 595.0  // 210 mm in points (72 points per inch)
        let pageHeight = 842.0 // 297 mm in points (72 points per inch)
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
            let websiteString = "\(website)"
            let websiteAttributed = NSAttributedString(string: websiteString, attributes: attributes)
            let websiteRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
            websiteAttributed.draw(in: websiteRect)
            yPosition += 20
        }
        
        return yPosition + 10
    }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, additionalTopPadding: CGFloat = 5) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        let contentFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        let contentAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: contentFont]
        
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleSize = attributedTitle.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        // Calculate the total height of the section
        var totalHeight = titleSize.height + 10 + additionalTopPadding // Title height plus some padding and additional top padding
        for line in content {
            let attributedContent = NSAttributedString(string: line, attributes: contentAttributes)
            let contentSize = attributedContent.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            totalHeight += contentSize.height + 5 // Content height plus some padding
        }
        
        var yPosition = yOffset + additionalTopPadding
        
        // If the section doesn't fit on the current page, start a new page
        if yPosition + totalHeight > pageRect.height - 72 {
            context.beginPage()
            yPosition = 36 + additionalTopPadding
        }
        
        // Draw the title
        let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: titleSize.height)
        attributedTitle.draw(in: titleRect)
        yPosition += titleSize.height + 10
        
        // Draw the content
        for line in content {
            let attributedContent = NSAttributedString(string: line, attributes: contentAttributes)
            let contentSize = attributedContent.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
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
    
    private static func addProjects(title: String, projects: [Project], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let projectTitleFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        let titleSize = titleString.size()
        
        var currentY = yOffset
        
        // Check if there's enough space for the title and at least one project
        if currentY + titleSize.height + 50 > pageRect.height - 72 {
            context.beginPage()
            currentY = 36
        }
        
        titleString.draw(at: CGPoint(x: 36, y: currentY))
        currentY += titleSize.height + 15
        
        for project in projects {
            let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
            let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
            
            let projectTitleSize = projectTitleString.size()
            let detailsRect = detailsString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            let totalProjectHeight = projectTitleSize.height + detailsRect.height + 20 // 20 for padding
            
            // Check if there's enough space for the entire project
            if currentY + totalProjectHeight > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            projectTitleString.draw(at: CGPoint(x: 36, y: currentY))
            currentY += projectTitleSize.height + 5
            
            detailsString.draw(in: CGRect(x: 36, y: currentY, width: pageRect.width - 72, height: detailsRect.height))
            currentY += detailsRect.height + 15
        }
        
        return currentY
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
                    let rightColumnWidth: CGFloat = pageRect.width * 0.55 // Adjusted for better spacing
                    let leftColumnXOffset: CGFloat = 36
                    let rightColumnXOffset: CGFloat = leftColumnXOffset + leftColumnWidth + 20 // Increased space between columns
                    
                    // Left column (Skills and Education first)
                    var leftColumnYOffset = currentYOffset
                    leftColumnYOffset = addSection(title: "Skills", content: cv.skills, pageRect: pageRect, yOffset: leftColumnYOffset, width: leftColumnWidth, xOffset: leftColumnXOffset, context: context)
                    leftColumnYOffset = addHistorySection(title: "Education", history: cv.educationalHistory, pageRect: pageRect, yOffset: leftColumnYOffset, width: leftColumnWidth, xOffset: leftColumnXOffset, context: context)
                    
                    // Right column (Summary, Experience, and Projects)
                    var rightColumnYOffset = currentYOffset
                    rightColumnYOffset = addSection(title: "Summary", content: [cv.summary], pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset, context: context)
                    rightColumnYOffset = addHistorySection(title: "Professional Experience", history: cv.professionalHistory, pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset, context: context)
                    rightColumnYOffset = addProjects(cv.projects, pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset, context: context)
                }
                
                continuation.resume(returning: data)
            }
        }
    }

    private static func addProjects(_ projects: [Project], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let projectTitleFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        var currentY = yOffset
        
        // Check if we need to create a new page for the title
        if currentY + 20 > pageRect.height - 72 {
            context.beginPage()
            currentY = 36
        }
        
        let titleString = NSAttributedString(string: "Projects", attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: xOffset, y: currentY))
        
        currentY += 20
        
        // Loop through all projects
        for (index, project) in projects.enumerated() {
            let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
            let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
            
            let titleRect = projectTitleString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            let detailsRect = detailsString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            let requiredHeight = titleRect.height + detailsRect.height + 15
            
            // Check remaining height for all the remaining projects
            let totalRemainingHeight: CGFloat = projects[index...].reduce(0) { result, project in
                let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
                let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
                
                let titleRect = projectTitleString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                let detailsRect = detailsString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                // Ensure result is non-optional CGFloat
                return result + titleRect.height + detailsRect.height + 15
            }
            
            // If the total remaining height can fit in the current page, continue on this page
            if currentY + totalRemainingHeight <= pageRect.height - 72 {
                // Draw project title and details
                projectTitleString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: titleRect.height))
                currentY += titleRect.height + 5
                
                detailsString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: detailsRect.height))
                currentY += detailsRect.height + 15
            } else {
                // Start a new page if necessary
                if currentY + requiredHeight > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                // Draw project title and details on the new page
                projectTitleString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: titleRect.height))
                currentY += titleRect.height + 5
                
                detailsString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: detailsRect.height))
                currentY += detailsRect.height + 15
            }
        }
        
        return currentY
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
            let websiteString = NSAttributedString(string: "\(website)", attributes: detailsAttributes)
            websiteString.draw(at: CGPoint(x: 36, y: currentY))
            currentY += websiteString.size().height + 5
        }
        
        return currentY + 10 // Add some extra padding at the bottom of the header
    }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let contentFont = UIFont.systemFont(ofSize: 10, weight: .regular)

        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: contentFont]

        var currentY = yOffset

        // Check if title will overflow
        if currentY + 20 > pageRect.height - 72 {
            context.beginPage()
            currentY = 36 // Reset to top of the new page
        }

        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: xOffset, y: currentY))

        currentY += 20

        for item in content {
            let itemString = NSAttributedString(string: "• \(item)", attributes: contentAttributes)
            let itemRect = itemString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)

            // Check if the next item will overflow the page
            if currentY + itemRect.height > pageRect.height - 72 {
                context.beginPage()
                currentY = 36 // Reset Y offset for new page
            }

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
        
        var currentY = yOffset + stringSize.height
        
        if let website = info.website, !website.isEmpty {
            let websiteString = NSAttributedString(string: website, attributes: attributes)
            let websiteSize = websiteString.size()
            let websiteX = (pageRect.width - websiteSize.width) / 2
            
            currentY += 5 // Add a small gap between contact info and website
            websiteString.draw(at: CGPoint(x: websiteX, y: currentY))
            currentY += websiteSize.height
        }
        
        return currentY + 20 // Add some padding after the contact info
    }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        let contentFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let contentAttributes: [NSAttributedString.Key: Any] = [.font: contentFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: 36, y: yOffset))
        
        var currentY = yOffset + 25
        
        if title == "SKILLS" {
            let margin: CGFloat = 36
            let columnSpacing: CGFloat = 5 // Adjust this value to increase/decrease space between columns
            let totalWidth = pageRect.width - (2 * margin) // Total available width
            let columnWidth = (totalWidth - columnSpacing) / 3 // Width of each column
            
            let leftX: CGFloat = margin
            let rightX: CGFloat = leftX + columnWidth + columnSpacing
            
            for i in stride(from: 0, to: content.count, by: 2) {
                let skill1 = "• " + content[i]
                let skill1String = NSAttributedString(string: skill1, attributes: contentAttributes)
                let skill1Rect = skill1String.boundingRect(with: CGSize(width: columnWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                var skill2String: NSAttributedString? = nil
                var skill2Rect: CGRect? = nil
                if i + 1 < content.count {
                    let skill2 = "• " + content[i + 1]
                    skill2String = NSAttributedString(string: skill2, attributes: contentAttributes)
                    skill2Rect = skill2String?.boundingRect(with: CGSize(width: columnWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                }
                
                let pairHeight = max(skill1Rect.height, skill2Rect?.height ?? 0)
                
                if currentY + pairHeight > pageRect.height - margin {
                    context.beginPage()
                    currentY = margin
                }
                
                skill1String.draw(in: CGRect(x: leftX, y: currentY, width: columnWidth, height: skill1Rect.height))
                skill2String?.draw(in: CGRect(x: rightX, y: currentY, width: columnWidth, height: skill2Rect?.height ?? 0))
                
                currentY += pairHeight + 5 // Space between pairs
            }
        } else {
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
        let projectTitleFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
        let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
        
        let titleString = NSAttributedString(string: title, attributes: titleAttributes)
        let titleSize = titleString.size()
        
        var currentY = yOffset
        
        // Check if there's enough space for the title and at least one project
        if currentY + titleSize.height + 50 > pageRect.height - 72 {
            context.beginPage()
            currentY = 36
        }
        
        titleString.draw(at: CGPoint(x: 36, y: currentY))
        currentY += titleSize.height + 15
        
        for project in projects {
            let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
            let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
            
            let projectTitleSize = projectTitleString.size()
            let detailsRect = detailsString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            let totalProjectHeight = projectTitleSize.height + detailsRect.height + 20 // 20 for padding
            
            // Check if there's enough space for the entire project
            if currentY + totalProjectHeight > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            projectTitleString.draw(at: CGPoint(x: 36, y: currentY))
            currentY += projectTitleSize.height + 5
            
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
        let detailsString = NSAttributedString(string: "\(info.email) | \(info.phoneNumber) | \(info.address)\n \(info.website ?? "")", attributes: detailsAttributes)

        
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
