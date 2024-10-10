//
//  ProjectView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct ProjectView: View {
    @Binding var projects: [Project]
    @State private var newProject = Project(title: "", details: "")
    @State private var editingProjectId: UUID? = nil
    @State private var tempTitle: String = ""
    @State private var tempDetails: String = ""
    
    var body: some View {
        List {
            ForEach(projects, id: \.id) { project in
                VStack(alignment: .leading, spacing: 20) {
                    if editingProjectId == project.id {
                        TextField("Project Title", text: $tempTitle)
                            .autocorrectionDisabled()
                        
                        TextField("Project Details", text: $tempDetails, axis: .vertical)
                            .autocorrectionDisabled()
                     
                        HStack(spacing: 20) {
                            Button {
                                saveEdits(for: project)
                            } label: {
                               Text("Save")
                            }
                            .foregroundStyle(.blue)
                            
                            Button(action: {
                                cancelEditing()
                            }, label: {
                                Text("Cancel")
                            })
                            .foregroundStyle(.red)
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
                        }
                        
                        Text(project.details)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
        
        TextEditor(text: Binding(
            get: { newProject.details },
            set: { newProject.details = $0 }
        ))
        .frame(minHeight: 200)
        .autocorrectionDisabled()
        .background(Color(.black).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
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
        projects = []
        projects.append(newProject)
        newProject = Project(title: "", details: "")
    }
    
    private func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
    }
}


