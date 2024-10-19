//
//  SimpleCVApp.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct SimpleCVApp: App {
    @State private var storeKitViewModel = StoreKitViewModel()
    
    var body: some Scene {
        WindowGroup {
            Tab()
                .task {
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
                .environment(storeKitViewModel)
        }
        .modelContainer(for: [CV.self, CustomCV.self])
    }
}
