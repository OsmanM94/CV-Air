//
//  EducationalHistoryView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct EducationalHistoryView: View {
    @Binding var educationalHistory: [Education]
    @State private var newEducation = Education(institution: "", degree: "", startYear: Calendar.current.component(.year, from: Date()), endYear: nil, details: "")
    
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var editingEducationId: UUID? = nil
    @State private var tempEducation: Education?
    
    var body: some View {
        List {
            ForEach(educationalHistory, id: \.id) { education in
                VStack(alignment: .leading, spacing: 8) {
                    if editingEducationId == education.id {
                        editingView(for: education)
                    } else {
                        displayView(for: education)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .onMove(perform: moveEducation)
            .onDelete(perform: deleteEducation)
            .listRowSeparator(.hidden)
        }
        
        TextField("Institution", text: $newEducation.institution)
            .autocorrectionDisabled()
            .onChange(of: newEducation.institution) { _, _ in
                showingError = false
            }
        
        TextField("Degree", text: $newEducation.degree)
            .autocorrectionDisabled()
            .onChange(of: newEducation.degree) { _, _ in
                showingError = false
            }
        
        if showingError {
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
        }
        
        HStack {
            Picker("Start Year", selection: $newEducation.startYear) {
                ForEach(1950...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
            .background(Color.black.opacity(0.1))
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Picker("End Year", selection: Binding(
                get: { newEducation.endYear ?? Calendar.current.component(.year, from: Date()) },
                set: { newEducation.endYear = $0 }
            )) {
                ForEach(1950...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
            .background(Color.black.opacity(0.1))
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        
        TextField("Additional Details", text: $newEducation.details, axis: .vertical)
            .autocorrectionDisabled()
        
        Button("Add Education") {
            if validateNewEducation() {
                educationalHistory.append(newEducation)
                newEducation = Education(institution: "", degree: "", startYear: Calendar.current.component(.year, from: Date()), endYear: nil, details: "")
                showingError = false
            }
        }
        .foregroundStyle(.blue)
    }
    
    private func displayView(for education: Education) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(education.institution)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(formatYearRange(start: education.startYear, end: education.endYear))
                    .font(.caption)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button(action: {
                    startEditing(education)
                }) {
                    Image(systemName: "pencil")
                        .imageScale(.medium)
                        .foregroundStyle(.blue)
                }
            }
            Text(education.degree)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if !education.details.isEmpty {
                Text("Details:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.top, 4)
                
                Text(education.details)
                    .font(.subheadline)
            }
        }
    }
    
    private func editingView(for education: Education) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Institution", text: Binding(
                get: { tempEducation?.institution ?? "" },
                set: { tempEducation?.institution = $0 }
            ))
            .autocorrectionDisabled()
            
            TextField("Degree", text: Binding(
                get: { tempEducation?.degree ?? "" },
                set: { tempEducation?.degree = $0 }
            ))
            .autocorrectionDisabled()
            
            HStack(spacing: 10) {
                Picker("From", selection: Binding(
                    get: { tempEducation?.startYear ?? Calendar.current.component(.year, from: Date()) },
                    set: { tempEducation?.startYear = $0 }
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
                
                Picker("To", selection: Binding(
                    get: { tempEducation?.endYear ?? Calendar.current.component(.year, from: Date()) },
                    set: { tempEducation?.endYear = $0 }
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
            }
            
            TextField("Additional Details", text: Binding(
                get: { tempEducation?.details ?? "" },
                set: { tempEducation?.details = $0 }
            ), axis: .vertical)
            .autocorrectionDisabled()
            
            HStack(spacing: 20) {
                Button("Save") {
                    saveEdits()
                }
                .foregroundStyle(.blue)
                
                Button("Cancel") {
                    cancelEditing()
                }
                .foregroundStyle(.red)
            }
        }
    }
    
    private func startEditing(_ education: Education) {
        editingEducationId = education.id
        tempEducation = education
    }
    
    private func saveEdits() {
        if let index = educationalHistory.firstIndex(where: { $0.id == editingEducationId }),
           let updatedEducation = tempEducation {
            educationalHistory[index] = updatedEducation
        }
        editingEducationId = nil
        tempEducation = nil
    }
    
    private func cancelEditing() {
        editingEducationId = nil
        tempEducation = nil
    }
    
    func moveEducation(from source: IndexSet, to destination: Int) {
        educationalHistory.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteEducation(at offsets: IndexSet) {
        educationalHistory.remove(atOffsets: offsets)
    }
    
    private func validateNewEducation() -> Bool {
        if newEducation.institution.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Institution name cannot be empty"
            showingError = true
            return false
        }
        
        if newEducation.degree.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Degree cannot be empty"
            showingError = true
            return false
        }
        
        return true
    }
}
