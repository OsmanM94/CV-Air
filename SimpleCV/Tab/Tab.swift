//
//  Tab.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct Tab: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Create", systemImage: "doc.fill.badge.plus")
                }
                .tag(0)
            
            SavedCVsView()
                .tabItem {
                    Label("Saved", systemImage: "folder.fill")
                }
                .tag(1)
            
            GuidanceView()
                .tabItem {
                    Label("Guidance", systemImage: "info.circle.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    Tab()
}
