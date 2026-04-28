import SwiftUI
import AuthenticationServices
import CryptoKit

/// Sign in with Apple — Phase 0 sonu DoD: bu ekrandan giriş yapılınca HomeView gösterilmeli.
struct SignInView: View {
    @State private var auth = AuthService.shared
    @State private var currentNonce: String?
    @State private var error: String?
    @State private var showEmailSheet = false

    var body: some View {
        VStack {
            Spacer()
            Logo(size: 88)
            Text("yazma. gıcık yazsın.")
                .font(AppFont.body(16))
                .foregroundColor(AppColor.text60)
                .padding(.top, 28)
            Spacer()

            SignInWithAppleButton(.signIn, onRequest: prepare, onCompletion: handle)
                .signInWithAppleButtonStyle(.white)
                .frame(height: 56)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.button, style: .continuous))
                .padding(.horizontal, 24)

            // Test path (Phase 2). Phase 6'da gizlenir.
            Button {
                showEmailSheet = true
            } label: {
                Text("e-posta ile giriş")
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.text40)
                    .underline()
            }
            .padding(.top, 14)

            if let error {
                Text(error)
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.danger)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.horizontal, 24)
            }

            Text("giriş yaparak şartları kabul ediyorsun")
                .font(AppFont.body(12))
                .foregroundColor(AppColor.text40)
                .padding(.top, 14)
                .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showEmailSheet) {
            EmailSignInSheet(onSuccess: { showEmailSheet = false })
                .presentationDetents([.medium])
                .presentationBackground(AppColor.bg0)
        }
    }

    private func prepare(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    private func handle(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let err):
            error = err.localizedDescription
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                error = "apple sign in başarısız"
                return
            }

            Task {
                do {
                    try await auth.signInWithApple(idToken: idToken, nonce: nonce)
                    if let userIDStr = credential.user as String? {
                        KeychainManager.save(userIDStr, for: .appleSignInUserID)
                    }
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var byte: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &byte)
                return byte
            }
            for r in randoms where remaining > 0 {
                if r < charset.count {
                    result.append(charset[Int(r)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

#Preview {
    SignInView()
        .background(CosmicBackground())
        .preferredColorScheme(.dark)
}
