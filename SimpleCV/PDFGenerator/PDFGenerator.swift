
import SwiftUI

enum CVFontSize {
    case small
    case medium
    case large
    
    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.7
        case .medium: return 1.0
        case .large: return 1.1
        }
    }
}

enum CVSpacing {
    case compact
    case normal
    case relaxed
    
    var scaleFactor: CGFloat {
        switch self {
        case .compact: return 0.8
        case .normal: return 1.0
        case .relaxed: return 1.2
        }
    }
}

protocol CVTemplate {
    static func generatePDF(for cv: CV, fontSize: CVFontSize, spacing: CVSpacing) async -> Data
}

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

struct OriginalTemplate: CVTemplate {
    static func generatePDF(for cv: CV, fontSize: CVFontSize, spacing: CVSpacing) async -> Data {
            await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let renderer = createPDFRenderer(for: cv)
                    
                    let data = renderer.pdfData { context in
                        var currentYOffset: CGFloat = 0
                        
                        context.beginPage()
                        
                        currentYOffset = addTitle(cv.personalInfo.name, pageRect: context.pdfContextBounds, fontSize: fontSize)
                        currentYOffset = addPersonalInfo(cv.personalInfo, pageRect: context.pdfContextBounds, yOffset: currentYOffset, fontSize: fontSize, spacing: spacing)
                        
                        if !cv.summary.isEmpty {
                            currentYOffset = addSection(title: "Summary", content: [cv.summary], pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                        }
                        
                        if !cv.professionalHistory.isEmpty {
                            currentYOffset = addHistorySection(title: "Professional History", history: cv.professionalHistory, pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                        }
                        
                        if !cv.educationalHistory.isEmpty {
                            currentYOffset = addHistorySection(title: "Educational History", history: cv.educationalHistory, pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                        }
                        
                        if !cv.projects.isEmpty {
                            currentYOffset = addProjects(title: "Projects", projects: cv.projects, pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                        }
                        
                        if !cv.skills.isEmpty {
                            currentYOffset = addSection(title: "Skills", content: [cv.skills.joined(separator: " • ")], pageRect: context.pdfContextBounds, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
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
        
        let pageWidth = 595.0  // 210 mm in points (72 points per inch)
        let pageHeight = 842.0 // 297 mm in points (72 points per inch)
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        return UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    }
    
    private static func addTitle(_ title: String, pageRect: CGRect, fontSize: CVFontSize) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 24.0 * fontSize.scaleFactor, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
            let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
            let titleStringSize = attributedTitle.size()
            let titleStringRect = CGRect(x: 36, y: 36, width: pageRect.width - 72, height: titleStringSize.height)
            attributedTitle.draw(in: titleStringRect)
            return titleStringRect.origin.y + titleStringSize.height + 10
        }
    
    private static func addPersonalInfo(_ info: PersonalInfo, pageRect: CGRect, yOffset: CGFloat, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let font = UIFont.systemFont(ofSize: 12.0 * fontSize.scaleFactor, weight: .regular)
            let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
            var yPosition = yOffset
            
            let firstLineString = "\(info.address) • \(info.phoneNumber)"
            let firstLineAttributed = NSAttributedString(string: firstLineString, attributes: attributes)
            let firstLineRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
            firstLineAttributed.draw(in: firstLineRect)
            yPosition += 20 * spacing.scaleFactor
            
            let emailString = "\(info.email)"
            let emailAttributed = NSAttributedString(string: emailString, attributes: attributes)
            let emailRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
            emailAttributed.draw(in: emailRect)
            yPosition += 20 * spacing.scaleFactor
            
            if let website = info.website, !website.isEmpty {
                let websiteString = "Website: \(website)"
                let websiteAttributed = NSAttributedString(string: websiteString, attributes: attributes)
                let websiteRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
                websiteAttributed.draw(in: websiteRect)
                yPosition += 20 * spacing.scaleFactor
            }
            
            return yPosition + (10 * spacing.scaleFactor)
        }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 16.0 * fontSize.scaleFactor, weight: .bold)
            let contentFont = UIFont.systemFont(ofSize: 12.0 * fontSize.scaleFactor, weight: .regular)
            
            let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
            let contentAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: contentFont]
            
            let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
            let titleSize = attributedTitle.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            var yPosition = yOffset + (5 * spacing.scaleFactor)
            
            if yPosition + titleSize.height + 30 > pageRect.height - 72 {
                context.beginPage()
                yPosition = 36
            }
            
            let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: titleSize.height)
            attributedTitle.draw(in: titleRect)
            yPosition += titleSize.height + (10 * spacing.scaleFactor)
            
            for line in content {
                let attributedContent = NSAttributedString(string: line, attributes: contentAttributes)
                let contentSize = attributedContent.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                if yPosition + contentSize.height > pageRect.height - 72 {
                    context.beginPage()
                    yPosition = 36
                }
                
                let contentRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: contentSize.height)
                attributedContent.draw(in: contentRect)
                yPosition += contentSize.height + (5 * spacing.scaleFactor)
            }
            
            return yPosition + (10 * spacing.scaleFactor)
        }
    
    private static func addHistorySection(title: String, history: [HistoryEntry], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 16.0 * fontSize.scaleFactor, weight: .bold)
            let entryTitleFont = UIFont.systemFont(ofSize: 14.0 * fontSize.scaleFactor, weight: .semibold)
            let detailsFont = UIFont.systemFont(ofSize: 12.0 * fontSize.scaleFactor, weight: .regular)
            
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
            yPosition += titleSize.height + (10 * spacing.scaleFactor)
            
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
                
                yPosition += entryTitleSize.height + dateSize.height + (10 * spacing.scaleFactor)
                
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
                    yPosition += bulletSize.height + (5 * spacing.scaleFactor)
                }
                
