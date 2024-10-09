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
    
    var body: some View {
        List {
            ForEach(educationalHistory, id: \.id) { education in
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
        
        TextField("Degree", text: $newEducation.degree)
            .autocorrectionDisabled()
        
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
            educationalHistory.append(newEducation)
            newEducation = Education(institution: "", degree: "", startYear: Calendar.current.component(.year, from: Date()), endYear: nil, details: "")
        }
        .disabled(newEducation.institution.isEmpty || newEducation.degree.isEmpty)
        .foregroundStyle(.blue)
    }
    
    func moveEducation(from source: IndexSet, to destination: Int) {
        educationalHistory.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteEducation(at offsets: IndexSet) {
        educationalHistory.remove(atOffsets: offsets)
    }
    
    func formatYearRange(start: Int, end: Int?) -> String {
        if let end = end {
            return "\(start) - \(end)"
        } else {
            return "\(start) - Present"
        }
    }
}

