import SwiftUI

/// Phase 0 placeholder. Phase 2.5'te 5 mode kartı + history ile değiştirilir.
struct HomeView: View {
    @State private var auth = AuthService.shared

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Logo(size: 56)
            Text("hoş geldin")
                .font(AppFont.display(28, weight: .bold))
                .foregroundColor(.white)
            if let id = auth.userID {
                Text(id.uuidString)
                    .font(AppFont.mono(11))
                    .foregroundColor(AppColor.text40)
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Text("phase 0 — buradan sonra mode kartları gelecek")
                .font(AppFont.body(13))
                .italic()
                .foregroundColor(AppColor.text40)
            PrimaryButton("çıkış yap", style: .holoBorder) {
                Task { await auth.signOut() }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
