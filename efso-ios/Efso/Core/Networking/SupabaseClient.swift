import Foundation
import Supabase

/// Supabase singleton — auth + DB + storage + edge functions.
/// Phase 0.5 bootstrap. Gerçek kullanım Phase 1+.
final class SupabaseService: Sendable {
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
    var storage: SupabaseStorageClient { client.storage }
    var functions: FunctionsClient { client.functions }

    /// Postgrest table query — `service.from("profiles").select(...)`
    func from(_ table: String) -> PostgrestQueryBuilder {
        client.from(table)
    }

    /// RPC call — `service.rpc("fn_increment_usage", params: ...)`
    func rpc(_ fn: String, params: some Encodable & Sendable) throws -> PostgrestFilterBuilder {
        try client.rpc(fn, params: params)
    }
}
