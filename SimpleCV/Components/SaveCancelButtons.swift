//
//  SaveCancelButtons.swift
//  SimpleCV
//
//  Created by asia on 11.10.2024.
//

import SwiftUI

struct SaveCancelButtons: View {
    @State private var isSaving: Bool = false
    @State private var isCancelling: Bool = false
    
    let savingAction: () -> Void
    let cancellingAction: () -> Void
    
    var body: some View {
        HStack {
            Button {
                isSaving.toggle()
                savingAction()
                
            } label: {
                Text("Save")
            }
            .foregroundStyle(.blue)
            .accessibilityLabel("Save changes")
            .sensoryFeedback(.success, trigger: isSaving)
            
            Spacer()
            
            Button(action: {
                isCancelling.toggle()
                cancellingAction()
            }, label: {
                Text("Cancel")
            })
            .foregroundStyle(.red)
            .accessibilityLabel("Cancel changes")
            .sensoryFeedback(.error, trigger: isCancelling)
        }
        .onDisappear {
            isSaving = false
            isCancelling = false
        }
    }
}

#Preview {
    SaveCancelButtons(savingAction: {}, cancellingAction: {})
}
