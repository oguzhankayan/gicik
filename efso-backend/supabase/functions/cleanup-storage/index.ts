// Cron job — runs daily 03:00 UTC
// Deletes screenshots older than 24 hours from storage + nullifies path on conversations rows.
// Called by pg_cron with service-role bearer.

import { preflightOk, jsonResponse, errorResponse } from "../_shared/cors.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return preflightOk();

  // Service role only
  const auth = req.headers.get("Authorization") ?? "";
  const expected = `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""}`;
  if (auth !== expected) {
    return errorResponse("unauthenticated", "service role only", 401);
  }

  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const client = createClient(url, key, { auth: { persistSession: false } });

  const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

  // Find old conversations with non-null screenshot_storage_path
  const { data: oldRows, error: selectErr } = await client
    .from("conversations")
    .select("id, screenshot_storage_path")
    .lt("created_at", cutoff)
    .not("screenshot_storage_path", "is", null);

  if (selectErr) {
    return errorResponse("internal", `select failed: ${selectErr.message}`, 500);
  }

  const paths = (oldRows ?? []).map((r) => r.screenshot_storage_path).filter(Boolean) as string[];
  let deleted = 0;
  let failed = 0;

  if (paths.length > 0) {
    const { data: removeData, error: removeErr } = await client.storage
      .from("screenshots")
      .remove(paths);

    if (removeErr) {
      console.error("storage remove error", removeErr);
      failed = paths.length;
    } else {
      deleted = removeData?.length ?? 0;
    }

    // Null out paths regardless (DB hygiene)
    const ids = (oldRows ?? []).map((r) => r.id);
    await client
      .from("conversations")
      .update({ screenshot_storage_path: null })
      .in("id", ids);
  }

  // ─── Step 2: 30-day conversation data cleanup ───
  // CLAUDE.md mandate: conversations 30 gün tutulur. Row'u silmiyoruz (history
  // metadata kalır), parse_result ve generation_result null'lanır.
  const cutoff30d = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString();

  const { data: oldConvs, error: oldConvErr } = await client
    .from("conversations")
    .select("id")
    .lt("created_at", cutoff30d)
    .or("parse_result.neq.null,generation_result.neq.null");

  let conversationsCleaned = 0;
  if (oldConvErr) {
    console.error("30d conversation select failed", oldConvErr.message);
  } else if (oldConvs && oldConvs.length > 0) {
    const ids = oldConvs.map((r) => r.id);
    const { error: updateErr } = await client
      .from("conversations")
      .update({ parse_result: null, generation_result: null })
      .in("id", ids);

    if (updateErr) {
      console.error("30d conversation cleanup update failed", updateErr.message);
    } else {
      conversationsCleaned = ids.length;
      console.log(`30d cleanup: nullified parse/generation data for ${conversationsCleaned} conversations`);
    }
  }

  return jsonResponse({ ok: true, deleted, failed, scanned: paths.length, conversations_cleaned: conversationsCleaned });
});
