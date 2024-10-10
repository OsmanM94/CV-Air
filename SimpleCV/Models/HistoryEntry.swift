//
//  HistoryEntry.swift
//  SimpleCV
//
//  Created by asia on 10.10.2024.
//

import Foundation
import SwiftData

@Model
class HistoryEntry: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var startYear: Int
    var endYear: Int?
    var details: [String]
    
    init(title: String, subtitle: String, startYear: Int, endYear: Int? = nil, details: [String]) {
        self.title = title
        self.subtitle = subtitle
        self.startYear = startYear
        self.endYear = endYear
        self.details = details
    }
}
