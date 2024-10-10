//
//  ProfessionalHistoryView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct ProfessionalExperienceView: View {
    @Binding var professionalHistory: [ProfessionalExperience]
    @State private var newExperience = ProfessionalExperience(company: "", position: "", startYear: Calendar.current.component(.year, from: Date()), endYear: nil, responsibilities: [])
    
    @State private var newResponsibility: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        List {
            ForEach(professionalHistory, id: \.id) { experience in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(experience.company)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(formatYearRange(start: experience.startYear, end: experience.endYear))
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Text(experience.position)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !experience.responsibilities.isEmpty {
                        Text("Responsibilities:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.top, 4)
                        
                        ForEach(experience.responsibilities, id: \.self) { responsibility in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundStyle(.blue)
                                Text(responsibility)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .onMove(perform: moveExperience)
            .onDelete(perform: deleteExperience)
            .listRowSeparator(.hidden)
        }
        
        
        TextField("Company", text: $newExperience.company)
            .textInputAutocapitalization(.words)
            .textContentType(.organizationName)
            .autocorrectionDisabled()
            .onChange(of: newExperience.company) {_, _ in
                showingError = false
            }
        
        TextField("Position", text: $newExperience.position)
            .autocorrectionDisabled()
            .textContentType(.jobTitle)
            .onChange(of: newExperience.position) {_, _ in
                showingError = false
            }
        
        if showingError {
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
        }
        
        HStack {
            Picker("Start Year", selection: $newExperience.startYear) {
                ForEach(1950...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
            .background(Color.black.opacity(0.1))
            .frame(width: 150, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Picker("End Year", selection: Binding(
                get: { newExperience.endYear ?? Calendar.current.component(.year, from: Date()) },
                set: { newExperience.endYear = $0 }
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
        
        VStack(alignment: .leading, spacing: 12) {
            ForEach(newExperience.responsibilities.indices, id: \.self) { index in
                HStack {
                    Label {
                        Text(newExperience.responsibilities[index])
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    Button(action: {
                        newExperience.responsibilities.remove(at: index)
                    }) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }
            }
            
            HStack {
                TextField("What was your responsibility?", text: $newResponsibility, axis: .vertical)
                    .autocorrectionDisabled()
                
                Button {
                    if !newResponsibility.isEmpty {
                        newExperience.responsibilities.append(newResponsibility)
                        newResponsibility = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.green)
                }
                .disabled(newResponsibility.isEmpty)
            }
            .padding(.top)
        }
        
        Button("Add Experience") {
            if validateNewExperience() {
                professionalHistory.append(newExperience)
                newExperience = ProfessionalExperience(company: "", position: "", startYear: Calendar.current.component(.year, from: Date()), endYear: nil, responsibilities: [])
                showingError = false
            }
        }
        .foregroundStyle(.blue)
    }
    
    func moveExperience(from source: IndexSet, to destination: Int) {
        professionalHistory.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteExperience(at offsets: IndexSet) {
        professionalHistory.remove(atOffsets: offsets)
    }
    
    private func validateNewExperience() -> Bool {
        if newExperience.company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Company name cannot be empty"
            showingError = true
            return false
        }
        
        if newExperience.position.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Position cannot be empty"
            showingError = true
            return false
        }
        
        return true
    }
}


