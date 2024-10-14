
import SwiftUI

struct ProjectView: View {
    @Binding var projects: [Project]
    @State private var newProject = Project(title: "", details: "")
    @State private var editingProjectId: UUID? = nil
    @State private var tempTitle: String = ""
    @State private var tempDetails: String = ""
    
    @AppStorage("isTextAssistEnabled") private var isTextAssistEnabled: Bool = false
    
    let characterLimits: [String: Int] = [
        "title": 100,
        "details": 500
    ]
        
    var body: some View {
        List {
            ForEach(projects, id: \.id) { project in
                VStack(alignment: .leading, spacing: 20) {
                    if editingProjectId == project.id {
                        TextField("Project Title", text: $tempTitle)
                            .autocorrectionDisabled()
                            .accessibilityLabel("Edit Project Title")
                            .characterLimit($tempTitle, limit: characterLimits["title"] ?? 100, isTextAssistEnabled: isTextAssistEnabled)
                        
                        TextField("Project Details", text: $tempDetails, axis: .vertical)
                            .accessibilityLabel("Edit Project Details")
                            .characterLimit($tempDetails, limit: characterLimits["details"] ?? 500, isTextAssistEnabled: isTextAssistEnabled)
                        
                        SaveCancelButtons {
                            saveEdits(for: project)
                        } cancellingAction: {
                            cancelEditing()
                        }
                        
                    } else {
                        HStack {
                            Text(project.title)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                startEditing(project)
                            } label: {
                                Image(systemName: "pencil")
                                    .imageScale(.large)
                            }
                            .foregroundStyle(.blue)
                            .accessibilityLabel("Edit Project")
                        }
                        
                        Text(project.details)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .contain)
                .accessibilityLabel(editingProjectId == project.id ? "Editing Project" : "Project")
                .accessibilityValue(editingProjectId == project.id ? "Title: \(tempTitle), Details: \(tempDetails)" : "Title: \(project.title), Details: \(project.details)")
            }
            .onMove(perform: moveProject)
            .onDelete(perform: deleteProject)
            .listRowSeparator(.hidden, edges: .top)
        }
        
        TextField("Project Title", text: Binding(
            get: { newProject.title },
            set: { newProject.title =  $0 }
        ))
        .padding([.top])
        .autocorrectionDisabled()
        .listRowSeparator(.hidden, edges: .bottom)
        .alignmentGuide(.leading, computeValue: {_ in 0 })
        .accessibilityLabel("New Project Title")
        .characterLimit(Binding(
            get: { newProject.title },
            set: { newProject.title = $0 }
        ), limit: characterLimits["title"] ?? 100, isTextAssistEnabled: isTextAssistEnabled)
        
        TextEditor(text: Binding(
            get: { newProject.details },
            set: { newProject.details = $0 }
        ))
        .frame(minHeight: 200)
        .background(Color(.black).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityLabel("New Project Details")
        .characterLimit(Binding(
            get: { newProject.details },
            set: { newProject.details = $0 }
        ), limit: characterLimits["details"] ?? 500, isTextAssistEnabled: isTextAssistEnabled)
        
        Button(action: addNewProject) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Project")
            }
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .disabled((newProject.title).isEmpty && (newProject.details).isEmpty)
        .listRowSeparator(.hidden)
        .accessibilityLabel("Add New Project")
        .accessibilityHint("Adds a new project with the entered title and details")
    }
    
    private func startEditing(_ project: Project) {
        editingProjectId = project.id
        tempTitle = project.title
        tempDetails = project.details
    }
    
    private func saveEdits(for project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].title = tempTitle
            projects[index].details = tempDetails
        }
        editingProjectId = nil
    }
    
    private func cancelEditing() {
        editingProjectId = nil
    }
    
    private func moveProject(from source: IndexSet, to destination: Int) {
        projects.move(fromOffsets: source, toOffset: destination)
    }
    
    private func addNewProject() {
        projects.append(newProject)
        newProject = Project(title: "", details: "")
    }
    
    private func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
    }
}


