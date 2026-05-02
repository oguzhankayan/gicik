// Wildcard CORS is acceptable here: Supabase Edge Functions are invoked by
// the iOS app (not a browser origin we control) and all mutation endpoints
// require a valid JWT in the Authorization header. The real auth boundary is
// the JWT, not the Origin header — restricting origins would add no security
// benefit and would break mobile clients.
export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

export function preflightOk(): Response {
  return new Response("ok", { headers: corsHeaders });
}

export function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function errorResponse(
  code: string,
  message: string,
  status = 400,
  details?: unknown,
): Response {
  return jsonResponse({ error: { code, message, details } }, status);
}
