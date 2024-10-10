//
//  HistoryEntry.swift
//  SimpleCV
//
//  Created by asia on 10.10.2024.
//

import Foundation

struct HistoryEntry: Identifiable, Codable {
    var id = UUID()
    var title: String
    var subtitle: String
    var startYear: Int
    var endYear: Int
    var details: [String]
}
