
import SwiftUI
import SwiftData

struct CombinedSavedCVsView: View {
    @State private var selectedCVType: CVType = .standard
    @Environment(\.colorScheme) private var colorScheme
    
    @Query private var savedCustomCVs: [CustomCV]
    @Query private var standardCVs: [CV]
    
    enum CVType {
        case standard, custom
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("CV Type", selection: $selectedCVType) {
                    Text("Standard").tag(CVType.standard)
                    Text("Custom").tag(CVType.custom)
                }
                .pickerStyle(.segmented)
                .padding()
              
                selectedCV
    
            }
            .background(backgroundStyle)
            .navigationTitle("Saved")
            .toolbarBackground(backgroundStyle, for: .navigationBar)
        }
    }
    
    @ViewBuilder
    private var selectedCV: some View {
        switch selectedCVType {
        case .standard:
            SavedStandardCVsView()
        case .custom:
            SavedCustomCVsView()
        }
    }
    
    private var backgroundStyle: Color {
        if (selectedCVType == .standard && standardCVs.isEmpty) ||
            (selectedCVType == .custom && savedCustomCVs.isEmpty) {
            return colorScheme == .light ? .white : .clear
        } else {
            return colorScheme == .light ? Color(.systemGray6) : .clear
        }
    }
}

#Preview {
    CombinedSavedCVsView()
}
