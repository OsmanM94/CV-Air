
import SwiftUI

struct HistoryView: View {
    @Binding var history: [HistoryEntry]
    @State private var newEntry = HistoryEntry(title: "", subtitle: "", startYear: Calendar.current.component(.year, from: Date()), endYear: nil, details: [])
    
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    @State private var showingDeleteAlert = false
    @State private var deleteIndex: Int?
    
    @State private var editingEntryId: UUID? = nil
    @State private var tempEntry: HistoryEntry?
    
    @State private var newDetail: String = ""
    
    @AppStorage("isTextAssistEnabled") private var isTextAssistEnabled: Bool = false
    let characterLimits: [String: Int] = [
        "title": 100,
        "subtitle": 100,
        "detail": 100
    ]
        
    let titlePlaceholder: String
    let subtitlePlaceholder: String
    let detailsTitle: String
    let addButtonTitle: String
    
    var body: some View {
        List {
            ForEach(history) { entry in
                VStack(alignment: .leading, spacing: 8) {
                    if editingEntryId == entry.id {
                        editingView(for: entry)
                    } else {
                        displayView(for: entry)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .onMove(perform: moveEntry)
            .onDelete(perform: deleteEntry)
            .listRowSeparator(.hidden)
        }
        
        TextField(titlePlaceholder, text: $newEntry.title)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .onChange(of: newEntry.title) { _, _ in
                showingError = false
            }
            .accessibilityLabel(titlePlaceholder)
            .characterLimit($newEntry.title, limit: characterLimits["title"] ?? 100, isTextAssistEnabled: isTextAssistEnabled)
        
        TextField(subtitlePlaceholder, text: $newEntry.subtitle)
            .autocorrectionDisabled()
            .onChange(of: newEntry.subtitle) { _, _ in
                showingError = false
            }
            .accessibilityLabel(subtitlePlaceholder)
            .characterLimit($newEntry.subtitle, limit: characterLimits["subtitle"] ?? 150, isTextAssistEnabled: isTextAssistEnabled)
        
        if showingError {
            Text(errorMessage)
                .foregroundStyle(.red)
                .font(.caption)
                .accessibilityLabel("Error: \(errorMessage)")
        }
        
        HStack {
            Picker("From", selection: $newEntry.startYear) {
                ForEach(1950...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.black.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .alignmentGuide(.leading, computeValue: { _ in 0 })
            .accessibilityLabel("Start Year")
            
            Picker("To", selection: Binding(
                get: { newEntry.endYear ?? Calendar.current.component(.year, from: Date()) },
                set: { newEntry.endYear = $0 }
            )) {
                ForEach(1950...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.black.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .alignmentGuide(.leading, computeValue: { _ in 0})
            .accessibilityLabel("End Year")
        }
        
        VStack(alignment: .leading, spacing: 25) {
            ForEach(newEntry.details.indices, id: \.self) { index in
                HStack {
                    Text(newEntry.details[index])
                    .accessibilityLabel("\(detailsTitle) \(index + 1): \(newEntry.details[index])")
                    
                    Spacer()
                    
                    Button(action: {
                        newEntry.details.remove(at: index)
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .accessibilityLabel("Delete \(detailsTitle) \(index + 1)")
                }
            }
            
            HStack {
                TextField("\(detailsTitle)", text: $newDetail)
                    .accessibilityLabel("New \(detailsTitle)")
                    .characterLimit($newDetail, limit: characterLimits["detail"] ?? 100, isTextAssistEnabled: isTextAssistEnabled)
                
                Button {
                    if !newDetail.isEmpty {
                        newEntry.details.append(newDetail)
                        newDetail = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .disabled(newDetail.isEmpty)
                .accessibilityLabel("Add \(detailsTitle)")
            }
            .padding(.top)
        }
        
        Button(addButtonTitle) {
            if validateNewEntry() {
                history.append(newEntry)
                newEntry = HistoryEntry(title: "", subtitle: "", startYear: Calendar.current.component(.year, from: Date()), endYear: 2024, details: [])
                showingError = false
            }
        }
        .foregroundStyle(.blue)
        .accessibilityLabel(addButtonTitle)
    }
    
    // MARK: - MainView
    
    private func displayView(for entry: HistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    startEditing(entry)
                } label: {
                    Image(systemName: "pencil")
                        .imageScale(.large)
                        .foregroundStyle(.blue)
                }
                .accessibilityLabel("Edit \(entry.title)")
                
            }
            Text(entry.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(formatYearRange(start: entry.startYear, end: entry.endYear))
                .font(.caption)
                .padding(6)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            if !entry.details.isEmpty {
                Text(detailsTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.top, 4)
                
                ForEach(entry.details, id: \.self) { detail in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundStyle(.blue)
                        Text(detail)
                            .font(.subheadline)
                    }
                    .accessibilityLabel("\(detailsTitle): \(detail)")
                }
            }
        }
    }
    
    // MARK: - EditView
    
    private func editingView(for entry: HistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 30) {
            TextField(titlePlaceholder, text: Binding(
                get: { tempEntry?.title ?? "" },
                set: { tempEntry?.title = $0 }
            ))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .accessibilityLabel("Edit \(titlePlaceholder)")
            .characterLimit(Binding(
                get: { tempEntry?.title ?? "" },
                set: { tempEntry?.title = $0 }
            ), limit: characterLimits["title"] ?? 100, isTextAssistEnabled: isTextAssistEnabled)
            
            TextField(subtitlePlaceholder, text: Binding(
                get: { tempEntry?.subtitle ?? "" },
                set: { tempEntry?.subtitle = $0 }
            ))
            .autocorrectionDisabled()
            .accessibilityLabel("Edit \(subtitlePlaceholder)")
            .characterLimit(Binding(
                get: { tempEntry?.subtitle ?? "" },
                set: { tempEntry?.subtitle = $0 }
            ), limit: characterLimits["subtitle"] ?? 150, isTextAssistEnabled: isTextAssistEnabled)
            
            HStack(spacing: 10) {
                Picker("", selection: Binding(
                    get: { tempEntry?.startYear ?? Calendar.current.component(.year, from: Date()) },
                    set: { tempEntry?.startYear = $0 }
                )) {
                    ForEach(1950...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .background(Color.black.opacity(0.1))
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("Edit Start Year")
                
                Picker("", selection: Binding(
                    get: { tempEntry?.endYear ?? Calendar.current.component(.year, from: Date()) },
                    set: { tempEntry?.endYear = $0 }
                )) {
                    ForEach(1950...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .background(Color.black.opacity(0.1))
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("Edit End Year")
            }
            .frame(maxWidth: .infinity)
            
            Text(detailsTitle)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.top, 4)
                                    
            ForEach(Array((tempEntry?.details ?? []).enumerated()), id: \.offset) { index, detail in
                HStack(spacing: 15) {
                    TextField("Edit \(detailsTitle)", text: Binding(
                        get: { String(describing: detail) },
                        set: { newValue in
                            if var details = tempEntry?.details {
                                details[index] = newValue
                                tempEntry?.details = details
                            }
                        }
                    ), axis: .vertical)
                    .accessibilityLabel("Edit \(detailsTitle) \(index + 1)")
                    .characterLimit(Binding(
                        get: { String(describing: detail) },
                        set: { newValue in
                            if var details = tempEntry?.details {
                                details[index] = newValue
                                tempEntry?.details = details
                            }
                        }
                    ), limit: characterLimits["detail"] ?? 200, isTextAssistEnabled: isTextAssistEnabled)
                    
                    Button(action: {
                        deleteIndex = index
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .accessibilityLabel("Delete \(detailsTitle) \(index + 1)")
                }
            }
            .alert("Delete Detail", isPresented: $showingDeleteAlert, presenting: deleteIndex) { index in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if var details = tempEntry?.details, details.indices.contains(index) {
                        details.remove(at: index)
                        tempEntry?.details = details
                    }
                }
            } message: { _ in
                Text("Are you sure you want to delete this detail?")
            }
            
            HStack {
                TextField("New \(detailsTitle)", text: $newDetail)
                    .accessibilityLabel("New \(detailsTitle)")
                    .characterLimit($newDetail, limit: characterLimits["detail"] ?? 100, isTextAssistEnabled: isTextAssistEnabled)
                Spacer()
                
                Button {
                    if !newDetail.isEmpty {
                        tempEntry?.details.append(newDetail)
                        newDetail = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .disabled(newDetail.isEmpty)
                .accessibilityLabel("Add \(detailsTitle)")
            }
            .padding([.top, .bottom], 30)
            
            SaveCancelButtons {
                saveEdits()
            } cancellingAction: {
                cancelEditing()
            }
        }
    }
    
    // MARK: - Private methods
    
    private func startEditing(_ entry: HistoryEntry) {
        editingEntryId = entry.id
        tempEntry = entry
    }
    
    private func saveEdits() {
        if let index = history.firstIndex(where: { $0.id == editingEntryId }),
           let updatedEntry = tempEntry {
            history[index] = updatedEntry
        }
        editingEntryId = nil
        tempEntry = nil
        newDetail = ""
    }
    
    private func cancelEditing() {
        editingEntryId = nil
        tempEntry = nil
        newDetail = ""
    }
    
    private func moveEntry(from source: IndexSet, to destination: Int) {
        history.move(fromOffsets: source, toOffset: destination)
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
    }
    
    private func validateNewEntry() -> Bool {
        if newEntry.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "\(titlePlaceholder) cannot be empty"
            showingError = true
            return false
        }
        
        if newEntry.subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "\(subtitlePlaceholder) cannot be empty"
            showingError = true
            return false
        }
        
        return true
    }
}
