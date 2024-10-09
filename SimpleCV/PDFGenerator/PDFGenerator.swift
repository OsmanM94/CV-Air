//
//  PDFGenerator.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

enum PDFGenerationError: Error {
    case cancelled
    case failedToGeneratePDF
}

//struct CVPDFGenerator {
//    static func generatePDF(for cv: CV) async -> Data {
//        await withCheckedContinuation { continuation in
//            DispatchQueue.global(qos: .userInitiated).async {
//                // PDF Metadata
//                let pdfMetaData = [
//                    kCGPDFContextCreator: "CV",
//                    kCGPDFContextAuthor: cv.personalInfo.name
//                ]
//                let format = UIGraphicsPDFRendererFormat()
//                format.documentInfo = pdfMetaData as [String: Any]
//                
//                // Page dimensions (A4 size)
//                let pageWidth = 8.5 * 72.0
//                let pageHeight = 11 * 72.0
//                let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
//                
//                let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
//                
//                let data = renderer.pdfData { context in
//                    context.beginPage()
//                    
//                    // Add the title (Name)
//                    let titleBottom = addTitle(cv.personalInfo.name, pageRect: pageRect)
//                    var currentYOffset = titleBottom + 10
//                    
//                    // Add Personal Information section
//                    currentYOffset = addSection(
//                        title: "Personal Information",
//                        content: [
//                            cv.personalInfo.address,
//                            cv.personalInfo.phoneNumber,
//                            cv.personalInfo.email
//                        ],
//                        pageRect: pageRect,
//                        yOffset: currentYOffset
//                    )
//                    
//                    // Add Summary section
//                    if !cv.summary.isEmpty {
//                        currentYOffset = addSection(
//                            title: "Summary",
//                            content: [cv.summary],
//                            pageRect: pageRect,
//                            yOffset: currentYOffset
//                        )
//                    }
//                    
//                    // Add Professional History section
//                    if !cv.professionalHistory.isEmpty {
//                        var historyContent = [String]()
//                        for experience in cv.professionalHistory {
//                            historyContent.append(experience.company)
//                            historyContent.append("\(experience.position) (\(formatYearRange(start: experience.startYear, end: experience.endYear)))")
//                            historyContent.append(contentsOf: experience.responsibilities)
//                        }
//                        currentYOffset = addSection(
//                            title: "Professional History",
//                            content: historyContent,
//                            pageRect: pageRect,
//                            yOffset: currentYOffset
//                        )
//                    }
//                    
//                    // Add Educational History section
//                    if !cv.educationalHistory.isEmpty {
//                        var educationContent = [String]()
//                        for education in cv.educationalHistory {
//                            educationContent.append(education.institution)
//                            educationContent.append("\(education.degree) (\(formatYearRange(start: education.startYear, end: education.endYear)))")
//                            educationContent.append(education.details)
//                        }
//                        currentYOffset = addSection(
//                            title: "Educational History",
//                            content: educationContent,
//                            pageRect: pageRect,
//                            yOffset: currentYOffset
//                        )
//                    }
//                    
//                    // Add Skills section
//                    if !cv.skills.isEmpty {
//                        _ = addSection(
//                            title: "Skills",
//                            content: cv.skills,
//                            pageRect: pageRect,
//                            yOffset: currentYOffset
//                        )
//                    }
//                }
//                
//                continuation.resume(returning: data)
//            }
//        }
//    }
//    
//    private static func addTitle(_ title: String, pageRect: CGRect) -> CGFloat {
//        let titleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
//        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
//        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
//        let titleStringSize = attributedTitle.size()
//        let titleStringRect = CGRect(x: (pageRect.width - titleStringSize.width) / 2.0,
//                                     y: 36,
//                                     width: titleStringSize.width,
//                                     height: titleStringSize.height)
//        attributedTitle.draw(in: titleStringRect)
//        return titleStringRect.origin.y + titleStringRect.size.height
//    }
//    
//    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
//        let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
//        let contentFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
//        
//        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
//        let contentAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: contentFont]
//        
//        var yPosition = yOffset
//        
//        // Draw the section title
//        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
//        let titleSize = attributedTitle.size()
//        let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: titleSize.height)
//        attributedTitle.draw(in: titleRect)
//        yPosition += titleRect.height + 5
//        
//        // Draw the section content
//        for line in content {
//            let attributedContent = NSAttributedString(string: line, attributes: contentAttributes)
//            let contentSize = attributedContent.size()
//            let contentRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: contentSize.height)
//            attributedContent.draw(in: contentRect)
//            yPosition += contentRect.height + 5
//        }
//        
//        return yPosition
//    }
//}

