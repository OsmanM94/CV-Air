//
//  CustomCV.swift
//  SimpleCV
//
//  Created by asia on 18.10.2024.
//

import Foundation
import SwiftData

@Model
class CustomCV {
    var personalInfo: PersonalInfo
    var summary: String
    var customSections: [CustomSection]
    var pdfData: Data?
    
    init(personalInfo: PersonalInfo, summary: String, customSections: [CustomSection], pdfData: Data? = nil) {
        self.personalInfo = personalInfo
        self.summary = summary
        self.customSections = customSections
        self.pdfData = pdfData
    }
}

struct CustomSection: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: [String]
}