                yPosition += 10 * spacing.scaleFactor
            }
            
            return yPosition
        }
    
    private static func addProjects(title: String, projects: [Project], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 16.0 * fontSize.scaleFactor, weight: .bold)
            let projectTitleFont = UIFont.systemFont(ofSize: 14.0 * fontSize.scaleFactor, weight: .semibold)
            let detailsFont = UIFont.systemFont(ofSize: 12.0 * fontSize.scaleFactor, weight: .regular)
            
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
            let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
            
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            let titleSize = titleString.size()
            
            var currentY = yOffset
            
            if currentY + titleSize.height + 50 > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            titleString.draw(at: CGPoint(x: 36, y: currentY))
            currentY += titleSize.height + (15 * spacing.scaleFactor)
            
            for project in projects {
                let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
                let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
                
                let projectTitleSize = projectTitleString.size()
                let detailsRect = detailsString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                let totalProjectHeight = projectTitleSize.height + detailsRect.height + (20 * spacing.scaleFactor)
                
                if currentY + totalProjectHeight > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                projectTitleString.draw(at: CGPoint(x: 36, y: currentY))
                currentY += projectTitleSize.height + (5 * spacing.scaleFactor)
                
                detailsString.draw(in: CGRect(x: 36, y: currentY, width: pageRect.width - 72, height: detailsRect.height))
                currentY += detailsRect.height + (15 * spacing.scaleFactor)
            }
            
            return currentY
        }
}