struct CVPDFGenerator {
    static func generatePDF(for cv: CV) async -> Data {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                // PDF Metadata
                let pdfMetaData = [
                    kCGPDFContextCreator: "CV",
                    kCGPDFContextAuthor: cv.personalInfo.name
                ]
                let format = UIGraphicsPDFRendererFormat()
                format.documentInfo = pdfMetaData as [String: Any]
                
                // Page dimensions (A4 size)
                let pageWidth = 8.5 * 72.0
                let pageHeight = 11 * 72.0
                let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
                
                let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
                
                let data = renderer.pdfData { context in
                    context.beginPage()
                    
                    // Add the title (Name)
                    var currentYOffset = addTitle(cv.personalInfo.name, pageRect: pageRect)
                    
                    // Add Personal Information section
                    currentYOffset = addPersonalInfo(cv.personalInfo, pageRect: pageRect, yOffset: currentYOffset)
                    
                    // Add Summary section
                    if !cv.summary.isEmpty {
                        currentYOffset = addSection(
                            title: "Summary",
                            content: [cv.summary],
                            pageRect: pageRect,
                            yOffset: currentYOffset
                        )
                    }
                    
                    // Add Professional History section
                    if !cv.professionalHistory.isEmpty {
                        currentYOffset = addProfessionalHistory(cv.professionalHistory, pageRect: pageRect, yOffset: currentYOffset)
                    }
                    
                    // Add Educational History section
                    if !cv.educationalHistory.isEmpty {
                        currentYOffset = addEducationalHistory(cv.educationalHistory, pageRect: pageRect, yOffset: currentYOffset)
                    }
                    
                    // Add Projects section
                    if let projects = cv.projects, !projects.isEmpty {
                        currentYOffset = addProjects(projects, pageRect: pageRect, yOffset: currentYOffset)
                    }
                    
                    // Add Skills section
                    if !cv.skills.isEmpty {
                        _ = addSection(
                            title: "Skills",
                            content: [cv.skills.joined(separator: " • ")],
                            pageRect: pageRect,
                            yOffset: currentYOffset
                        )
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
        let titleStringRect = CGRect(x: 36,
                                     y: 36,
                                     width: pageRect.width - 72,
                                     height: titleStringSize.height)
        attributedTitle.draw(in: titleStringRect)
        return titleStringRect.origin.y + titleStringSize.height + 10
    }
    
//    private static func addPersonalInfo(_ info: PersonalInfo, pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
//        let font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
//        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
//        let yPosition = yOffset
//        
//        let infoString = "\(info.address) • \(info.phoneNumber) • \(info.email) • \(info.website ?? "")"
//        let attributedInfo = NSAttributedString(string: infoString, attributes: attributes)
//        let infoRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
//        attributedInfo.draw(in: infoRect)
//        
//        return yPosition + 30
//    }
    
    private static func addPersonalInfo(_ info: PersonalInfo, pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        var yPosition = yOffset
        
        // First line: address, phone, email
        let firstLineString = "\(info.address) • \(info.phoneNumber) • \(info.email)"
        let firstLineAttributed = NSAttributedString(string: firstLineString, attributes: attributes)
        let firstLineRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
        firstLineAttributed.draw(in: firstLineRect)
        yPosition += 20
        
        // Second line: website (if present)
        if let website = info.website, !website.isEmpty {
            let websiteString = "Website: \(website)"
            let websiteAttributed = NSAttributedString(string: websiteString, attributes: attributes)
            let websiteRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
            websiteAttributed.draw(in: websiteRect)
            yPosition += 20
        }
        
        return yPosition + 10 // Add some extra space after personal info
    }
    
    private static func addSection(title: String, content: [String], pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
        let titleFont = UIFont.systemFont(ofSize: 16.0, weight: .bold)
        let contentFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        let contentAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: contentFont]
        
        var yPosition = yOffset
        
        // Draw the section title
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
        let titleSize = attributedTitle.size()
        let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: titleSize.height)
        attributedTitle.draw(in: titleRect)
        yPosition += titleSize.height + 5
        
        // Draw the section content
        for line in content {
            let attributedContent = NSAttributedString(string: line, attributes: contentAttributes)
            let contentSize = attributedContent.size()
            let contentRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: contentSize.height)
            attributedContent.draw(in: contentRect)
            yPosition += contentSize.height + 5
        }
        
