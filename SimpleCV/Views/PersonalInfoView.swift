

import SwiftUI

struct PersonalInfoView: View {
    @Binding var personalInfo: PersonalInfo
    @AppStorage("isTextAssistEnabled") private var isTextAssistEnabled: Bool = false
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, address, phoneNumber, email, website
    }
    
    let characterLimits: [Field: Int] = [
        .name: 50,
        .address: 100,
        .phoneNumber: 20,
        .email: 50,
        .website: 100
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            createTextField(field: .name, text: $personalInfo.name, placeholder: "Name", contentType: .name, keyboardType: .namePhonePad)
            
            Divider()
            
            createTextField(field: .address, text: $personalInfo.address, placeholder: "Address", contentType: .fullStreetAddress)
            
            Divider()
            
            createTextField(field: .phoneNumber, text: $personalInfo.phoneNumber, placeholder: "Phone Number", contentType: .telephoneNumber, keyboardType: .namePhonePad)
            
            Divider()
            
            createTextField(field: .email, text: $personalInfo.email, placeholder: "Email", contentType: .emailAddress, keyboardType: .emailAddress)
            
            Divider()
            
            createTextField(field: .website, text: Binding(
                get: { personalInfo.website ?? "" },
                set: { personalInfo.website = $0.isEmpty ? nil : $0 }
            ), placeholder: "Website (optional)", contentType: .URL, keyboardType: .URL)
        }
        .onSubmit {
            advanceFocus()
        }
    }
    
    private func createTextField(field: Field, text: Binding<String>, placeholder: String, contentType: UITextContentType, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(placeholder, text: text)
                .textContentType(contentType)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(field == .email || field == .website ? .never : .words)
                .focused($focusedField, equals: field)
                .submitLabel(field == .website ? .done : .next)
                .accessibilityLabel(placeholder)
                .characterLimit(text, limit: characterLimits[field] ?? 100, isTextAssistEnabled: isTextAssistEnabled)
        }
    }
    
    private func advanceFocus() {
        switch focusedField {
        case .name:
            focusedField = .address
        case .address:
            focusedField = .phoneNumber
        case .phoneNumber:
            focusedField = .email
        case .email:
            focusedField = .website
        case .website:
            focusedField = nil
        case .none:
            break
        }
    }
}
