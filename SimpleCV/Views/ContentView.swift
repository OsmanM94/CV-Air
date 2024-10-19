import SwiftUI
import SwiftData

struct ContentView: View {    
    @State private var cvType: CVType = .standard
    
    enum CVType {
        case standard, custom
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("CV Type", selection: $cvType) {
                    Text("Standard").tag(CVType.standard)
                    Text("Custom").tag(CVType.custom)
                }
                .pickerStyle(.segmented)
                .padding()
                
                creationView
            }
            .navigationTitle("Create CV")
        }
    }
    
    @ViewBuilder
    private var creationView: some View {
        switch cvType {
        case .standard:
            StandardCVCreationView()
        case .custom:
            CustomCVCreationView()
               
        }
    }
}

struct StandardCVCreationView: View {
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
    @State private var selectedFontSize: CVFontSize = .medium
    @State private var selectedSpacing: CVSpacing = .normal
    
    var body: some View {
        CVFormView(cv: cv, onSave: saveCV, isNewCV: true)
    }
    
    private func saveCV() async {
        cv.pdfData = await generatePDF(
            for: cv,
            using: selectedTemplate,
            fontSize: selectedFontSize,
            spacing: selectedSpacing
        )
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

struct CustomCVCreationView: View {
    @Environment(StoreKitViewModel.self) private var storeViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var customCV = CustomCV(
        personalInfo: PersonalInfo(
            name: "",
            address: "",
            phoneNumber: "",
            email: "",
            website: ""
        ),
        summary: "",
        customSections: []
    )
    
    var body: some View {
        CustomCVFormView(customCV: customCV, onSave: saveCustomCV, isNewCV: true)
            .disabled(storeViewModel.unlockedFeatures["customCV"] != true)
            .overlay {
                if storeViewModel.unlockedFeatures["customCV"] != true {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)
                        .padding()
                        .background(Color(.black).opacity(0.5))
                        .clipShape(Circle())
                }
            }
    }
    
    private func saveCustomCV() async {
        modelContext.insert(customCV)
        
        do {
            try modelContext.save()
            resetFormFields()
        } catch {
            print("Error saving Custom CV: \(error)")
        }
    }
    
    private func resetFormFields() {
        customCV = CustomCV(
            personalInfo: PersonalInfo(
                name: "",
                address: "",
                phoneNumber: "",
                email: "",
                website: ""
            ),
            summary: "",
            customSections: []
        )
    }
}

#Preview {
    ContentView()
        .environment(StoreKitViewModel())
}
