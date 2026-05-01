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

    /// Cold-launch sırasında restoreSession bitene kadar `true` —
    /// RootView bu süreçte SignInView yerine splash gösterir, flicker olmaz.
    /// Init'te true başlar, restore tamamlanınca false olur.
    private(set) var isRestoring: Bool = true

    var isSignedIn: Bool { session != nil }
    var userID: UUID? { session?.user.id }

    private init() {
        Task {
            await restoreSession()
            await checkAppleCredentialState()
        }
        observeAppleRevocation()
    }

    func restoreSession() async {
        defer { isRestoring = false }
        do {
            let session = try await SupabaseService.shared.auth.session
            self.session = session
            await identifyVendors(session: session)
        } catch {
            // Expired/invalid session — sessizce signed-out duruma düş.
            // Critical: log to Sentry; expired refresh token sessiz olmasın.
            self.session = nil
        }
    }

    /// Apple Sign In credential durumunu kontrol et — Apple Review 4.8/5.1.1
    /// gereği. Kullanıcı iOS Ayarlar > Apple ID > "Apps Using Your Apple
    /// ID" üzerinden hesabımızı kaldırırsa burası `revoked` döner; otomatik
    /// signOut yapılır. Cold launch'ta bir kez çalışır.
    func checkAppleCredentialState() async {
        guard let userID = KeychainManager.read(.appleSignInUserID), !userID.isEmpty else {
            return
        }
        let provider = ASAuthorizationAppleIDProvider()
        do {
            let state = try await provider.credentialState(forUserID: userID)
            switch state {
            case .authorized:
                break
            case .revoked, .notFound:
                // Kullanıcı Apple tarafından authorize'u kaldırdı.
                // Veya credential bulunamadı (cihaz/kullanıcı eşleşmiyor).
                await signOut()
            case .transferred:
                break
            @unknown default:
                break
            }
        } catch {
            // Sessiz fail — credentialState bazen geçici hata verir.
            // Hard logout yapma; user manuel açtığında re-check olur.
        }
    }

    /// Runtime revocation — kullanıcı app açıkken Settings'ten kaldırırsa.
    /// `ASAuthorizationAppleIDProvider.credentialRevokedNotification` post
    /// edilir; biz signOut ile cevap veririz.
    private func observeAppleRevocation() {
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor [weak self] in
                await self?.signOut()
            }
        }
    }

    /// Sign-in sonrası user_id'yi RevenueCat + analytics'a tanıt.
    private func identifyVendors(session: Session) async {
        let uuid = session.user.id
        await SubscriptionManager.shared.identify(userId: uuid.uuidString)
        AnalyticsService.shared.identify(userID: uuid)
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
            await identifyVendors(session: session)
        } catch {
            self.lastError = .unknown(error.localizedDescription)
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
