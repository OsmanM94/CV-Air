

import SwiftUI
import SwiftData

struct SavedCustomCVsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedCustomCVs: [CustomCV]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(savedCustomCVs, id: \.id) { customCV in
                    NavigationLink(destination: CustomCVDetailView(customCV: customCV)) {
                        Text(customCV.personalInfo.name)
                    }
                }
                .onDelete(perform: deleteCustomCVs)
            }
            .overlay {
                if savedCustomCVs.isEmpty {
                    ContentUnavailableView("Empty", systemImage: "tray.fill")
                }
            }
            .toolbar {
                EditButton()
                    .disabled(savedCustomCVs.isEmpty)
            }
        }
    }
    
    private func deleteCustomCVs(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(savedCustomCVs[index])
            }
        }
    }
}

struct CustomCVDetailView: View {
    @Bindable var customCV: CustomCV
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        CustomCVFormView(customCV: customCV, onSave: updateCustomCV, isNewCV: false)
            .navigationTitle("Edit")
    }
    
    private func updateCustomCV() {
        do {
            try modelContext.save()
        } catch {
            print("Error updating Custom CV: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        SavedCustomCVsView()
    }
}
