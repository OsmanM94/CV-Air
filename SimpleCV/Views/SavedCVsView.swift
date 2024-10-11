//
//  SavedCVsView.swift
//  SimpleCV
//
//  Created by asia on 08.10.2024.
//

import SwiftUI
import SwiftData

struct SavedCVsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedCVs: [CV]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(savedCVs, id: \.id) { cv in
                    NavigationLink(destination: CVDetailView(cv: cv)) {
                        Text(cv.personalInfo.name)
                    }
                }
                .onDelete(perform: deleteCVs)
            }
            .navigationTitle("Saved CVs")
            .overlay {
                if savedCVs.isEmpty {
                    ContentUnavailableView("Empty", systemImage: "tray.fill")
                }
            }
            .toolbar {
                EditButton()
                    .disabled(savedCVs.isEmpty)
            }
        }
    }
    
    private func deleteCVs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(savedCVs[index])
            }
        }
    }
}

struct CVDetailView: View {
    @Bindable var cv: CV
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        CVFormView(cv: cv, onSave: updateCV, isNewCV: false)
            .navigationTitle("Edit")
    }
    
    private func updateCV() {
        do {
            try modelContext.save()
        } catch {
            print("Error updating CV: \(error)")
        }
    }
}

#Preview {
    SavedCVsView()
}
