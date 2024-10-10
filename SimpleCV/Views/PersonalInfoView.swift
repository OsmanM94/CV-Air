//
//  PersonalInfoView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct PersonalInfoView: View {
    @Binding var personalInfo: PersonalInfo
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, address, phoneNumber, email, website
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("Name", text: $personalInfo.name)
                .textContentType(.name)
                .keyboardType(.namePhonePad)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .accessibilityLabel("Name")
            
            Divider()
            
            TextField("Address", text: $personalInfo.address)
                .textContentType(.fullStreetAddress)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .address)
                .submitLabel(.next)
                .accessibilityLabel("Address")
            
            Divider()
            
            TextField("Phone Number", text: $personalInfo.phoneNumber)
                .textContentType(.telephoneNumber)
                .keyboardType(.namePhonePad)
                .focused($focusedField, equals: .phoneNumber)
                .submitLabel(.next)
                .accessibilityLabel("Phone number")
            
            Divider()
            
            TextField("Email", text: $personalInfo.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .accessibilityLabel("Email address")
            
            Divider()
            
            TextField("Website (optional)", text: Binding(
                get: { personalInfo.website ?? "" },
                set: { personalInfo.website = $0.isEmpty ? nil : $0 }
            ))
            .textContentType(.URL)
            .keyboardType(.URL)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: .website)
            .submitLabel(.done)
            .accessibilityLabel("Website (optional)")
        }
        .onSubmit {
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
}
