//
//  Project.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import Foundation

struct Project: Codable, Identifiable {
    var id = UUID()
    var title: String?
    var details: String?
    
    init(id: UUID = UUID(), title: String? = nil, details: String? = nil) {
        self.id = id
        self.title = title
        self.details = details
    }
}