struct ModernMinimalistTemplate: CVTemplate {
    static func generatePDF(for cv: CV, fontSize: CVFontSize, spacing: CVSpacing) async -> Data {
           await withCheckedContinuation { continuation in
               DispatchQueue.global(qos: .userInitiated).async {
                   let renderer = createPDFRenderer(for: cv)
                   
                   let data = renderer.pdfData { context in
                       let pageRect = context.pdfContextBounds
                       var currentYOffset: CGFloat = 0
                       
                       context.beginPage()
                       
                       currentYOffset = addHeader(cv.personalInfo, pageRect: pageRect, fontSize: fontSize)
                       
                       let leftColumnWidth: CGFloat = pageRect.width * 0.35
                       let rightColumnWidth: CGFloat = pageRect.width * 0.55
                       let leftColumnXOffset: CGFloat = 36
                       let rightColumnXOffset: CGFloat = leftColumnXOffset + leftColumnWidth + 20
                       
                       // Left column (Skills and Education first)
                       var leftColumnYOffset = currentYOffset
                       leftColumnYOffset = addSection(title: "Skills", content: cv.skills, pageRect: pageRect, yOffset: leftColumnYOffset, width: leftColumnWidth, xOffset: leftColumnXOffset, context: context, fontSize: fontSize, spacing: spacing)
                       leftColumnYOffset = addHistorySection(title: "Education", history: cv.educationalHistory, pageRect: pageRect, yOffset: leftColumnYOffset, width: leftColumnWidth, xOffset: leftColumnXOffset, context: context, fontSize: fontSize, spacing: spacing)
                       
                       // Right column (Summary, Experience, and Projects)
                       var rightColumnYOffset = currentYOffset
                       rightColumnYOffset = addSection(title: "Summary", content: [cv.summary], pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset, context: context, fontSize: fontSize, spacing: spacing)
                       rightColumnYOffset = addHistorySection(title: "Professional Experience", history: cv.professionalHistory, pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset, context: context, fontSize: fontSize, spacing: spacing)
                       rightColumnYOffset = addProjects(cv.projects, pageRect: pageRect, yOffset: rightColumnYOffset, width: rightColumnWidth, xOffset: rightColumnXOffset, context: context, fontSize: fontSize, spacing: spacing)
                   }
                   
                   continuation.resume(returning: data)
               }
           }
       }

    private static func addProjects(_ projects: [Project], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
           let titleFont = UIFont.systemFont(ofSize: 14 * fontSize.scaleFactor, weight: .bold)
           let projectTitleFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .semibold)
           let detailsFont = UIFont.systemFont(ofSize: 10 * fontSize.scaleFactor, weight: .regular)
           
           let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
           let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
           let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
           
           var currentY = yOffset
           
           if currentY + 20 > pageRect.height - 72 {
               context.beginPage()
               currentY = 36
           }
           
           let titleString = NSAttributedString(string: "Projects", attributes: titleAttributes)
           titleString.draw(at: CGPoint(x: xOffset, y: currentY))
           
           currentY += 20 * spacing.scaleFactor
           
           for (index, project) in projects.enumerated() {
               let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
               let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
               
               let titleRect = projectTitleString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
               let detailsRect = detailsString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
               
               let requiredHeight = titleRect.height + detailsRect.height + 15 * spacing.scaleFactor
               
               let totalRemainingHeight: CGFloat = projects[index...].reduce(0) { result, project in
                   let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
                   let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
                   
                   let titleRect = projectTitleString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                   let detailsRect = detailsString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                   
                   return result + titleRect.height + detailsRect.height + 15 * spacing.scaleFactor
               }
               
               if currentY + totalRemainingHeight <= pageRect.height - 72 {
                   projectTitleString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: titleRect.height))
                   currentY += titleRect.height + 5 * spacing.scaleFactor
                   
