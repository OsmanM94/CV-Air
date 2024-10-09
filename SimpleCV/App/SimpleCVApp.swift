//
//  SimpleCVApp.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI
import SwiftData

@main
struct SimpleCVApp: App {
    var body: some Scene {
        WindowGroup {
            Tab()
        }
        .modelContainer(for: CV.self)
    }
}
