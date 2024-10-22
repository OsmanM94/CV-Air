import SwiftUI
import SwiftData

struct ContentView: View {    
    @State private var cvType: CVType = .standard
    @Environment(\.colorScheme) private var colorScheme
    
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
            .background(backgroundStyle)
            .navigationTitle("Create")
            .toolbarBackground(backgroundStyle, for: .navigationBar)
           
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
    
    private var backgroundStyle: Color {
        colorScheme == .light ? Color(.systemGray6) : Color.clear
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
        ZStack {
            if storeViewModel.unlockedFeatures["customCV"] != true {
                CustomCVPromo()
            } else {
                CustomCVFormView(customCV: customCV, onSave: saveCustomCV, isNewCV: true)
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
