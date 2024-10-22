
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
            }
            .containerRelativeFrame(.horizontal)
            .padding(.top)
            .overlay(alignment: .bottom) {
                lockedOverlay
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.orange)
                    .padding(30)
            }
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
        VStack {
            if let customCVProduct = storeViewModel.products.first(where: { $0.id == "customCV" }) {
                Button(action: {
                    Task {
                        await storeViewModel.purchase(product: customCVProduct)
                        storeViewModel.purchaseViewState = .ready
                    }
                }) {
                    Text("Unlock for \(customCVProduct.displayPrice)")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .disabled(storeViewModel.purchaseViewState == .purchasing)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            } else {
                ProgressView()
            }
        }
        .padding([.top, .bottom])
        .padding(.bottom, 30)
    }
}

#Preview {
    CustomCVPromo()
        .environment(StoreKitViewModel())
}
