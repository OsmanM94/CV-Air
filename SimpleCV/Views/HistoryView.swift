//
//  HistoryView.swift
//  SimpleCV
//
//  Created by asia on 10.10.2024.
//

import SwiftUI

struct HistoryView: View {
    @Binding var history: [HistoryEntry]
    @State private var newEntry = HistoryEntry(title: "", subtitle: "", startYear: Calendar.current.component(.year, from: Date()), endYear: 2024, details: [])
    
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var editingEntryId: UUID? = nil
    @State private var tempEntry: HistoryEntry?
    
    @State private var newDetail: String = ""
    @State private var showingSaveConfirmation: Bool = false
    @State private var editingDetailIndex: Int? = nil
    
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
        
        TextField(subtitlePlaceholder, text: $newEntry.subtitle)
            .autocorrectionDisabled()
            .onChange(of: newEntry.subtitle) { _, _ in
                showingError = false
            }
            .accessibilityLabel(subtitlePlaceholder)
        
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
                get: { newEntry.endYear },
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
        
        VStack(alignment: .leading, spacing: 12) {
            ForEach(newEntry.details.indices, id: \.self) { index in
                HStack {
                    Label {
                        Text(newEntry.details[index])
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
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
                
                Text(formatYearRange(start: entry.startYear, end: entry.endYear))
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button(action: {
                    startEditing(entry)
                }) {
                    Image(systemName: "pencil")
                        .imageScale(.medium)
                        .foregroundStyle(.blue)
                }
                .accessibilityLabel("Edit \(entry.title)")
            }
            Text(entry.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
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
        VStack(alignment: .leading, spacing: 20) {
            TextField(titlePlaceholder, text: Binding(
                get: { tempEntry?.title ?? "" },
                set: { tempEntry?.title = $0 }
            ))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .accessibilityLabel("Edit \(titlePlaceholder)")
            
            TextField(subtitlePlaceholder, text: Binding(
                get: { tempEntry?.subtitle ?? "" },
                set: { tempEntry?.subtitle = $0 }
            ))
            .autocorrectionDisabled()
            .accessibilityLabel("Edit \(subtitlePlaceholder)")
            
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
                        
            ForEach(tempEntry?.details ?? [], id: \.self) { detail in
                HStack {
                    Text(detail)
                    
                    Spacer()
                    
                    Button(action: {
                        tempEntry?.details.removeAll { $0 == detail }
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                    .accessibilityLabel("Delete \(detailsTitle): \(detail)")
                }
            }
            
            HStack {
                TextField("New \(detailsTitle)", text: $newDetail)
                    .accessibilityLabel("New \(detailsTitle)")
                
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
            .padding([.top, .bottom])
            
            HStack(spacing: 20) {
                Button("Save") {
                    showingSaveConfirmation.toggle()
                }
                .foregroundStyle(.blue)
                .accessibilityLabel("Save changes")
                .confirmationDialog("Are you sure you want to save these changes?", isPresented: $showingSaveConfirmation) {
                    Button("Save") {
                        saveEdits()
                        editingDetailIndex = nil
                    }
                    Button("Cancel", role: .cancel) { }
                }
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
    
    func moveEntry(from source: IndexSet, to destination: Int) {
        history.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteEntry(at offsets: IndexSet) {
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
