
import SwiftUI

struct CustomCVPromo: View {
    @Environment(StoreKitViewModel.self) private var storeViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image("customCV")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .shadow(color: .gray, radius: 1)
                
                lockedOverlay
            }
            .padding()
            .containerRelativeFrame(.horizontal)
            .task {
                if storeViewModel.products.isEmpty {
                    Task {
                        await storeViewModel.loadProducts()
                    }
                }
            }
        }
    }
    
    private var lockedOverlay: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("Unlock the ability to create custom sections for your CV!")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if let customCVProduct = storeViewModel.products.first(where: { $0.id == "customCV" }) {
                Button(action: {
                    Task {
                        await storeViewModel.purchase(product: customCVProduct)
                    }
                }) {
                    Text("Unlock for \(customCVProduct.displayPrice)")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .disabled(storeViewModel.purchaseViewState == .purchasing)
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            } else {
                ProgressView()
            }
        }
        .padding([.top, .bottom])
    }
}

#Preview {
    CustomCVPromo()
        .environment(StoreKitViewModel())
}
