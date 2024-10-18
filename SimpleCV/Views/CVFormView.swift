
import SwiftUI

struct CVFormView: View {
    @Bindable var cv: CV
    var onSave: (() async throws -> Void)?
    var isNewCV: Bool
    
    @State private var isSaving: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var saveSuccess: Bool = false
    
    @State private var showingShareSheet: Bool = false
    
    @AppStorage("isTextAssistEnabled") private var isTextAssistEnabled: Bool = false
    @State private var selectedTemplate: CVTemplateType = .original
    @State private var selectedFontSize: CVFontSize = .medium
    @State private var selectedSpacing: CVSpacing = .normal
    
    let summaryCharacterLimit: Int = 300
    
    @Environment(StoreKitViewModel.self) private var storeViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Template")) {
                Picker("Select Template", selection: $selectedTemplate) {
                    ForEach(CVTemplateType.allCases, id: \.id) { template in
                        if template == .original || storeViewModel.unlockedFeatures[template.productId] == true {
                            Text(template.rawValue).tag(template)
                        } else {
                            Label {
                                Text(template.rawValue)
                            } icon: {
                                Image(systemName: "lock.fill")
                            }
                            .tag(template)
                        }
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selectedTemplate) { _, newValue in
                    if newValue != .original && storeViewModel.unlockedFeatures[newValue.productId] != true {
                        selectedTemplate = .original
                    }
                }
            }
            .accessibilityLabel("Select templates")
            
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
                PersonalInfoView(personalInfo: $cv.personalInfo)
            }
            
            Section(header: Text("Summary")) {
                TextField("A short summary of yourself", text: $cv.summary, axis: .vertical)
                    .accessibilityLabel("Add a short summary about yourself. Keep it simple and to the point.")
                    .characterLimit($cv.summary, limit: summaryCharacterLimit, isTextAssistEnabled: isTextAssistEnabled)
            }
            
            Section {
                DisclosureGroup {
                    HistoryView(
                        history: $cv.professionalHistory,
                        titlePlaceholder: "Company",
                        subtitlePlaceholder: "Position",
                        detailsTitle: "Responsibilities",
                        addButtonTitle: "Add Experience"
                    )
                } label: {
                    Text("Professional History")
                        .foregroundStyle(.blue)
                }
            }

            Section {
                DisclosureGroup {
                    HistoryView(
                        history: $cv.educationalHistory,
                        titlePlaceholder: "Institution",
                        subtitlePlaceholder: "Degree",
                        detailsTitle: "Details",
                        addButtonTitle: "Add Education"
                    )
                } label: {
                    Text("Educational History")
                        .foregroundStyle(.blue)
                }
            }
            
            Section {
                DisclosureGroup {
                    ProjectView(projects: $cv.projects)
                } label: {
                    Label("Projects", systemImage: "folder.fill")
                        .foregroundStyle(.blue)
                }
            }

            Section(header: Text("Skills")) {
                SkillsView(skills: $cv.skills)
            }
            
            Section {
                NavigationLink("Preview") {
                    CVPreview(cv: cv, templateType: selectedTemplate, fontSize: selectedFontSize, spacing: selectedSpacing)
                }
                
                if let onSave = onSave {
                    Button(action: {
                        Task {
                            await saveCV(onSave: onSave)
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
            if let data = cv.pdfData {
                ShareSheet(activityItems: [data])
            }
        }
    }
    
    private func generateAndExportPDF() {
        Task {
            let pdfData = await generatePDF(for: cv, using: selectedTemplate, fontSize: selectedFontSize, spacing: selectedSpacing)
            await MainActor.run {
                cv.pdfData = pdfData
                showingShareSheet = true
            }
        }
    }
    
    private func saveCV(onSave: @escaping () async throws -> Void) async {
        guard !isSaving else { return }
        isSaving = true
        saveSuccess = false
        
        do {
            try await onSave()
            alertMessage = "CV saved successfully!"
            saveSuccess = true
        } catch {
            alertMessage = "Oops... Something went wrong: \(error.localizedDescription)"
        }
        
        isSaving = false
        showingAlert = true
    }
    
    private func isFormValid() -> Bool {
        !cv.personalInfo.name.isEmpty &&
        !cv.personalInfo.email.isEmpty &&
        !cv.personalInfo.phoneNumber.isEmpty &&
        !cv.personalInfo.address.isEmpty
    }
}
