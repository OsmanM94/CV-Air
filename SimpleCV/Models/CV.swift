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
    var professionalHistory: [ProfessionalExperience]
    var educationalHistory: [Education]
    var projects: [Project]
    var skills: [String]
    var pdfData: Data?
    
    init(personalInfo: PersonalInfo, summary: String, professionalHistory: [ProfessionalExperience], educationalHistory: [Education], projects: [Project], skills: [String]) {
        self.personalInfo = personalInfo
        self.summary = summary
        self.professionalHistory = professionalHistory
        self.educationalHistory = educationalHistory
        self.projects = projects
        self.skills = skills
    }
}