                   detailsString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: detailsRect.height))
                   currentY += detailsRect.height + 15 * spacing.scaleFactor
               } else {
                   if currentY + requiredHeight > pageRect.height - 72 {
                       context.beginPage()
                       currentY = 36
                   }
                   
                   projectTitleString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: titleRect.height))
                   currentY += titleRect.height + 5 * spacing.scaleFactor
                   
                   detailsString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: detailsRect.height))
                   currentY += detailsRect.height + 15 * spacing.scaleFactor
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
    
    private static func addHeader(_ info: PersonalInfo, pageRect: CGRect, fontSize: CVFontSize) -> CGFloat {
          let nameFont = UIFont.systemFont(ofSize: 24 * fontSize.scaleFactor, weight: .bold)
          let detailsFont = UIFont.systemFont(ofSize: 10 * fontSize.scaleFactor, weight: .regular)
          
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
          
          emailString.draw(at: CGPoint(x: 36, y: currentY))
          currentY += emailString.size().height + 5
          
          let addressRect = addressString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
          addressString.draw(in: CGRect(x: 36, y: currentY, width: pageRect.width - 72, height: addressRect.height))
          currentY += addressRect.height + 5
          
          phoneString.draw(at: CGPoint(x: 36, y: currentY))
          currentY += phoneString.size().height + 5
          
          if let website = info.website, !website.isEmpty {
              let websiteString = NSAttributedString(string: "\(website)", attributes: detailsAttributes)
              websiteString.draw(at: CGPoint(x: 36, y: currentY))
              currentY += websiteString.size().height + 5
          }
          
          return currentY + 10
      }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
           let titleFont = UIFont.systemFont(ofSize: 14 * fontSize.scaleFactor, weight: .bold)
           let contentFont = UIFont.systemFont(ofSize: 10 * fontSize.scaleFactor, weight: .regular)

           let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
           let contentAttributes: [NSAttributedString.Key: Any] = [.font: contentFont]

           var currentY = yOffset

           if currentY + 20 > pageRect.height - 72 {
               context.beginPage()
               currentY = 36
           }

           let titleString = NSAttributedString(string: title, attributes: titleAttributes)
           titleString.draw(at: CGPoint(x: xOffset, y: currentY))

           currentY += 20 * spacing.scaleFactor

           for item in content {
               let itemString = NSAttributedString(string: "• \(item)", attributes: contentAttributes)
               let itemRect = itemString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)

               if currentY + itemRect.height > pageRect.height - 72 {
                   context.beginPage()
                   currentY = 36
               }

               itemString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: itemRect.height))
               currentY += itemRect.height + 5 * spacing.scaleFactor
           }

           return currentY + 10 * spacing.scaleFactor
       }
    
    private static func addHistorySection(title: String, history: [HistoryEntry], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 14 * fontSize.scaleFactor, weight: .bold)
            let entryTitleFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .semibold)
            let detailsFont = UIFont.systemFont(ofSize: 10 * fontSize.scaleFactor, weight: .regular)
            
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let entryTitleAttributes: [NSAttributedString.Key: Any] = [.font: entryTitleFont]
            let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
            
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: xOffset, y: yOffset))
            
            var currentY = yOffset + 20 * spacing.scaleFactor
            
            for entry in history {
                let entryTitleText = "\(entry.title), \(entry.subtitle)"
                let dateText = formatYearRange(start: entry.startYear, end: entry.endYear)
                
                let entryTitleString = NSAttributedString(string: entryTitleText, attributes: entryTitleAttributes)
                let dateString = NSAttributedString(string: dateText, attributes: detailsAttributes)
                
                let titleRect = entryTitleString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                entryTitleString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: titleRect.height))
                currentY += titleRect.height + 5 * spacing.scaleFactor
                
                dateString.draw(at: CGPoint(x: xOffset, y: currentY))
                currentY += 15 * spacing.scaleFactor
                
                for detail in entry.details {
                    let detailString = NSAttributedString(string: "• \(detail)", attributes: detailsAttributes)
                    let detailRect = detailString.boundingRect(with: CGSize(width: width - 20, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                    
                    if currentY + detailRect.height > pageRect.height - 72 {
                        context.beginPage()
                        currentY = 36
                    }
                    
                    detailString.draw(in: CGRect(x: xOffset + 10, y: currentY, width: width - 20, height: detailRect.height))
                    currentY += detailRect.height + 5 * spacing.scaleFactor
                }
                
                currentY += 10 * spacing.scaleFactor
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
    static func generatePDF(for cv: CV, fontSize: CVFontSize, spacing: CVSpacing) async -> Data {
           await withCheckedContinuation { continuation in
               DispatchQueue.global(qos: .userInitiated).async {
                   let renderer = createPDFRenderer(for: cv)
                   
                   let data = renderer.pdfData { context in
                       let pageRect = context.pdfContextBounds
                       var currentYOffset: CGFloat = 0
                       
                       context.beginPage()
                       
                       currentYOffset = addCenteredName(cv.personalInfo.name, pageRect: pageRect, fontSize: fontSize)
                       currentYOffset = addContactInfo(cv.personalInfo, pageRect: pageRect, yOffset: currentYOffset, fontSize: fontSize, spacing: spacing)
                       
                       currentYOffset = addSection(title: "SUMMARY", content: [cv.summary], pageRect: pageRect, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                       currentYOffset = addHistorySection(title: "PROFESSIONAL EXPERIENCE", history: cv.professionalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                       currentYOffset = addHistorySection(title: "EDUCATION", history: cv.educationalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                       currentYOffset = addProjects(title: "PROJECTS", projects: cv.projects, pageRect: pageRect, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                       currentYOffset = addSection(title: "SKILLS", content: cv.skills, pageRect: pageRect, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
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
    
    private static func addCenteredName(_ name: String, pageRect: CGRect, fontSize: CVFontSize) -> CGFloat {
            let nameFont = UIFont.systemFont(ofSize: 24 * fontSize.scaleFactor, weight: .bold)
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
    
    private static func addContactInfo(_ info: PersonalInfo, pageRect: CGRect, yOffset: CGFloat, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let font = UIFont.systemFont(ofSize: 10 * fontSize.scaleFactor, weight: .regular)
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
                
                currentY += 5 * spacing.scaleFactor
                websiteString.draw(at: CGPoint(x: websiteX, y: currentY))
                currentY += websiteSize.height
            }
            
            return currentY + 20 * spacing.scaleFactor
        }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 14 * fontSize.scaleFactor, weight: .bold)
            let contentFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .regular)
            
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let contentAttributes: [NSAttributedString.Key: Any] = [.font: contentFont]
            
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 36, y: yOffset))
            
            var currentY = yOffset + 25 * spacing.scaleFactor
            
            if title == "SKILLS" {
                let margin: CGFloat = 36
                let columnSpacing: CGFloat = 5 * spacing.scaleFactor
                let totalWidth = pageRect.width - (2 * margin)
                let columnWidth = (totalWidth - columnSpacing) / 3
                
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
                    
                    currentY += pairHeight + 5 * spacing.scaleFactor
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
                    currentY += itemRect.height + 10 * spacing.scaleFactor
                }
            }
            
            return currentY + 10 * spacing.scaleFactor
        }
            
    private static func addHistorySection(title: String, history: [HistoryEntry], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
           let titleFont = UIFont.systemFont(ofSize: 14 * fontSize.scaleFactor, weight: .bold)
           let entryTitleFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .semibold)
           let detailsFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .regular)
           
           let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
           let entryTitleAttributes: [NSAttributedString.Key: Any] = [.font: entryTitleFont]
           let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
           
           let titleString = NSAttributedString(string: title, attributes: titleAttributes)
           titleString.draw(at: CGPoint(x: 36, y: yOffset))
           
           var currentY = yOffset + 25 * spacing.scaleFactor
           
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
               
               currentY += 20 * spacing.scaleFactor
               
               for detail in entry.details {
                   let detailString = NSAttributedString(string: "• \(detail)", attributes: detailsAttributes)
                   let detailRect = detailString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                   
                   if currentY + detailRect.height > pageRect.height - 72 {
                       context.beginPage()
                       currentY = 36
                   }
                   
                   detailString.draw(in: CGRect(x: 46, y: currentY, width: pageRect.width - 82, height: detailRect.height))
                   currentY += detailRect.height + 5 * spacing.scaleFactor
               }
               
               currentY += 15 * spacing.scaleFactor
           }
           
           return currentY
       }
    
    private static func addProjects(title: String, projects: [Project], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 14 * fontSize.scaleFactor, weight: .bold)
            let projectTitleFont = UIFont.systemFont(ofSize: 14 * fontSize.scaleFactor, weight: .semibold)
            let detailsFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .regular)
            
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
            let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
            
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            let titleSize = titleString.size()
            
            var currentY = yOffset
            
            if currentY + titleSize.height + 50 > pageRect.height - 72 {
                context.beginPage()
                currentY = 36
            }
            
            titleString.draw(at: CGPoint(x: 36, y: currentY))
            currentY += titleSize.height + 15 * spacing.scaleFactor
            
            for project in projects {
                let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
                let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
                
                let projectTitleSize = projectTitleString.size()
                let detailsRect = detailsString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                let totalProjectHeight = projectTitleSize.height + detailsRect.height + 20 * spacing.scaleFactor
                
                if currentY + totalProjectHeight > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                projectTitleString.draw(at: CGPoint(x: 36, y: currentY))
                currentY += projectTitleSize.height + 5 * spacing.scaleFactor
                
                detailsString.draw(in: CGRect(x: 36, y: currentY, width: pageRect.width - 72, height: detailsRect.height))
                currentY += detailsRect.height + 15 * spacing.scaleFactor
            }
            
            return currentY
        }
}

