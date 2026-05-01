# efso-backend

Supabase + Edge Functions (Deno + TypeScript). Tüm modlar end-to-end çalışıyor, prod live.

## Yapı

```
supabase/
├── config.toml                            # local + deploy config (project_id: efso)
├── migrations/
│   ├── 20260101000000_initial_schema.sql  # 6 tablo + RLS
│   ├── 20260101000100_storage_screenshots.sql
│   ├── 20260429000000_add_tonla_mode.sql
│   └── 20260501000000_schedule_cleanup_cron.sql  # pg_cron + vault
└── functions/
    ├── _shared/                           # cors, auth, types, llm-client,
    │                                       # prompt-loader, dates (TR TZ)
    ├── parse-screenshot/                  # ✅ vision parse + manual_input branch
    ├── generate-replies/                  # ✅ SSE streaming + cost ceiling
    ├── calibrate/                         # ✅ deterministik arketip
    ├── delete-account/                    # ✅ Apple 5.1.1 in-app deletion
    ├── cleanup-storage/                   # ✅ 24h ss + 30g conversation cleanup
    ├── create-text-conversation/          # ✅ tonla draft entry
    ├── prompt-feedback/                   # ✅ 👍👎 + reply index
    └── revenuecat-webhook/                # ✅ deployed, canlı test bekliyor

prompts/
├── L0_identity.tr.md                      # asistan sesi (genz tempo, sokak zekası)
├── L1_modes/{cevap,acilis,tonla,davet}.tr.md
├── L2_constraints.tr.md                   # security + ethics
├── L3_output_schemas.json                 # stage1 + stage2 JSON
├── L4_runtime_template.tr.md
├── archetypes/                            # 6 archetype prompt
├── tones/                                 # 5 tone prompt
└── stage1_parser.md                       # vision system prompt

scripts/
├── seed-prompts.ts                        # prompts/ → prompt_versions table
├── test-acilis.ts                         # 4 archetype × 4 profil eval
├── test-davet.ts                          # 4 archetype × 4 chat senaryo
├── test-tonla.ts                          # 4 archetype × 4 taslak senaryo
├── test-matrix.ts                         # cevap × archetype × tone matrisi
├── test-archetypes.ts
└── test-tones.ts
```

## Local geliştirme

```bash
brew install supabase/tap/supabase
cd efso-backend

cp .env.example .env.local
# ANTHROPIC_API_KEY, GEMINI_API_KEY, OPENAI_API_KEY (failover),
# SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

supabase start              # local Postgres + Studio + Auth
supabase db reset           # migrations apply

supabase functions serve generate-replies --env-file .env.local
```

## Deploy

```bash
supabase login
supabase link --project-ref <project-ref>

supabase db push
deno run --allow-read --allow-net --allow-env scripts/seed-prompts.ts

for fn in parse-screenshot generate-replies calibrate delete-account \
          cleanup-storage prompt-feedback create-text-conversation \
          revenuecat-webhook; do
  supabase functions deploy "$fn"
done

# Secrets
supabase secrets set ANTHROPIC_API_KEY=... GEMINI_API_KEY=...
```

### Bir kerelik post-deploy (Supabase Dashboard SQL Editor)

```sql
-- 1. Extensions ON: Database → Extensions → pg_cron + pg_net

-- 2. Vault: Project Settings → Vault → Add secret:
--    name: service_role_key, value: <SERVICE_ROLE_KEY>
select vault.create_secret('<SERVICE_ROLE_KEY>', 'service_role_key',
                          'For pg_cron jobs to call edge functions');

-- 3. Cron schedule
select cron.schedule(
    'cleanup-old-screenshots',
    '0 3 * * *',
    $$ select net.http_post(
        url := 'https://<PROJECT-REF>.supabase.co/functions/v1/cleanup-storage',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' ||
              (select decrypted_secret from vault.decrypted_secrets
               where name = 'service_role_key' limit 1)
        )
    ); $$
);

-- Kontrol:
select * from cron.job;
```

## API Contracts

Detay: edge function dosyalarındaki Request/Response interfaces.

| Endpoint | Auth | Status |
|---|---|---|
| `POST /functions/v1/calibrate` | JWT | ✅ live |
| `POST /functions/v1/parse-screenshot` | JWT (multipart, opt manual_input JSON) | ✅ live |
| `POST /functions/v1/generate-replies` | JWT (SSE stream) | ✅ live |
| `POST /functions/v1/create-text-conversation` | JWT (tonla) | ✅ live |
| `POST /functions/v1/delete-account` | JWT | ✅ live |
| `POST /functions/v1/prompt-feedback` | JWT | ✅ live |
| `POST /functions/v1/revenuecat-webhook` | RC signature | ✅ deployed (canlı test) |
| `POST /functions/v1/cleanup-storage` | service-role | ✅ live (cron) |

## Prompt versioning

`prompts/` dosyaları `prompt_versions` tablosuna `seed-prompts.ts` ile yüklenir. Aktif version'ı edge function'ı `_shared/prompt-loader.ts` ile çeker. A/B + rollback DB üzerinden mümkün, version tablosu kalır.

## Eval scripts

Her mode için ayrı matrix. 4 archetype × 4 senaryo, gerçek Anthropic API çağrısı:

```bash
deno run --allow-read --allow-net --allow-env scripts/test-acilis.ts
deno run --allow-read --allow-net --allow-env scripts/test-davet.ts
deno run --allow-read --allow-net --allow-env scripts/test-tonla.ts
deno run --allow-read --allow-net --allow-env scripts/test-matrix.ts   # cevap
```

Voice pivot (genz/viral) sonrası hepsi re-run edilmeli — output kalitesi tutuyor mu doğrula.

## Önemli detaylar

- **Cost ceiling:** generate-replies'da `usage_daily.llm_cost_usd >= $0.50` → 429 (server-side hard cap, premium dahil).
- **Quota truth:** `done` event'inde `remaining_today` + `is_premium` → client server-truth kullanır, lokal history fallback.
- **Manual input branch:** parse-screenshot `manual_input` form field'ı varsa vision skip + synthetic ParseResult.
- **TZ:** "bugün" boundary `Europe/Istanbul` (`_shared/dates.ts`).
- **SSE drop:** generate-replies 3 reply garanti etmez (LLM fail durumu); client-side guard partial result reddediyor.
- **Account deletion (Apple 5.1.1):** `delete-account` storage + 6 tablo + auth.users sırayla siler.
