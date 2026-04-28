# gicik-backend

Supabase + Edge Functions (Deno + TypeScript).

## Yapı

```
supabase/
├── config.toml                    # local + deploy config
├── migrations/
│   ├── 20260101000000_initial_schema.sql
│   └── 20260101000100_storage_screenshots.sql
└── functions/
    ├── _shared/                   # cors, auth, types
    ├── calibrate/                 # ✅ scaffold (deriveArchetype hazır)
    ├── parse-screenshot/          # 🚧 stub — Phase 2.3
    ├── generate-replies/          # 🚧 stub — Phase 2.4
    ├── prompt-feedback/           # ✅ scaffold
    ├── cleanup-storage/           # ✅ scaffold (cron)
    └── revenuecat-webhook/        # 🚧 Phase 4.4

prompts/
├── L0_identity.tr.md              # asistan sesi
├── L1_modes/                      # 5 mode prompt'u
├── L2_constraints.tr.md           # security + ethics
├── L3_output_schemas.json         # stage1 + stage2 JSON schema
├── L4_runtime_template.tr.md      # runtime variables
├── tones/                         # 5 tone prompt'u
└── stage1_parser.md               # Gemini system prompt

eval/
└── golden-set.json                # 50 senaryo (Phase 2 sonu)
```

## Local geliştirme

```bash
# 1. Supabase CLI kur (https://supabase.com/docs/guides/local-development)
brew install supabase/tap/supabase

# 2. Proje root'undan
cd gicik-backend
supabase start              # local Postgres + Studio + Auth
supabase db reset           # migrations'ı uygula

# 3. Env vars
cp .env.example .env.local
# ANTHROPIC_API_KEY, GEMINI_API_KEY, OPENAI_API_KEY (failover)

# 4. Edge function local dev
supabase functions serve calibrate --env-file .env.local
```

## Deploy

```bash
# Production'a (kez login ol)
supabase login
supabase link --project-ref <project-ref>

supabase db push                                 # migrations
supabase functions deploy calibrate
supabase functions deploy parse-screenshot
supabase functions deploy generate-replies
supabase functions deploy prompt-feedback
supabase functions deploy cleanup-storage

# Secrets
supabase secrets set ANTHROPIC_API_KEY=...
supabase secrets set GEMINI_API_KEY=...
```

## API Contracts

Tam contract'lar `prompt.md §7`'de. Özet:

| Endpoint | Auth | Phase | Status |
|---|---|---|---|
| `POST /functions/v1/calibrate` | JWT | 1.4 | scaffold ✅ |
| `POST /functions/v1/parse-screenshot` | JWT | 2.3 | stub |
| `POST /functions/v1/generate-replies` | JWT (SSE stream) | 2.4 | stub |
| `POST /functions/v1/prompt-feedback` | JWT | 2.7 | scaffold ✅ |
| `POST /functions/v1/cleanup-storage` | service-role | 0.2 | scaffold ✅ |

## Prompt versioning

`prompts/` dosyaları `prompt_versions` tablosuna `seed-prompts.ts` ile yüklenir (Phase 2.1). Aktif version'ı edge function'ı `_shared/prompt-loader.ts` ile çeker.
