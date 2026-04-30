import SwiftUI

/// Test giriş yolu — Phase 2 wiring testleri için.
/// Phase 6'da Apple SSO yeterli olunca bu sheet gizlenir.
struct EmailSignInSheet: View {
    @State private var auth = AuthService.shared
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var isLoading = false
    @State private var isSignUp = false
    let onSuccess: () -> Void

    /// Klavye odak yönetimi — email→password tab order + toolbar dismiss.
    @FocusState private var focused: Field?
    private enum Field: Hashable { case email, password }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(isSignUp ? "yeni hesap" : "e-posta ile giriş")
                .font(AppFont.display(22, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 24)

            VStack(spacing: 12) {
                TextField("", text: $email, prompt: Text("e-posta").foregroundColor(AppColor.text30))
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focused = .password }
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.bg1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(AppColor.text10, lineWidth: 1)
                            )
                    )

                SecureField("", text: $password, prompt: Text("şifre").foregroundColor(AppColor.text30))
                    .focused($focused, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        focused = nil
                        Task { await submit() }
                    }
                    .textContentType(isSignUp ? .newPassword : .password)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(AppColor.bg1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(AppColor.text10, lineWidth: 1)
                            )
                    )
            }

            if let error {
                Text(error)
                    .font(AppFont.body(13))
                    .foregroundColor(AppColor.danger)
            }

            PrimaryButton(isSignUp ? "kayıt ol" : "giriş",
                          isEnabled: !email.isEmpty && password.count >= 6 && !isLoading) {
                Task { await submit() }
            }

            Button(isSignUp ? "hesabım var, giriş yap" : "hesabım yok, kayıt ol") {
                isSignUp.toggle()
                error = nil
            }
            .font(AppFont.body(13))
            .foregroundColor(AppColor.text40)
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("bitti") { focused = nil }
            }
        }
    }

    private func submit() async {
        error = nil
        isLoading = true
        defer { isLoading = false }
        do {
            if isSignUp {
                try await auth.signUpWithEmail(email: email, password: password)
            } else {
                try await auth.signInWithEmail(email: email, password: password)
            }
            if auth.isSignedIn {
                onSuccess()
            } else {
                // signUp may require email confirmation; show hint
                error = "kayıt başarılı. e-posta onay linkini açıp tekrar giriş yap."
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
