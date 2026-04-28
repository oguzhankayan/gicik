import Foundation
import AuthenticationServices
import Supabase

/// Auth service — Sign in with Apple → Supabase auth bridge.
@Observable
@MainActor
final class AuthService {
    static let shared = AuthService()

    private(set) var session: Session?
    private(set) var isLoading = false
    private(set) var lastError: APIError?

    var isSignedIn: Bool { session != nil }
    var userID: UUID? { session?.user.id }

    private init() {
        Task { await restoreSession() }
    }

    func restoreSession() async {
        do {
            let session = try await SupabaseService.shared.auth.session
            self.session = session
        } catch {
            self.session = nil
        }
    }

    /// Sign in with Apple. Caller, ASAuthorizationAppleIDCredential ile döner.
    /// Apple ID provider Supabase dashboard'da aktif olmalı.
    func signInWithApple(idToken: String, nonce: String) async throws {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await SupabaseService.shared.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )
            self.session = session
        } catch {
            self.lastError = .unknown(String(describing: error))
            throw error
        }
    }

    func signOut() async {
        try? await SupabaseService.shared.auth.signOut()
        self.session = nil
        KeychainManager.delete(.appleSignInUserID)
        KeychainManager.delete(.supabaseSession)
    }

    // MARK: - Email (test path; Apple SSO kalır)

    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        let session = try await SupabaseService.shared.auth.signIn(email: email, password: password)
        self.session = session
    }

    func signUpWithEmail(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        let response = try await SupabaseService.shared.auth.signUp(email: email, password: password)
        if let session = response.session {
            self.session = session
        }
    }
}
