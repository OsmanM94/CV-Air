//
//  SupportView.swift
//  SimpleCV
//
//  Created by asia on 10.10.2024.
//

import SwiftUI

struct SupportView: View {
    let phoneNumber = "07466861603"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .foregroundStyle(Color(.systemGray6))
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("osmanmunur@yahoo.com")
                        .accessibilityLabel("Tap to email developer")
                    
                    Text("I'm aiming to answer within 24 hours")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 120)
            }
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SupportView()
}
