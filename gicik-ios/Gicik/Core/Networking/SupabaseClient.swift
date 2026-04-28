import Foundation
import Supabase

/// Supabase singleton — auth + DB + storage + edge functions.
/// Phase 0.5 bootstrap. Gerçek kullanım Phase 1+.
final class SupabaseService {
    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: Configuration.supabaseURL,
            supabaseKey: Configuration.supabaseAnonKey,
            options: .init(
                auth: .init(
                    flowType: .pkce,
                    autoRefreshToken: true
                )
            )
        )
    }

    var auth: AuthClient { client.auth }
    var db: PostgrestClient { client.database }
    var storage: SupabaseStorageClient { client.storage }
    var functions: FunctionsClient { client.functions }
}
