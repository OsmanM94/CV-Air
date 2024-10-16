

import SwiftUI

struct MarketingView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color(.systemGray6))
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Simple, ATS-Friendly, and ready to impress!")
                Text("")
                Text("You might be tempted to create a flashy CV, but the reality is that many Applicant Tracking Systems (ATS) struggle to read fancy formats.")
                Text("")
                Text("My app ensures your CV is ATS-compliant, so it won't be missed by potential employers. Simple, effective, and right on their desk, just the way it should be!")
                    
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            
        }
    }
}

#Preview {
    MarketingView()
}
