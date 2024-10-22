

import SwiftUI

struct CustomCVFormView: View {
    @Bindable var customCV: CustomCV
    var onSave: (() async throws -> Void)?
    var isNewCV: Bool
    
    @State private var isSaving: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var saveSuccess: Bool = false
    
    @State private var showingShareSheet: Bool = false
    
    @AppStorage("isTextAssistEnabled") private var isTextAssistEnabled: Bool = false
    @State private var selectedFontSize: CVFontSize = .medium
    @State private var selectedSpacing: CVSpacing = .normal
    
    let summaryCharacterLimit: Int = 300
    
    @Environment(StoreKitViewModel.self) private var storeViewModel
    
    var body: some View {
        Form {
            DisclosureGroup {
                Section(header: Text("Font Size")) {
                    Picker("Select Font Size", selection: $selectedFontSize) {
                        Text("Small").tag(CVFontSize.small)
                        Text("Medium").tag(CVFontSize.medium)
                        Text("Large").tag(CVFontSize.large)
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                .accessibilityLabel("Adjust font size. The smaller, the more you can fit in A4")
                
                Section(header: Text("Spacing")) {
                    Picker("Select Spacing", selection: $selectedSpacing) {
                        Text("Compact").tag(CVSpacing.compact)
                        Text("Normal").tag(CVSpacing.normal)
                        Text("Relaxed").tag(CVSpacing.relaxed)
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
                .accessibilityLabel("Adjust spacing between the sections")
            } label: {
                HStack {
                    Text("Adjustments")
                    Spacer()
                    if storeViewModel.unlockedFeatures["adjustments"] != true {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .disabled(storeViewModel.unlockedFeatures["adjustments"] != true)

            Section(header: Text("Personal Information")) {
                PersonalInfoView(personalInfo: $customCV.personalInfo)
            }
            
            Section(header: Text("Summary")) {
                TextField("A short summary of yourself", text: $customCV.summary, axis: .vertical)
                    .accessibilityLabel("Add a short summary about yourself. Keep it simple and to the point.")
                    .characterLimit($customCV.summary, limit: summaryCharacterLimit, isTextAssistEnabled: isTextAssistEnabled)
            }
            
            Section(header: Text("Custom Sections")) {
                CustomSectionsView(sections: $customCV.customSections)
            }
            
            Section {
                if let onSave = onSave {
                    Button(action: {
                        Task {
                            await saveCustomCV(onSave: onSave)
                        }
                    }) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text(isNewCV ? "Save" : "Update")
                        }
                    }
                    .disabled(!isFormValid() || isSaving)
                    .sensoryFeedback(.success, trigger: saveSuccess)
                }
            }
            .foregroundStyle(.blue)
        }
        .toolbar {
            Menu {
                EditButton()
                    .foregroundStyle(.blue)
                
                Button(action: {
                    generateAndExportPDF()
                }) {
                    Label("Export PDF", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button {
                    hideKeyboard()
                } label: {
                    Text("Done")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
        }
        .buttonStyle(.plain)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingShareSheet) {
            if let data = customCV.pdfData {
                ShareSheet(activityItems: [data])
            }
        }
    }
    
    private func generateAndExportPDF() {
        Task {
            let pdfData = await generateCustomPDF(for: customCV, fontSize: selectedFontSize, spacing: selectedSpacing)
            await MainActor.run {
                customCV.pdfData = pdfData
                showingShareSheet = true
            }
        }
    }
    
    private func saveCustomCV(onSave: @escaping () async throws -> Void) async {
        guard !isSaving else { return }
        isSaving = true
        saveSuccess = false
        
        do {
            try await onSave()
            alertMessage = "Saved."
            saveSuccess = true
        } catch {
            alertMessage = "Oops... Something went wrong: \(error.localizedDescription)"
        }
        
        isSaving = false
        showingAlert = true
    }
    
    private func isFormValid() -> Bool {
        !customCV.personalInfo.name.isEmpty &&
        !customCV.personalInfo.email.isEmpty &&
        !customCV.personalInfo.phoneNumber.isEmpty &&
        !customCV.personalInfo.address.isEmpty &&
        !customCV.customSections.isEmpty
    }
}

#Preview {
    NavigationStack {
        CustomCVFormView(customCV: CustomCV(personalInfo: PersonalInfo(name: "Munir", address: "54 Salter Street", phoneNumber: "07466861603", email: "osmanmunur@yahoo.com"), summary: "Hard working individual", customSections: [CustomSection(title: "Project", content: ["Hello electric is a car marketplace", "It is a web application that allows users to search for and buy electric vehicles"])]), isNewCV: true)
            .environment(StoreKitViewModel())
    }
}
