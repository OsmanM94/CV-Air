//
//  ContentView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI
import SwiftData


func formatYearRange(start: Int, end: Int?) -> String {
    if let end = end {
        return "\(start) - \(end)"
    } else {
        return "\(start) - Present"
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cv = CV(
        personalInfo: PersonalInfo(
            name: "",
            address: "",
            phoneNumber: "",
            email: "",
            website: ""
        ),
        summary: "",
        professionalHistory: [],
        educationalHistory: [],
        projects: [],
        skills: []
    )
    
    var body: some View {
        NavigationStack {
            CVFormView(cv: cv, onSave: saveCV, isNewCV: true)
                .navigationTitle("Create")
        }
    }
    
    private func saveCV() async {
        cv.pdfData = await CVPDFGenerator.generatePDF(for: cv)
        modelContext.insert(cv)
        
        do {
            try modelContext.save()
            resetFormFields()
        } catch {
            print("Error saving CV: \(error)")
        }
    }
    
    private func resetFormFields() {
        cv = CV(
            personalInfo: PersonalInfo(
                name: "",
                address: "",
                phoneNumber: "",
                email: "",
                website: ""
            ),
            summary: "",
            professionalHistory: [],
            educationalHistory: [],
            projects: [],
            skills: []
        )
    }
}

#Preview {
    ContentView()
}
