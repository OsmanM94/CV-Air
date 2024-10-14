
import SwiftUI

struct SettingsView: View {
    @AppStorage("isTextAssistEnabled") private var isTextAssistEnabled: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Feedback & Support") {
                    NavigationLink("Support") {
                        SupportView()
                    }
                }
                .accessibilityLabel("Call support for any questions or issues")
                
                Section("Text length feedback") {
                    Toggle("Get feedback", systemImage: "text.badge.checkmark", isOn: $isTextAssistEnabled)
                        .popoverTip(TextAssistTip(), arrowEdge: .bottom)
                }
                .accessibilityLabel("Receive feedback on text length to optimize your CV for ATS systems")
            }
            .navigationTitle("Settings")
            .padding(.top)
        }
    }
}

#Preview {
    SettingsView()
}
