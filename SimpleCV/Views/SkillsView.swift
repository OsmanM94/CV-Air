//
//  SkillsView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI

struct SkillsView: View {
    @Binding var skills: [String]
    @State private var newSkill = ""
    
    var body: some View {
        List {
            ForEach(skills, id: \.self) { skill in
                Text(skill)
            }
            .onMove(perform: moveSkills)
            .onDelete(perform: deleteSkill)
        }
        
        HStack {
            TextField("What's your skill?", text: $newSkill)
            Button(action: {
                addSkill()
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.green)
                    .imageScale(.large)
            })
            .disabled(newSkill.isEmpty)
            .foregroundStyle(.blue)
        }
    }
    
    func moveSkills(from source: IndexSet, to destination: Int) {
        skills.move(fromOffsets: source, toOffset: destination)
    }
    
    func addSkill() {
        if !newSkill.isEmpty {
            skills.append(newSkill)
            newSkill = ""
        }
    }
    
    func deleteSkill(at offsets: IndexSet) {
        skills.remove(atOffsets: offsets)
    }
}

