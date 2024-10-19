
import SwiftUI

struct CustomSectionsView: View {
    @Binding var sections: [CustomSection]
    @State private var newSection = CustomSection(title: "", content: [])
    @State private var newContent: String = ""
    
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showingDeleteAlert = false
    @State private var deleteIndex: Int?
    
    @State private var editingSectionId: UUID? = nil
    @State private var tempSection: CustomSection?
    
    @AppStorage("isTextAssistEnabled") private var isTextAssistEnabled: Bool = false
    let characterLimits: [String: Int] = [
        "title": 50,
        "content": 200
    ]
    
    var body: some View {
        List {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: 8) {
                    if editingSectionId == section.id {
                        editingView(for: section)
                    } else {
                        displayView(for: section)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .onMove(perform: moveSection)
            .onDelete(perform: deleteSection)
            .listRowSeparator(.hidden)
        }
        
        TextField("Section Title", text: $newSection.title)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .onChange(of: newSection.title) { _, _ in
                showingError = false
            }
            .accessibilityLabel("New Section Title")
            .characterLimit($newSection.title, limit: characterLimits["title"] ?? 50, isTextAssistEnabled: isTextAssistEnabled)
        
        if showingError {
            Text(errorMessage)
                .foregroundStyle(.red)
                .font(.caption)
                .accessibilityLabel("Error: \(errorMessage)")
        }
        
        VStack(alignment: .leading, spacing: 25) {
            ForEach(newSection.content.indices, id: \.self) { index in
                HStack {
                    Text(newSection.content[index])
                        .accessibilityLabel("Content \(index + 1): \(newSection.content[index])")
                    
                    Spacer()
                    
                    Button(action: {
                        newSection.content.remove(at: index)
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .accessibilityLabel("Delete Content \(index + 1)")
                }
            }
            
            HStack {
                TextField("New Content", text: $newContent, axis: .vertical)
                    .accessibilityLabel("New Content")
                    .characterLimit($newContent, limit: characterLimits["content"] ?? 200, isTextAssistEnabled: isTextAssistEnabled)
                
                Button {
                    if !newContent.isEmpty {
                        newSection.content.append(newContent)
                        newContent = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .disabled(newContent.isEmpty)
                .accessibilityLabel("Add Content")
            }
            .padding(.top)
        }
        
        Button("Add Section") {
            sections.append(newSection)
            newSection = CustomSection(title: "", content: [])
            showingError = false
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
        .padding(.top)
        .foregroundStyle(.blue)
        .accessibilityLabel("Add Section")
    }
    
    private func displayView(for section: CustomSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(section.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    startEditing(section)
                } label: {
                    Image(systemName: "pencil")
                        .imageScale(.large)
                        .foregroundStyle(.blue)
                }
                .accessibilityLabel("Edit \(section.title)")
            }
            
            ForEach(section.content, id: \.self) { content in
                HStack(alignment: .top, spacing: 8) {
                    Text("")
                        .foregroundStyle(.blue)
                    Text(content)
                        .font(.subheadline)
                }
                .accessibilityLabel("Content: \(content)")
            }
        }
    }
    
    private func editingView(for section: CustomSection) -> some View {
        VStack(alignment: .leading, spacing: 30) {
            TextField("Section Title", text: Binding(
                get: { tempSection?.title ?? "" },
                set: { tempSection?.title = $0 }
            ))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .accessibilityLabel("Edit Section Title")
            .characterLimit(Binding(
                get: { tempSection?.title ?? "" },
                set: { tempSection?.title = $0 }
            ), limit: characterLimits["title"] ?? 100, isTextAssistEnabled: isTextAssistEnabled)
            
            ForEach(Array((tempSection?.content ?? []).enumerated()), id: \.offset) { index, content in
                HStack(spacing: 15) {
                    TextField("Edit Content", text: Binding(
                        get: { content },
                        set: { newValue in
                            if var contents = tempSection?.content {
                                contents[index] = newValue
                                tempSection?.content = contents
                            }
                        }
                    ), axis: .vertical)
                    .accessibilityLabel("Edit Content \(index + 1)")
                    .characterLimit(Binding(
                        get: { content },
                        set: { newValue in
                            if var contents = tempSection?.content {
                                contents[index] = newValue
                                tempSection?.content = contents
                            }
                        }
                    ), limit: characterLimits["content"] ?? 200, isTextAssistEnabled: isTextAssistEnabled)
                    
                    Button(action: {
                        deleteIndex = index
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .accessibilityLabel("Delete Content \(index + 1)")
                }
            }
            .alert("Delete Content", isPresented: $showingDeleteAlert, presenting: deleteIndex) { index in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if var contents = tempSection?.content, contents.indices.contains(index) {
                        contents.remove(at: index)
                        tempSection?.content = contents
                    }
                }
            } message: { _ in
                Text("Are you sure you want to delete this content?")
            }
            
            HStack {
                TextField("New Content", text: $newContent)
                    .accessibilityLabel("New Content")
                    .characterLimit($newContent, limit: characterLimits["content"] ?? 200, isTextAssistEnabled: isTextAssistEnabled)
                Spacer()
                
                Button {
                    if !newContent.isEmpty {
                        tempSection?.content.append(newContent)
                        newContent = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .disabled(newContent.isEmpty)
                .accessibilityLabel("Add Content")
            }
            .padding([.top, .bottom], 30)
            
            SaveCancelButtons {
                saveEdits()
            } cancellingAction: {
                cancelEditing()
            }
        }
    }
    
    private func startEditing(_ section: CustomSection) {
        editingSectionId = section.id
        tempSection = section
    }
    
    private func saveEdits() {
        if let index = sections.firstIndex(where: { $0.id == editingSectionId }),
           let updatedSection = tempSection {
            sections[index] = updatedSection
        }
        editingSectionId = nil
        tempSection = nil
        newContent = ""
    }
    
    private func cancelEditing() {
        editingSectionId = nil
        tempSection = nil
        newContent = ""
    }
    
    private func moveSection(from source: IndexSet, to destination: Int) {
        sections.move(fromOffsets: source, toOffset: destination)
    }
    
    private func deleteSection(at offsets: IndexSet) {
        sections.remove(atOffsets: offsets)
    }
}



