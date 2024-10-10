//
//  FormView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct CVFormView: View {
    @Bindable var cv: CV
    var onSave: (() async throws -> Void)?
    var isNewCV: Bool
    
    @State private var isSaving: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var saveSuccess: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                PersonalInfoView(personalInfo: $cv.personalInfo)
            }
            
            Section(header: Text("Summary")) {
                TextField("A short summary of yourself", text: $cv.summary, axis: .vertical)
                    .accessibilityLabel("Add a short summary about yourself. Keep it simple and to the point.")
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
                    Text("Professional history")
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
                    Text("Educational history")
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
                    CVPreview(cv: cv)
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
            ToolbarItem {
                EditButton()
                    .foregroundStyle(.blue)
                    
            }
        }
        .buttonStyle(.plain)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
