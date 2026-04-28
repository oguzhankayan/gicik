// Auth helper — extracts user_id from JWT and returns Supabase client.

import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";

export interface AuthContext {
  userId: string;
  client: SupabaseClient;  // user-scoped, RLS enforced
  serviceClient: SupabaseClient;  // service role, bypasses RLS — use sparingly
}

export async function requireAuth(req: Request): Promise<AuthContext> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    throw new AuthError("missing or invalid Authorization header");
  }
  const jwt = authHeader.replace("Bearer ", "");

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !anonKey || !serviceKey) {
    throw new AuthError("supabase env not configured", 500);
  }

  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: `Bearer ${jwt}` } },
    auth: { persistSession: false },
  });

  const { data: { user }, error } = await client.auth.getUser();
  if (error || !user) {
    throw new AuthError("invalid token");
  }

  const serviceClient = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false },
  });

  return { userId: user.id, client, serviceClient };
}

export class AuthError extends Error {
  constructor(public override message: string, public status = 401) {
    super(message);
  }
}