struct CompactEfficientTemplate: CVTemplate {
    static func generatePDF(for cv: CV, fontSize: CVFontSize, spacing: CVSpacing) async -> Data {
            await withCheckedContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    let renderer = createPDFRenderer(for: cv)
                    
                    let data = renderer.pdfData { context in
                        let pageRect = context.pdfContextBounds
                        var currentYOffset: CGFloat = 0
                        
                        context.beginPage()
                        
                        currentYOffset = addCompactHeader(cv.personalInfo, pageRect: pageRect, fontSize: fontSize)
                        
                        currentYOffset = addSection(title: "Summary", content: [cv.summary], pageRect: pageRect, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                        currentYOffset = addHistorySection(title: "Experience", history: cv.professionalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                        currentYOffset = addHistorySection(title: "Education", history: cv.educationalHistory, pageRect: pageRect, yOffset: currentYOffset, context: context, fontSize: fontSize, spacing: spacing)
                        
                        let columnWidth = (pageRect.width - 72) / 2
                        var leftColumnYOffset = currentYOffset
                        var rightColumnYOffset = currentYOffset
                        
                        leftColumnYOffset = addSection(title: "Skills", content: cv.skills, pageRect: pageRect, yOffset: leftColumnYOffset, context: context, fontSize: fontSize, spacing: spacing, width: columnWidth, xOffset: 36)
                        rightColumnYOffset = addProjects(cv.projects, pageRect: pageRect, yOffset: rightColumnYOffset, width: columnWidth, xOffset: columnWidth + 46, context: context, fontSize: fontSize, spacing: spacing)
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
    
    private static func addCompactHeader(_ info: PersonalInfo, pageRect: CGRect, fontSize: CVFontSize) -> CGFloat {
            let nameFont = UIFont.systemFont(ofSize: 18 * fontSize.scaleFactor, weight: .bold)
            let detailsFont = UIFont.systemFont(ofSize: 9 * fontSize.scaleFactor, weight: .regular)
            
            let nameAttributes: [NSAttributedString.Key: Any] = [.font: nameFont]
            let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
            
            let nameString = NSAttributedString(string: info.name, attributes: nameAttributes)
            let detailsString = NSAttributedString(string: "\(info.email) | \(info.phoneNumber) | \(info.address)\n \(info.website ?? "")", attributes: detailsAttributes)

            nameString.draw(at: CGPoint(x: 36, y: 36))
            
            let nameBounds = nameString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
            
            detailsString.draw(at: CGPoint(x: 36, y: 36 + nameBounds.height + 2))
            
            return 36 + nameBounds.height + detailsString.size().height + 10
        }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing, width: CGFloat? = nil, xOffset: CGFloat = 36) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .bold)
            let contentFont = UIFont.systemFont(ofSize: 10 * fontSize.scaleFactor, weight: .regular)
            
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let contentAttributes: [NSAttributedString.Key: Any] = [.font: contentFont]
            
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: xOffset, y: yOffset))
            
