//
//  Education.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import Foundation

struct Education: Codable, Identifiable {
    var id = UUID()
    var institution: String
    var degree: String
    var startYear: Int
    var endYear: Int?
    var details: String
}

