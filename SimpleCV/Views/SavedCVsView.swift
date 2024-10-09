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
    @State private var showingShareSheet: Bool = false
    @State private var isGeneratingPDF: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        CVFormView(cv: cv, onSave: updateCV, isNewCV: false)
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    EditButton()
                    
                    Button(action: {
                        generateAndExportPDF()
                    }) {
                        HStack {
                            if isGeneratingPDF {
                                ProgressView()
                                    
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                    .disabled(isGeneratingPDF)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let data = cv.pdfData {
                    ShareSheet(activityItems: [data])
                }
            }
    }
    
    private func updateCV() {
        do {
            try modelContext.save()
        } catch {
            print("Error updating CV: \(error)")
        }
    }
    
    private func generateAndExportPDF() {
        isGeneratingPDF = true
        
        Task {
            let pdfData = await CVPDFGenerator.generatePDF(for: cv)
            await MainActor.run {
                cv.pdfData = pdfData
                isGeneratingPDF = false
                showingShareSheet = true
            }
        }
    }
}

struct TimeoutError: Error {}

#Preview {
    SavedCVsView()
}