            var currentY = yOffset + (15 * spacing.scaleFactor)
            
            for item in content {
                let itemString = NSAttributedString(string: "• \(item)", attributes: contentAttributes)
                let itemRect = itemString.boundingRect(with: CGSize(width: width ?? (pageRect.width - 72), height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                if currentY + itemRect.height > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                itemString.draw(in: CGRect(x: xOffset, y: currentY, width: width ?? (pageRect.width - 72), height: itemRect.height))
                currentY += itemRect.height + (2 * spacing.scaleFactor)
            }
            
            return currentY + (5 * spacing.scaleFactor)
        }
        
        private static func addHistorySection(title: String, history: [HistoryEntry], pageRect: CGRect, yOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .bold)
            let entryTitleFont = UIFont.systemFont(ofSize: 11 * fontSize.scaleFactor, weight: .semibold)
            let detailsFont = UIFont.systemFont(ofSize: 10 * fontSize.scaleFactor, weight: .regular)
            
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let entryTitleAttributes: [NSAttributedString.Key: Any] = [.font: entryTitleFont]
            let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
            
            let titleString = NSAttributedString(string: title, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 36, y: yOffset))
            
            var currentY = yOffset + (15 * spacing.scaleFactor)
            
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
                
                currentY += 15 * spacing.scaleFactor
                
