import SwiftUI
import SwiftData

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
    
    @State private var selectedTemplate: CVTemplateType = .original
    
    var body: some View {
        NavigationStack {
            CVFormView(cv: cv, onSave: saveCV, isNewCV: true)
                .navigationTitle("Create")
        }
    }
        
    private func saveCV() async {
        cv.pdfData = await generatePDF(for: cv, using: selectedTemplate)
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
        selectedTemplate = .original
    }
}

#Preview {
    ContentView()
}
