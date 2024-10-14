

import SwiftUI

struct CharacterLimitModifier: ViewModifier {
    @Binding var text: String
    let characterLimit: Int
    let isTextAssistEnabled: Bool
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            content
            
            if isTextAssistEnabled {
                let charCount = text.count
                
                if charCount > characterLimit {
                    Text("Character recommended limit exceeded: \(charCount)/\(characterLimit)")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if charCount > Int(Double(characterLimit) * 0.8) {
                    Text("Approaching recommended character limit: \(charCount)/\(characterLimit)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else {
                    if !text.isEmpty {
                        Text("Looks good")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
        }
    }
}

extension View {
    func characterLimit(_ text: Binding<String>, limit: Int, isTextAssistEnabled: Bool) -> some View {
        self.modifier(CharacterLimitModifier(text: text, characterLimit: limit, isTextAssistEnabled: isTextAssistEnabled))
    }
}