                for detail in entry.details {
                    let detailString = NSAttributedString(string: "• \(detail)", attributes: detailsAttributes)
                    let detailRect = detailString.boundingRect(with: CGSize(width: pageRect.width - 72, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                    
                    if currentY + detailRect.height > pageRect.height - 72 {
                        context.beginPage()
                        currentY = 36
                    }
                    
                    detailString.draw(in: CGRect(x: 46, y: currentY, width: pageRect.width - 82, height: detailRect.height))
                    currentY += detailRect.height + (2 * spacing.scaleFactor)
                }
                
                currentY += 5 * spacing.scaleFactor
            }
            
            return currentY
        }
        
        private static func addProjects(_ projects: [Project], pageRect: CGRect, yOffset: CGFloat, width: CGFloat, xOffset: CGFloat, context: UIGraphicsPDFRendererContext, fontSize: CVFontSize, spacing: CVSpacing) -> CGFloat {
            let titleFont = UIFont.systemFont(ofSize: 12 * fontSize.scaleFactor, weight: .bold)
            let projectTitleFont = UIFont.systemFont(ofSize: 11 * fontSize.scaleFactor, weight: .semibold)
            let detailsFont = UIFont.systemFont(ofSize: 10 * fontSize.scaleFactor, weight: .regular)
            
            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let projectTitleAttributes: [NSAttributedString.Key: Any] = [.font: projectTitleFont]
            let detailsAttributes: [NSAttributedString.Key: Any] = [.font: detailsFont]
            
            let titleString = NSAttributedString(string: "Projects", attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: xOffset, y: yOffset))
            
            var currentY = yOffset + (15 * spacing.scaleFactor)
            
            for project in projects {
                let projectTitleString = NSAttributedString(string: project.title, attributes: projectTitleAttributes)
                let detailsString = NSAttributedString(string: project.details, attributes: detailsAttributes)
                
                if currentY + 30 > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                projectTitleString.draw(at: CGPoint(x: xOffset, y: currentY))
                currentY += 15 * spacing.scaleFactor
                
                let detailsRect = detailsString.boundingRect(with: CGSize(width: width - 10, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                
                if currentY + detailsRect.height > pageRect.height - 72 {
                    context.beginPage()
                    currentY = 36
                }
                
                detailsString.draw(in: CGRect(x: xOffset, y: currentY, width: width - 10, height: detailsRect.height))
                currentY += detailsRect.height + (5 * spacing.scaleFactor)
            }
            
            return currentY
        }
}
