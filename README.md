# efso

Türkiye-first AI iletişim koçu. iOS-only MVP. Apple Review için "iletişim koçu" olarak pozisyonlanır; dating-first ama %30+ non-dating demo content zorunlu.

## Repo yapısı

```
efso/
├── prompt.md                # Master prompt (Oğuzhan'ın brief'i)
├── CLAUDE.md                # Claude Code context (= prompt.md)
├── BUILD_PLAN.md            # Phase 0-7, commit-by-commit task listesi
├── README.md                # bu dosya
├── .gitignore
│
├── efso-ios/               # SwiftUI iOS app
│   ├── SETUP.md             # 5-10 dk Xcode kurulum
│   ├── README.md
│   ├── project.yml          # xcodegen spec
│   ├── Debug.xcconfig.template
│   ├── Release.xcconfig.template
│   ├── Efso/
│   │   ├── App/             # entry, config, root
│   │   ├── DesignSystem/    # tokens + 9 component + katalog
│   │   ├── Features/        # auth, onboarding, main, modes, profile
│   │   ├── Core/            # networking, auth, analytics
│   │   ├── Models/
│   │   └── Resources/
│   │       └── design-source/   # Claude Design canonical export
│   ├── EfsoTests/
│   └── EfsoUITests/
│
└── efso-backend/           # Supabase + Edge Functions
    ├── README.md
    └── supabase/
        ├── config.toml
        ├── migrations/      # 5 tablo + storage + RLS
        ├── functions/       # 5 edge function
        └── prompts/         # L0-L4 + 5 mode + 5 tone + stage1 parser
```

## Hızlı başlangıç

1. **Backend kur**: `efso-backend/README.md` — Supabase project + migrations + edge functions
2. **iOS kur**: `efso-ios/SETUP.md` — Xcodegen ile 5-10 dakikada hazır
3. **Build başlat**: `BUILD_PLAN.md` Phase 1'den itibaren

## Phase durumu

| Phase | Durum |
|---|---|
| 0 — Bootstrap | ✅ Scaffold tamam, kullanıcı SETUP.md'yi takip etmeli |
| 1 — Onboarding | ⏳ Sonraki |
| 2 — Vision Pipeline | ⏳ |
| 3 — Modes | ⏳ |
| 4 — Subscription | ⏳ |
| 5 — Polish | ⏳ |
| 6 — TestFlight | ⏳ |
| 7 — Post-launch | ⏳ |

## Stack özeti

**iOS:** SwiftUI · iOS 17+ · Swift 6 · MV pattern · Swift Concurrency · StoreKit 2 + RevenueCat · Supabase Swift SDK · Lottie · PostHog/Sentry/Mixpanel

**Backend:** Supabase (Postgres + Auth + Storage + Edge Functions) · Deno + TypeScript · RLS-on every table · Cron retention

**LLM:**
- Stage 1 parse: Gemini 2.5 Flash (vision + JSON)
- Stage 2 generate: Claude Sonnet 4.5 (streaming + prompt caching ~75% cost↓)
- Failover: GPT-5

## License

Proprietary — © 2026 Oğuzhan Kayan
