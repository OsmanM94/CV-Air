
import SwiftUI

enum PDFGenerationError: Error {
    case cancelled
    case failedToGeneratePDF
}

struct CVPDFGenerator {
    static func generatePDF(for cv: CV) async -> Data {
           await withCheckedContinuation { continuation in
               DispatchQueue.global(qos: .userInitiated).async {
                   let pdfMetaData = [
                       kCGPDFContextCreator: "CV",
                       kCGPDFContextAuthor: cv.personalInfo.name
                   ]
                   let format = UIGraphicsPDFRendererFormat()
                   format.documentInfo = pdfMetaData as [String: Any]
                   
                   let pageWidth = 8.5 * 72.0
                   let pageHeight = 11 * 72.0
                   let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
                   
                   let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
                   
                   let data = renderer.pdfData { context in
                       var currentYOffset: CGFloat = 0
                       
                       context.beginPage()
                       
                       currentYOffset = addTitle(cv.personalInfo.name, pageRect: pageRect)
                       currentYOffset = addPersonalInfo(cv.personalInfo, pageRect: pageRect, yOffset: currentYOffset)
                       
                       if !cv.summary.isEmpty {
                           currentYOffset = addSection(title: "Summary", content: [cv.summary], pageRect: pageRect, yOffset: currentYOffset, context: context)
                       }
                       
                       if !cv.professionalHistory.isEmpty {
                           currentYOffset = addHistorySection(title: "Professional History", history: cv.professionalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context)
                       }
                       
                       if !cv.educationalHistory.isEmpty {
                           currentYOffset = addHistorySection(title: "Educational History", history: cv.educationalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context)
                       }
                       
                       if !cv.projects.isEmpty {
                           currentYOffset = addProjects(cv.projects, pageRect: pageRect, yOffset: currentYOffset, context: context)
                       }
                       
                       if !cv.skills.isEmpty {
                           currentYOffset = addSection(title: "Skills", content: [cv.skills.joined(separator: " • ")], pageRect: pageRect, yOffset: currentYOffset, context: context)
                       }
                   }
                   
                   continuation.resume(returning: data)
               }
           }
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
        
        // Address and phone number
        let firstLineString = "\(info.address) • \(info.phoneNumber)"
        let firstLineAttributed = NSAttributedString(string: firstLineString, attributes: attributes)
        let firstLineRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
        firstLineAttributed.draw(in: firstLineRect)
        yPosition += 20
        
        // Email
        let emailString = "\(info.email)"
        let emailAttributed = NSAttributedString(string: emailString, attributes: attributes)
        let emailRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
        emailAttributed.draw(in: emailRect)
        yPosition += 20
        
        // Website (if provided)
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
        
        // Add a little extra space before the Skills section
        if title == "Skills" {
            yPosition += 10  // Adjust this value to increase or decrease the spacing
        }
        
        // Check if there's enough space for the title and at least some content
        if yPosition + titleSize.height + 30 > pageRect.height - 72 {
            context.beginPage()
            yPosition = 36
        }
        
        // Draw the title
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
            
            // Check if there's enough space for the title and at least one entry
            if yPosition + titleSize.height + 60 > pageRect.height - 72 {
                context.beginPage()
                yPosition = 36
            }
            
            // Draw the title
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
        
        // Check if there's enough space for the title and at least one project
        if yPosition + titleSize.height + 60 > pageRect.height - 72 {
            context.beginPage()
            yPosition = 36
        }
        
        // Draw the title
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
            let attributedDetails = NSAttributedString(string:  project.details, attributes: detailsAttributes)
            let detailsSize = attributedDetails.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            let detailsRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: detailsSize.height)
            attributedDetails.draw(in: detailsRect)
            yPosition += detailsSize.height + 10
        }
        
        return yPosition
    }
    
    private static func formatYearRange(start: Int, end: Int?) -> String {
        if let end = end {
            return "\(start) - \(end)"
        } else {
            return "\(start) - Present"
        }
    }
}
