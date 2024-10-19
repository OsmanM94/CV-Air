
import SwiftUI

struct CombinedSavedCVsView: View {
    @State private var selectedCVType: CVType = .standard
    
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
                
                if selectedCVType == .standard {
                    SavedStandardCVsView()
                } else {
                    SavedCustomCVsView()
                }
            }
            .navigationTitle("Saved CVs")
        }
    }
}

#Preview {
    CombinedSavedCVsView()
}
