//
//  PersonalInfoView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct PersonalInfoView: View {
    @Binding var personalInfo: PersonalInfo
    
    var body: some View {
        TextField("Name", text: $personalInfo.name)
            .textContentType(.name)
            .keyboardType(.namePhonePad)
            .autocorrectionDisabled()
        
        TextField("Address", text: $personalInfo.address)
            .textContentType(.fullStreetAddress)
            .autocorrectionDisabled()
        
        TextField("Phone Number", text: $personalInfo.phoneNumber)
            .textContentType(.telephoneNumber)
            .keyboardType(.namePhonePad)
        
        TextField("Email", text: $personalInfo.email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        
        TextField("Website (optional)", text: Binding(
            get: { personalInfo.website ?? "" },
            set: { personalInfo.website = $0.isEmpty ? nil : $0 }
        ))
        .textContentType(.URL)
        .keyboardType(.URL)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
}

