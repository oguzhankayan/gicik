# efso-ios

SwiftUI iOS uygulaması. iOS 17+, Swift 6, MV pattern.

## İlk kurulum

📖 **[SETUP.md](SETUP.md)** — sıfırdan Xcode projesini ayağa kaldırma (5-10 dakika).

## Proje yapısı

```
Efso/
├── App/
│   ├── EfsoApp.swift              # @main entry, Sentry/Analytics bootstrap
│   ├── AppDelegate.swift           # push notification, deep link
│   ├── Configuration.swift         # env vars (xcconfig'den)
│   └── RootView.swift              # auth state router
│
├── DesignSystem/
│   ├── Colors.swift                # AppColor (cosmic black + holographic)
│   ├── Typography.swift            # AppFont (display/body/mono)
│   ├── Spacing.swift               # 4-point grid + AppRadius
│   ├── Animations.swift            # spring + custom curves
│   ├── CosmicBackground.swift      # full-screen bg
│   ├── Color+Hex.swift             # Color(hex: 0xFF0080)
│   ├── DesignSystemCatalogView.swift  # canlı katalog
│   └── Components/
│       ├── Logo.swift              # Y2K, holographic dot
│       ├── PrimaryButton.swift     # 3 stil: solid / holoBorder / holoFill
│       ├── SecondaryButton.swift
│       ├── Chip.swift              # pill + selected state
│       ├── ProgressDots.swift
│       ├── TopBar.swift
│       ├── ObservationCard.swift   # asistan sesi (italik + lime stripe)
│       ├── ReplyCard.swift         # output sesi (mono + copy + thumbs)
│       ├── GlassCard.swift         # modifier
│       └── LoadingShimmer.swift    # skeleton
│
├── Features/
│   ├── Auth/SignInView.swift       # Sign in with Apple
│   ├── Onboarding/                 # Phase 1
│   ├── Main/                       # Phase 2 — HomeView, picker, tone, gen, result
│   ├── Modes/                      # Phase 3 — 5 mod
│   ├── Profile/                    # Phase 3
│   └── Settings/                   # Phase 5
│
├── Core/
│   ├── Networking/                 # SupabaseClient, APIError, Endpoints
│   ├── Auth/                       # AuthService, KeychainManager
│   ├── Storage/UserDefaultsKeys.swift
│   ├── Subscription/               # Phase 4 — RevenueCat
│   └── Analytics/                  # AnalyticsService, EventNames
│
├── Models/                         # User, Conversation, Tone, Mode (Phase 1+)
└── Resources/
    ├── Fonts/                      # SpaceGrotesk, JetBrainsMono
    ├── Lottie/                     # calibration-reveal.json (Phase 1.5)
    └── design-source/              # Claude Design canonical export (read-only)
```

## Phase 0 durumu

✅ Tamamlanan:
- Repo yapısı + .gitignore
- DesignSystem tam (token + 9 component + canlı katalog)
- Configuration / SupabaseClient / AuthService scaffolds
- App entry + RootView + SignInView (Apple SSO) + HomeView placeholder
- xcodegen `project.yml` + xcconfig template'leri + SETUP.md

⚠️ Senin yapacakların:
- `SETUP.md`'yi takip et — Xcode projesi üret, dependencies çek, build
- Supabase backend deploy (`efso-backend/README.md`)
- Apple Developer Team ID + Apple Sign In configuration
- Fonts indir + Resources/Fonts/'a koy

## Geliştirme prensipleri

`prompt.md §14` ve `BUILD_PLAN.md` her iki Claude Code oturumunda okunmalı.

- Türkçe yorum, İngilizce identifier
- Her PR küçük + focused
- Test: Models, ViewModels, API client zorunlu
- SwiftUI body içinde ağır iş yok
- async/await ağırlık, Combine sadece UI binding
- typed errors, `catch { }` boş bloğu YOK
- `os_log` structured logging, `print` yasak
- Sentry breadcrumbs önemli action'lar için

## Skiller

Build sırasında otomatik kullanılacak (BUILD_PLAN.md'nin sonundaki tablo):
- `/axiom:build-fixer` — build sorunları
- `/axiom:concurrency-auditor` — Swift 6 strict concurrency
- `/axiom:swiftui-architecture-auditor` — view/viewmodel ayrımı
- `/axiom:accessibility-auditor` — Phase 5
- `/claude-api` — Phase 2 LLM client + caching
- `/impeccable` — design system tasarım iterasyonları
