//
//  CV.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import Foundation
import SwiftData

@Model
class CV {
    var personalInfo: PersonalInfo
    var summary: String
    var professionalHistory: [HistoryEntry]
    var educationalHistory: [HistoryEntry]
    var projects: [Project]
    var skills: [String]
    var pdfData: Data?
    
    init(personalInfo: PersonalInfo, summary: String, professionalHistory: [HistoryEntry], educationalHistory: [HistoryEntry], projects: [Project], skills: [String], pdfData: Data? = nil) {
        self.personalInfo = personalInfo
        self.summary = summary
        self.professionalHistory = professionalHistory
        self.educationalHistory = educationalHistory
        self.projects = projects
        self.skills = skills
        self.pdfData = pdfData
    }
}
