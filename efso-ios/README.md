# efso-ios

SwiftUI iOS uygulaması. **iOS 17+**, **Swift 6 strict concurrency**, MV pattern (`@Observable`).

## İlk kurulum

📖 **[SETUP.md](SETUP.md)** — sıfırdan Xcode projesini ayağa kaldırma (5-10 dakika).

```bash
brew install xcodegen
cp Debug.xcconfig.template Debug.xcconfig    # secrets doldur
cp Release.xcconfig.template Release.xcconfig
xcodegen generate
open Efso.xcodeproj
```

## Proje yapısı

```
Efso/
├── App/
│   ├── EfsoApp.swift                # @main, Sentry/Analytics bootstrap, RC init
│   ├── AppDelegate.swift             # push token (Phase 7), deep link
│   ├── Configuration.swift           # env vars (xcconfig)
│   └── RootView.swift                # auth state router (isRestoring → splash)
│
├── DesignSystem/
│   ├── Colors.swift, Typography.swift, Spacing.swift, Animations.swift
│   ├── CosmicBackground.swift, Color+Hex.swift
│   ├── DesignSystemCatalogView.swift
│   └── Components/
│       ├── Logo.swift                # holographic dot in "o"
│       ├── PrimaryButton, SecondaryButton, Chip, ProgressDots, TopBar
│       ├── ObservationCard            # asistan sesi (italic + lime stripe)
│       ├── ReplyCard                  # output sesi (mono + copy + thumbs)
│       ├── GlassCard, LoadingShimmer
│       ├── EmptyStateView, TypewriterText
│       └── SpotlightOverlay           # tek-seferlik onboarding spotlight
│
├── Features/
│   ├── Auth/
│   │   ├── SignInView                 # Sign in with Apple
│   │   └── EmailSignInSheet           # #if DEBUG only test path
│   ├── HowItWorks/HowItWorksView      # 14sn replayable explainer
│   ├── Onboarding/                    # 12 ekran flow
│   │   ├── SplashView, ValueIntroView, DemographicView
│   │   ├── CalibrationIntroView, CalibrationQuizView (9 soru)
│   │   ├── DemoUploadView, NotificationPermissionView
│   │   ├── StarRatingPrimeView, PrePaywallValueView
│   │   ├── AIConsentView, PaywallView, LegalSheet
│   │   └── OnboardingFlowView, OnboardingViewModel
│   ├── Main/                          # 4 mod ana akış
│   │   ├── HomeView, HomeViewModel
│   │   ├── ScreenshotPickerView       # SS yükleme + recents + manual entry CTA
│   │   ├── ManualChatComposerView     # cevap/davet için elle konuşma
│   │   ├── ManualProfileEntryView     # açılış için elle profil
│   │   ├── TonlaDraftView             # taslak text input
│   │   ├── GenerationView             # streaming SSE UI
│   │   ├── ResultView                 # 3 reply card + tone switcher
│   │   └── ArchetypeSwitcherSheet
│   ├── Profile/ProfileView             # "sen" hub: archetype + history + ayarlar
│   └── Settings/VoiceSampleEditorView
│
├── Core/
│   ├── Networking/
│   │   ├── APIClient.swift             # invokeJSON / invokeMultipart / invokeStream (SSE)
│   │   ├── Endpoints.swift, APIError.swift, SupabaseService.swift
│   │   └── (idle watchdog 30s, ephemeral session, manual_input branch)
│   ├── Auth/
│   │   ├── AuthService.swift           # Apple SSO + credentialState + revocation
│   │   └── KeychainManager.swift
│   ├── Storage/
│   │   ├── UserDefaultsKeys.swift, RecentScreenshotsLoader.swift
│   │   └── Calendar+Istanbul.swift     # quota reset boundary TZ
│   ├── Subscription/
│   │   ├── SubscriptionManager.swift   # RC + 4s grace period race fix
│   │   └── EntitlementGate.swift       # 3/gün throttle, mode/tone open
│   └── Analytics/AnalyticsService.swift, EventNames.swift
│
├── Models/                            # Mode, Tone, Calibration, Conversation
└── Resources/
    ├── Assets.xcassets/AppIcon.appiconset/  # 1024×1024 PNG (placeholder)
    ├── calibration-questions.json     # 9 soru
    ├── Fonts/, Lottie/
    └── design-source/                 # Claude Design canonical export (gitignored from build)
```

## Build durumu

| Faz | Kapsam | Durum |
|---|---|---|
| 0-3 | Bootstrap, onboarding, vision pipeline, modes | ✅ |
| A | 8 submission blocker | ✅ |
| B | 4 prod bug + 6 dead-tap | ✅ |
| C | App Review compliance + iOS stability + UX polish | ✅ |
| D | TestFlight (signing + archive + invite) | ⏳ user manual |

Detay: root `HANDOFF.md` ve `CLAUDE.md`.

## Geliştirme prensipleri

- Türkçe yorum, İngilizce identifier
- Küçük + focused PR
- Test: Models, ViewModels, API client zorunlu (post-launch backlog)
- SwiftUI body içinde ağır iş yok
- async/await; Combine sadece UI binding
- Typed errors, `catch { }` boş blok yasak
- Sentry breadcrumbs önemli action'lar için
- Brand voice: lowercase, GenZ tempo, klişe yok, "abicilik" yok
