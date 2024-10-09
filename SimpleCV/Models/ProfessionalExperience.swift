//
//  ProfessionalExperience.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import Foundation

struct ProfessionalExperience: Codable, Identifiable, Equatable {
    var id = UUID()
    var company: String
    var position: String
    var startYear: Int
    var endYear: Int?
    var responsibilities: [String]
}