        return yPosition + 10
    }
    
    private static func addProfessionalHistory(_ history: [ProfessionalExperience], pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
        var yPosition = addSection(title: "Professional History", content: [], pageRect: pageRect, yOffset: yOffset)
        
        for experience in history {
            let companyFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
            let detailsFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
            
            let companyAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: companyFont]
            let detailsAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: detailsFont]
            
            let companyText = "\(experience.company), \(experience.position)"
            let dateText = formatYearRange(start: experience.startYear, end: experience.endYear)
            
            let attributedCompany = NSAttributedString(string: companyText, attributes: companyAttributes)
            let attributedDate = NSAttributedString(string: dateText, attributes: detailsAttributes)
            
            let companyRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
            let dateRect = CGRect(x: 36, y: yPosition + 20, width: pageRect.width - 72, height: 20)
            
            attributedCompany.draw(in: companyRect)
            attributedDate.draw(in: dateRect)
            
            yPosition += 50
            
            for responsibility in experience.responsibilities {
                let bulletPoint = "• \(responsibility)"
                let attributedBullet = NSAttributedString(string: bulletPoint, attributes: detailsAttributes)
                let bulletRect = CGRect(x: 46, y: yPosition, width: pageRect.width - 82, height: 20)
                attributedBullet.draw(in: bulletRect)
                yPosition += 20
            }
            
            yPosition += 10
        }
        
        return yPosition
    }
    
    private static func addEducationalHistory(_ history: [Education], pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
        var yPosition = addSection(title: "Educational History", content: [], pageRect: pageRect, yOffset: yOffset)
        
        for education in history {
            let schoolFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
            let detailsFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
            
            let schoolAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: schoolFont]
            let detailsAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: detailsFont]
            
            let schoolText = education.institution
            let degreeText = "\(education.degree), \(formatYearRange(start: education.startYear, end: education.endYear))"
            
            let attributedSchool = NSAttributedString(string: schoolText, attributes: schoolAttributes)
            let attributedDegree = NSAttributedString(string: degreeText, attributes: detailsAttributes)
            
            let schoolRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
            let degreeRect = CGRect(x: 36, y: yPosition + 20, width: pageRect.width - 72, height: 20)
            
            attributedSchool.draw(in: schoolRect)
            attributedDegree.draw(in: degreeRect)
            
            yPosition += 50
            
            if !education.details.isEmpty {
                let attributedDetails = NSAttributedString(string: education.details, attributes: detailsAttributes)
                let detailsRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
                attributedDetails.draw(in: detailsRect)
                yPosition += 30
            }
        }
        
        return yPosition
    }
    
    private static func addProjects(_ projects: [Project], pageRect: CGRect, yOffset: CGFloat) -> CGFloat {
        var yPosition = addSection(title: "Projects", content: [], pageRect: pageRect, yOffset: yOffset)
        
        let titleFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        let detailsFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: titleFont]
        let detailsAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: detailsFont]
        
        for project in projects {
            if let title = project.title {
                let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
                let titleRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 20)
                attributedTitle.draw(in: titleRect)
                yPosition += 25
            }
            
            if let details = project.details {
                let attributedDetails = NSAttributedString(string: details, attributes: detailsAttributes)
                let detailsRect = CGRect(x: 36, y: yPosition, width: pageRect.width - 72, height: 60)
                attributedDetails.draw(in: detailsRect)
                yPosition += 70
            }
        }
        
        return yPosition
    }
}
