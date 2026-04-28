# Gıcık — Build Plan

Bu plan `prompt.md` (master) + `design/` referansları + tasarım sistemini somut, **commit-by-commit** task listesine çevirir. Phase 0'dan Phase 7'ye sırayla yürütülür.

> **Çıktı dosyaları:**
> - `prompt.md` — master context (dokunma, her şey buradan türüyor)
> - `CLAUDE.md` — Claude Code'un her oturumda yüklediği bağlam (= prompt.md kopyası)
> - `BUILD_PLAN.md` — bu dosya, faz/task listesi
>
> **Repo stratejisi:** Şu an monorepo (`gicik/`). Phase 0 sonunda `gicik-ios/` ve `gicik-backend/` alt-dizinlerine ayrılır. (Master prompt iki ayrı repo öneriyor; solo dev için monorepo + workspace daha pratik. Sonra ayrılabilir.)

---

## Phase Akışı (özet)

| Phase | Süre | Çıktı |
|---|---|---|
| 0 — Bootstrap | 1-2 gün | iOS + backend iskelet, Supabase migrations, Sign in with Apple |
| 1 — Onboarding | 3-4 gün | 12 ekran, kalibrasyon flow, arketip atama |
| 2 — Vision Pipeline | 4-5 gün | Stage1+Stage2 LLM, streaming, prompt caching |
| 3 — Modes | 3-4 gün | 5 mod (cevap/açılış/bio/hayalet/davet) |
| 4 — Subscription | 2 gün | RevenueCat + StoreKit 2 + paywall |
| 5 — Polish | 3-4 gün | Animasyon, haptic, empty/error states, lokalizasyon, App Store assets |
| 6 — TestFlight | 1 hafta | 50 kişilik kapalı beta, Apple submission |
| 7 — Post-launch | 2-4 hafta | Widget, Siri shortcut, A/B test, prompt admin |

---

## Design Klasörü ↔ SwiftUI View Mapping

| `design/` referansı | SwiftUI View | Phase |
|---|---|---|
| `splash_screen` | `SplashView` | 1 |
| `demographic_screen` | `DemographicView` | 1 |
| `calibration_intro` | `CalibrationIntroView` | 1 |
| `quiz_binary_scenario`, `quiz_likert_scale`, `quiz_single_select` | `CalibrationQuizView` (3 cell varyantı) | 1 |
| `calibration_result_reveal` | `CalibrationResultView` (Lottie) | 1 |
| `demo_upload_aha_moment` | `DemoUploadView` | 1 |
| `notification_permission` | `NotificationPermissionView` | 1 |
| `ai_consent_screen` | `AICOnsentView` | 1 |
| `paywall_option_1`, `paywall_option_2_high_contrast`, `paywall_option_3_feature_focused` | `PaywallView` (A/B test üç varyant) | 4 |
| `home_variation_1/2/3` | `HomeView` (A/B test üç varyant) | 2 |
| `screenshot_picker_empty_state` | `ScreenshotPickerView.empty` | 2 |
| `screenshot_picker_in_progress` | `ScreenshotPickerView.uploading` | 2 |
| `screenshot_picker_complete` | `ScreenshotPickerView.done` | 2 |
| `tone_selector` | `ToneSelectorView` | 2 |
| `generation_streaming_state` | `GenerationView` | 2 |
| `result_screen_default_state` | `ResultView` (3 reply card) | 2 |
| `profile_screen` | `ProfileView` | 3 |
| `empty_state_no_history` | `EmptyState.noHistory` | 5 |
| `empty_state_network_error` | `ErrorState.network` | 5 |
| `empty_state_rate_limited` | `ErrorState.rateLimited` | 5 |
| `empty_state_unsupported_image` | `ErrorState.unsupportedImage` | 5 |
| `cyber_ironic_coach` | Karakter art (asset, splash bg) | 1 |
| `design_system.png` | DesignSystem token kaynak | 0 |
| `app_clip_siri_shortcut` | AppShortcuts | 7 |
| `ios_widgets_small_medium` | WidgetKit | 7 |
| `share_extension_ui` | Share Extension | 7 |

Her view'ı yazarken önce `design/<klasör>/screen.png` ve `code.html`'e bak, refleks olmadan kopyalama — SwiftUI native'ine çevir.

---

## PHASE 0 — Bootstrap (1-2 gün)

### 0.1 Repo yapısını ayır
- [ ] `gicik-ios/` ve `gicik-backend/` alt klasörlerini oluştur
- [ ] `prompt.md`, `CLAUDE.md`, `BUILD_PLAN.md` root'ta kalsın
- [ ] `design/` klasörünü `gicik-ios/Resources/design-references/` altına taşı (committed reference, build'e dahil değil — `.xcodeproj` exclude)
- **Commit:** `chore: split monorepo into ios + backend subdirs`

### 0.2 Backend init (Supabase)
- [ ] `cd gicik-backend && supabase init`
- [ ] `supabase/config.toml` — TR region, project_id ayarla
- [ ] `.env.local` — local dev, gitignore'da
- [ ] `supabase/migrations/20260101000000_initial_schema.sql` yaz (master prompt §6'daki tüm CREATE TABLE'lar)
  - profiles, conversations, prompt_versions, usage_daily, security_events
  - tüm RLS policy'leri
  - tüm indexler
- [ ] `supabase db reset` ile local test
- [ ] Apple Sign In provider config (Supabase dashboard'da)
- [ ] Storage bucket: `screenshots` (private, RLS, signed URL)
- [ ] Cron job: günlük 03:00 TR'de eski screenshot sil (Postgres `cron` extension veya pg_net)
- **Commit:** `feat(backend): initial schema + RLS + storage bucket`

### 0.3 iOS init (Xcode)
- [ ] Xcode 16+ → New Project → iOS App, SwiftUI lifecycle, Swift 6, iOS 17 min
- [ ] Bundle ID: `to.tikla.gicik` (master prompt'taki tercih)
- [ ] Display Name: `Gıcık`
- [ ] `Info.plist`:
  - `NSPhotoLibraryUsageDescription` = "Mesaj ekran görüntülerini analiz etmek için fotoğraflarına erişim"
  - `NSCameraUsageDescription` (gelecek için, MVP'de kullanılmayacak)
- [ ] Capabilities: Sign in with Apple, Push Notifications, App Groups (widget için ileride)
- [ ] SPM dependencies:
  - `supabase-swift` (https://github.com/supabase/supabase-swift)
  - `purchases-ios` (RevenueCat)
  - `posthog-ios`
  - `sentry-cocoa`
  - `mixpanel-swift`
  - `lottie-ios`
- **Commit:** `feat(ios): xcode project + dependencies`

### 0.4 Design System tokens

> **Önbelleklenmiş başlangıç:** `design-source/swiftui/DesignTokens.swift` ve `Primitives.swift` zaten `tokens.css` ve `parts/shared.jsx`'ten çevrilmiş halde repo'da. Phase 0.4'ün ilk işi bunları `gicik-ios/Gicik/DesignSystem/` altına böl + Xcode target'a ekle.

Adımlar:
- [ ] `design-source/swiftui/DesignTokens.swift` → `Gicik/DesignSystem/` altına böl:
  - `Colors.swift` (AppColor + Color hex extension)
  - `Typography.swift` (AppFont)
  - `Spacing.swift` (AppSpacing)
  - `Radius.swift` (AppRadius)
  - `Shadow.swift` (AppShadow + ShadowSpec)
  - `Animations.swift` (AppAnimation)
  - `CosmicBackground.swift` (View + modifier)
- [ ] `design-source/swiftui/Primitives.swift` → `Gicik/DesignSystem/Components/` altına böl:
  - `Logo.swift`
  - `PrimaryButton.swift` (3 style: solid / holoBorder / holoFill)
  - `SecondaryButton.swift`
  - `Chip.swift`
  - `ProgressDots.swift`
  - `TopBar.swift`
  - `ObservationCard.swift` (asistan sesi — italik, lime stripe)
  - `ReplyCard.swift` (output sesi — mono label + copy/feedback)
  - `GlassCard.swift` (modifier)
- [ ] `Gicik/DesignSystem/Modifiers/HapticFeedback.swift` — `.haptic(.medium)` modifier (Primitives'te `sensoryFeedback` kullanıyoruz, eski iOS fallback için)
- [ ] `Gicik/DesignSystem/Components/LoadingShimmer.swift` — skeleton shimmer (tokens.css'teki `@keyframes shimmer`)
- [ ] **Fonts:**
  - Space Grotesk (Regular, Medium, SemiBold, Bold) — `Resources/Fonts/`
  - JetBrains Mono (Regular, Medium) — `Resources/Fonts/`
  - Info.plist `UIAppFonts` array
- [ ] **DesignSystemCatalogView.swift** — tüm token'lar + primitives tek ekranda preview (Primitives.swift'teki `#Preview` block'unu canlı view'a çevir)
- **Commit:** `feat(ios): design system tokens + base components (from design-source)`

### 0.5 Configuration & networking
- [ ] `Gicik/App/Configuration.swift` — env değişkenleri
  - `Configuration.shared.supabaseURL` (xcconfig'den)
  - `Configuration.shared.supabaseAnonKey`
  - `Configuration.shared.revenueCatAPIKey`
  - `Configuration.shared.posthogAPIKey`
  - `Configuration.shared.sentryDSN`
- [ ] `Debug.xcconfig` ve `Release.xcconfig` (gitignore'da, `.template` versiyonları commitli)
- [ ] `Gicik/Core/Networking/SupabaseClient.swift` — singleton wrapper
- [ ] `Gicik/Core/Networking/APIClient.swift` — base URLRequest helper, hata mapping
- [ ] `Gicik/Core/Networking/Endpoints.swift` — endpoint enum
- [ ] `Gicik/Core/Auth/KeychainManager.swift` — Apple Sign In token saklama
- [ ] `Gicik/Core/Auth/AuthService.swift` — sign in / sign out / current session
- **Commit:** `feat(ios): config + supabase client + auth service`

### 0.6 App entry & root router
- [ ] `Gicik/App/GicikApp.swift` — `@main`, AppDelegate, Sentry init, PostHog init, RevenueCat init, Mixpanel init
- [ ] `Gicik/App/AppDelegate.swift` — push notification register, deep link handling
- [ ] `Gicik/App/RootView.swift` — auth state'e göre router (`AuthService.isSignedIn` ? `MainTabView` : `OnboardingFlowView`)
- [ ] `Gicik/Features/Auth/SignInView.swift` — placeholder, Sign in with Apple butonu
- [ ] `Gicik/Features/Main/HomeView.swift` — placeholder, "Hoşgeldin {{name}}" + sign out butonu
- **Commit:** `feat(ios): app entry + auth flow + placeholder home`

### 0.7 Sentry test & DoD
- [ ] `Sentry.captureMessage("first run")` ekle, dashboard'da gör
- [ ] Test crash: `fatalError("test")` → Sentry'de görülüyor mu
- [ ] **DoD:**
  - [x] App build alıyor (warning'siz)
  - [x] Sign in with Apple → Supabase auth → HomeView göster
  - [x] Sign out → tekrar SignInView
  - [x] Sentry crash test ✓
- **Commit:** `chore: phase 0 done — sign in works end-to-end`

---

## PHASE 1 — Onboarding Flow (3-4 gün)

### 1.1 OnboardingViewModel + navigation
- [ ] `Gicik/Features/Onboarding/OnboardingViewModel.swift` — `@Observable`, step enum, progress tracker, answers buffer
- [ ] `Gicik/Features/Onboarding/OnboardingFlowView.swift` — `NavigationStack` + step routing, smooth transition (matched geometry effect)
- **Commit:** `feat(onboarding): viewmodel + flow shell`

### 1.2 Splash → Demographic
- [ ] `SplashView.swift` — Y2K logo (lowercase "gıcık"), tagline "yazma. gıcık yazsın.", "başla" PrimaryButton
  - Ref: `design/splash_screen/`
  - Cyber/ironic coach asset: `design/cyber_ironic_coach/screen.png` arka plan layer
- [ ] `DemographicView.swift` — 3 grup chip seçim
  - Cinsiyet, Yaş bracket, Niyet
  - Validation: hepsi seçili olmalı, ileri butonu disabled
  - Ref: `design/demographic_screen/`
- **Commit:** `feat(onboarding): splash + demographic screens`

### 1.3 Calibration intro + quiz engine
- [ ] `CalibrationIntroView.swift` — "9 soru, 2 dakika" + "başla" CTA
  - Ref: `design/calibration_intro/`
- [ ] `Gicik/Models/CalibrationQuestion.swift` — question schema (master prompt §9)
- [ ] `Gicik/Resources/calibration-questions.json` — 9 soru (master prompt §9'daki YAML'dan JSON'a çevrilmiş)
- [ ] `CalibrationQuizView.swift` — soru tipi router
  - `BinaryScenarioCell` (ref: `design/quiz_binary_scenario/`)
  - `LikertScaleCell` (ref: `design/quiz_likert_scale/`)
  - `SingleSelectCell` (ref: `design/quiz_single_select/`)
  - `MultiSelectWithPriorityCell`
  - `SliderCell`
  - `FreeTextCell` (optional, atlanabilir)
- [ ] Progress bar üstte: "3/9"
- [ ] Skip butonu YOK (master prompt kuralı)
- **Commit:** `feat(onboarding): calibration quiz engine + 9 questions`

### 1.4 Backend: /calibrate endpoint
- [ ] `gicik-backend/supabase/functions/calibrate/index.ts`
  - input: answers[]
  - `_shared/archetype-derivation.ts` — master prompt §9'daki `deriveArchetype` (TypeScript)
  - output: archetype_primary, secondary, display_label, description[], traits, full_profile
  - profiles tablosuna yaz (calibration_data JSONB, calibration_completed_at)
- [ ] `_shared/auth-middleware.ts` — JWT validate, user_id extract
- [ ] Eval: 6 arketipi tetikleyen 6 sentetik input → 6 farklı output (deterministic)
- **Commit:** `feat(backend): /calibrate edge function + archetype derivation`

### 1.5 Calibration result + reveal animation
- [ ] `Gicik/Resources/Lottie/calibration-reveal.json` — Y2K reveal animation (Lottie download veya After Effects export)
- [ ] `CalibrationResultView.swift`
  - Lottie player + 2s playback
  - Reveal: arketip emoji + label ("🥀 GICIK")
  - 3 davranışsal gözlem cümlesi (typewriter animation, 200ms her satır)
  - "devam et" PrimaryButton
  - Ref: `design/calibration_result_reveal/`
- [ ] Haptic: reveal anında `.success`
- **Commit:** `feat(onboarding): calibration result + reveal animation`

### 1.6 Demo upload (aha moment)
- [ ] `DemoUploadView.swift`
  - Pre-loaded sample Türkçe Tinder profili (asset olarak)
  - "ben senin yerine yazsam?" intro cümle
  - Auto-generate: 3 sample reply (HARDCODED, backend'e gitmiyor — sadece animasyon gösterimi)
  - Stream-style typewriter ile cevaplar gelir, 1.5s aralık
  - "muhteşem" CTA → ileri
  - Ref: `design/demo_upload_aha_moment/`
- **Commit:** `feat(onboarding): demo upload aha moment`

### 1.7 Notification permission + AI consent
- [ ] `NotificationPermissionView.swift`
  - "gıcık sana haber versin" + 2 örnek bildirim preview kartı
  - "izin ver" → `UNUserNotificationCenter.current().requestAuthorization`
  - "şimdi değil" → atla, profile'a yazma
  - Ref: `design/notification_permission/`
- [ ] `AICOnsentView.swift` (KVKK + AI yasası gereği)
  - "verilerinin nasıl kullanıldığını bil" başlık
  - 4 madde checkbox (hepsi tikli default ama görünür)
  - "kabul ediyorum" CTA
  - Geri çekilebilir bildirim: "settings'te her zaman değiştirebilirsin"
  - profiles.ai_consent_given = true, ai_consent_at = now()
  - Ref: `design/ai_consent_screen/`
- **Commit:** `feat(onboarding): notification + AI consent`

### 1.8 Phase 1 DoD
- [ ] Yeni kullanıcı: Splash → Demographic → Calibration intro → Quiz (×9) → Result → Demo → NotifPerm → AIConsent → (Paywall placeholder, Phase 4'e bırak) → HomeView
- [ ] Quiz cevapları Supabase'a yazılıyor
- [ ] Calibration deterministik — aynı 9 cevap, aynı arketip
- [ ] Tüm ekranlar haptic + smooth transition
- [ ] Skip yok (paywall hariç, o da Phase 4)
- **Commit:** `chore: phase 1 done — onboarding flow complete`

---

## PHASE 2 — Vision Pipeline + Generation (4-5 gün)

### 2.1 Backend: prompt sistemi
- [ ] `gicik-backend/prompts/` klasörü oluştur, master prompt §8'deki tüm dosyaları yaz:
  - `L0_identity.tr.md`
  - `L1_modes/cevap.tr.md`, `acilis.tr.md`, `bio.tr.md`, `hayalet.tr.md`, `davet.tr.md`
  - `L2_constraints.tr.md`
  - `L3_output_schemas.json`
  - `L4_runtime_template.tr.md`
  - `tones/flortoz.tr.md`, `esprili.tr.md`, `direkt.tr.md`, `sicak.tr.md`, `gizemli.tr.md`
  - `stage1_parser.md`
- [ ] `seed-prompts.ts` — tüm dosyaları okur, `prompt_versions` tablosuna v1 olarak yazar (`is_active=true`)
- [ ] `_shared/prompt-loader.ts` — `(layer, mode, tone)` → active version'ı çek, cache et
- **Commit:** `feat(backend): prompt versioning system + L0-L4 + tones`

### 2.2 Backend: LLM client
- [ ] `_shared/llm-client.ts`
  - `parseScreenshot(image, mode)` — Gemini 2.5 Flash, vision input, structured JSON output, schema validation
  - `generateReplies(parseResult, profile, tone, mode)` — Anthropic Claude Sonnet 4.5, prompt caching aktif (`cache_control` L0+L2+L3)
  - Failover: Sonnet 5xx → GPT-5
  - Cost tracking: token sayısı × per-token rate → DB'ye yaz
  - Timeout: parse 5s, generate 15s
- [ ] Env vars: `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `OPENAI_API_KEY`
- **Commit:** `feat(backend): LLM client + prompt caching + failover`

### 2.3 Backend: /parse-screenshot
- [ ] `functions/parse-screenshot/index.ts`
  - multipart/form-data → image bytes
  - Storage'a yükle (`screenshots/<user_id>/<uuid>.jpg`, signed URL)
  - Gemini vision call → ParseResult JSON
  - Validate: schema match, injection_attempt check
  - Insert `conversations` row (parse_result, parse_model, parse_cost_usd, parse_duration_ms)
  - Response: { conversation_id, parse_result, duration_ms }
- [ ] Rate limit: 10/dk per user (Postgres function veya KV store)
- [ ] **Eval:** 5 sentetik screenshot (Tinder/iMessage/WhatsApp/Bumble/Instagram) → doğru `platform_detected`
- [ ] **Injection test:** "ignore previous instructions" yazılı screenshot → `injection_attempt: true`
- **Commit:** `feat(backend): /parse-screenshot edge function`

### 2.4 Backend: /generate-replies (streaming)
- [ ] `functions/generate-replies/index.ts`
  - input: conversation_id, tone
  - profiles + conversations join → context
  - L0 + L1(mode) + L2 + tone(selected) + L4(template fill) → final prompt
  - Anthropic SSE streaming
  - Output filter: toxic positivity ("sen değerlisin", "harikasın") → regenerate
  - Each token → `data: {"type":"token","text":"..."}\n\n`
  - Final: `data: {"type":"reply","index":0,"text":"...","tone_angle":"..."}` × 3
  - Update `conversations` row: generation_result, model, cost, duration
- [ ] **Eval:** 20 senaryo × 5 tone = 100 generation, manual review %80+ kabul
- [ ] **Injection test:** L2 constraints aktif, sınır cümlesi üretmiyor mu
- **Commit:** `feat(backend): /generate-replies SSE streaming + filter`

### 2.5 iOS: ScreenshotPicker + flow state
- [ ] `Gicik/Features/Main/HomeView.swift` — 5 mode kartı
  - Üst banner: "Gıcık seni 🥀 olarak biliyor" (arketip personalized)
  - Son 3 conversation history (varsa)
  - Ref: `design/home_variation_1/`, `home_variation_2/`, `home_variation_3/` — A/B test PostHog feature flag ile
- [ ] `Gicik/Features/Main/ScreenshotPickerView.swift` — 3 state
  - `.empty` (ref: `design/screenshot_picker_empty_state/`) — "fotoğraf seç" + PHPicker trigger
  - `.uploading` (ref: `design/screenshot_picker_in_progress/`) — progress bar + thumbnail preview
  - `.done` (ref: `design/screenshot_picker_complete/`) — auto-advance to ToneSelector
- [ ] `Gicik/Features/Main/HomeViewModel.swift` — flow state machine, PHPicker delegate, upload progress
- [ ] PHPicker → resize to max 1024px, JPEG q=0.8 (cost tasarruf)
- **Commit:** `feat(ios): home + screenshot picker (3 states)`

### 2.6 iOS: Tone selector + generation streaming
- [ ] `Gicik/Features/Main/ToneSelectorView.swift`
  - 5 tone chip: flörtöz, esprili, direkt, sıcak, gizemli
  - "default" badge: arketip'e göre önerilen tone (örn. dryroaster → direkt)
  - Tap → API call başlat, GenerationView'a navigate
  - Ref: `design/tone_selector/`
- [ ] `Gicik/Core/Networking/SSEClient.swift` — SSE parser (Combine veya AsyncSequence)
- [ ] `Gicik/Features/Main/GenerationView.swift`
  - Üst: arketip emoji + "gıcık düşünüyor..."
  - Observation cümlesi (asistan sesi) animasyonlu giriş
  - 3 placeholder card (skeleton shimmer)
  - SSE token geldikçe card'lar dolar (typewriter effect)
  - Ref: `design/generation_streaming_state/`
- **Commit:** `feat(ios): tone selector + streaming generation`

### 2.7 iOS: Result view
- [ ] `Gicik/Features/Main/ResultView.swift`
  - 3 reply card (`HolographicCard` component)
  - Her kart üstünde: tone_angle ("doğrudan engage" gibi) küçük etiket
  - Her kartta:
    - reply text
    - "kopyala" butonu (UIPasteboard, haptic, "kopyalandı" toast)
    - "👍 / 👎" feedback (POST /prompt-feedback)
  - Alt aksiyon barı: "tekrar üret" + "farklı tone dene"
  - Ref: `design/result_screen_default_state/`
- [ ] `POST /prompt-feedback` endpoint çağrısı (analytics + RLHF data)
- **Commit:** `feat(ios): result view + copy + feedback`

### 2.8 Phase 2 DoD
- [ ] E2E: Home → Mode tıkla → Screenshot picker → Upload → Tone seç → Streaming → 3 cevap → Kopyala
- [ ] **Latency:** parse <2s, generate first token <3s, full <8s (4G/wifi'de ölç)
- [ ] **Quality:** 20 senaryo manual eval, %80+ kabul
- [ ] **Injection:** 5 deneme bloklu
- [ ] **Cost:** prompt cache hit oranı %50+ (PostHog event)
- **Commit:** `chore: phase 2 done — full vision pipeline operational`

---

## PHASE 3 — Modes (3-4 gün)

### 3.1 Mode infra
- [ ] `Gicik/Models/Mode.swift` — enum: cevap, acilis, bio, hayalet, davet
- [ ] `Gicik/Features/Modes/ModeRouter.swift` — mode'a göre flow seç
- [ ] HomeView'daki kartları enum'a bağla
- **Commit:** `feat(modes): mode model + router`

### 3.2 Cevap mode (Phase 2'de zaten yapıldı)
- [ ] HomeView → cevap mode tıklandığında mevcut flow'a yönlendir
- [ ] Doğrula: 5 senaryo eval

### 3.3 Açılış mode
- [ ] `AcilisModeView.swift` — same as cevap (screenshot → tone → result)
- [ ] L1 prompt: `acilis.tr.md` aktif
- [ ] **Eval:** Tinder profil screenshot'ı × 5 tone, sonuçlar generic değil mi (YASAK: "selam, nasılsın")
- **Commit:** `feat(modes): açılış (opener) mode`

### 3.4 Bio mode
- [ ] `BioModeView.swift` — farklı flow:
  - 3 soru (`ne işle uğraşıyorsun?`, `ne sevmezsin?`, `seni seven biri ne der?`)
  - Form-style input
  - "üret" → generate-replies (mode=bio)
  - 3 bio versiyonu, kopyala
- [ ] L1 prompt: `bio.tr.md`
- [ ] **Eval:** 5 farklı user profili → 5 farklı bio set, klişe yok (ENTP/foodie YASAK)
- **Commit:** `feat(modes): bio mode (3-question flow)`

### 3.5 Hayalet mode
- [ ] `HayaletModeView.swift` — same as cevap UI
- [ ] L1 prompt: `hayalet.tr.md`
- [ ] **Özel:** angle 1 her zaman "yazma — sessizliği koru" (UI'da net görünsün, kart üstü "yazma" badge)
- [ ] **Eval:** 5 ghost senaryosu, 1. cevap her zaman "yazma" content'i mi
- **Commit:** `feat(modes): hayalet (ghost) mode`

### 3.6 Davet mode
- [ ] `DavetModeView.swift`
- [ ] L1 prompt: `davet.tr.md`
- [ ] **Karar mantığı:** prompt önce "davet anı geldi mi?" değerlendirir
  - Geldiyse: 3 davet cümlesi (spesifik plan / low-pressure / ironic)
  - Gelmediyse: tek mesaj "henüz değil. şu sinyalleri ara: [...]"
- [ ] UI'da iki state: "davet et" cards × 3 vs "henüz değil" advice card
- [ ] **Eval:** 10 senaryo (5 hazır, 5 değil) — model doğru karar veriyor mu
- **Commit:** `feat(modes): davet (invite) mode + timing logic`

### 3.7 Profile screen
- [ ] `Gicik/Features/Profile/ProfileView.swift`
  - Üst: arketip kart (emoji + label + 3 cümle)
  - "kalibrasyonu yenile" butonu (settings'e link)
  - Son 30 gün conversation history (lazy list)
  - Subscription status
  - "çıkış yap" butonu (footer)
  - Ref: `design/profile_screen/`
- [ ] `Gicik/Features/Profile/CalibrationEditView.swift` — quiz'i tekrar başlatma
- **Commit:** `feat(profile): profile screen + history + recalibrate`

### 3.8 Phase 3 DoD
- [ ] 5 mode hepsi çalışıyor, her biri 5 senaryo eval edildi
- [ ] Mode değiştirme: history kaybı yok
- [ ] Profile screen tam (history, recalibrate, sign out)
- **Commit:** `chore: phase 3 done — all 5 modes operational`

---

## PHASE 4 — Subscription & Paywall (2 gün)

### 4.1 RevenueCat setup
- [ ] RevenueCat dashboard: Gıcık project, iOS app
- [ ] Products:
  - `gicik_weekly` — ₺49/hafta, 3-day free trial
  - `gicik_yearly` — ₺499/yıl, no trial
- [ ] Entitlement: `premium`
- [ ] Offering: `default` (weekly + yearly)
- [ ] App Store Connect: in-app purchase products oluştur, sandbox tester ekle
- [ ] `Gicik/Core/Subscription/SubscriptionManager.swift` — RevenueCat wrapper
  - `currentEntitlement`, `purchase(product)`, `restorePurchases()`, `customerInfo`
- [ ] `Gicik/Core/Subscription/EntitlementGate.swift` — feature flag helper
  - `EntitlementGate.canGenerate(today: count)` — free 3/gün
  - `EntitlementGate.canUseTone(_:)` — free sadece "default"
  - `EntitlementGate.canUseMode(_:)` — free sadece cevap
- **Commit:** `feat(subscription): revenuecat + entitlement gate`

### 4.2 Paywall view (3 varyant A/B test)
- [ ] `Gicik/Features/Onboarding/PaywallView.swift`
- [ ] PostHog feature flag: `paywall_variant` → `option_1` | `option_2` | `option_3`
- [ ] Üç layout:
  - `option_1` (ref: `design/paywall_option_1/`) — standart Cal AI tarzı
  - `option_2` (ref: `design/paywall_option_2_high_contrast/`) — high contrast, dramatic
  - `option_3` (ref: `design/paywall_option_3_feature_focused/`) — feature liste odaklı
- [ ] Her varyantta:
  - Trial toggle DEFAULT ON
  - Weekly ₺49 / Yearly ₺499 toggle
  - "ÜCRETSIZ BAŞLAT" CTA
  - Restore purchases footer link
  - "İstediğin zaman iptal" footnote
- [ ] PostHog event: `paywall_view`, `paywall_purchase_clicked`, `paywall_dismissed`
- **Commit:** `feat(paywall): 3 variant A/B test paywall`

### 4.3 Soft paywall (free tier)
- [ ] `usage_daily` table — günlük generation count
- [ ] Backend: `/generate-replies` öncesi count check, limit aşıldı → 402 Payment Required
- [ ] iOS: 4. cevap denemesinde paywall modal sheet
- [ ] Free user: tone selector'da non-default tone'lar locked (kilitli ikon)
- [ ] Free user: HomeView'da non-cevap mode'lar locked
- **Commit:** `feat(subscription): free tier limits + soft paywall`

### 4.4 RevenueCat → Supabase webhook
- [ ] `gicik-backend/supabase/functions/revenuecat-webhook/index.ts`
- [ ] Validate signature
- [ ] Event'ler: INITIAL_PURCHASE, RENEWAL, CANCELLATION, EXPIRATION
- [ ] profiles tablosuna sync (entitlement, expiration_date)
- [ ] RevenueCat dashboard'da webhook URL set
- **Commit:** `feat(backend): revenuecat webhook → supabase sync`

### 4.5 Phase 4 DoD
- [ ] Sandbox: trial başla → 3 gün sonra renewal (sandbox time-compressed)
- [ ] Free user 4. generation → paywall modal görüyor
- [ ] Restore purchases çalışıyor
- [ ] Cross-device: iPhone'da satın al, iPad'de aktif
- [ ] Webhook: subscription state DB'de doğru
- **Commit:** `chore: phase 4 done — subscription pipeline complete`

---

## PHASE 5 — Polish (3-4 gün)

### 5.1 Empty + error states
- [ ] `Gicik/DesignSystem/Components/EmptyStateView.swift` — generic, ikon + başlık + alt + CTA
- [ ] `Gicik/DesignSystem/Components/ErrorStateView.swift` — generic
- [ ] Kullanım yerleri:
  - HomeView history boşsa: `EmptyStateView.noHistory` (ref: `design/empty_state_no_history/`)
  - Network error: `ErrorStateView.network` (ref: `design/empty_state_network_error/`)
  - Rate limited: `ErrorStateView.rateLimited` (ref: `design/empty_state_rate_limited/`)
  - Unsupported image (parse failed): `ErrorStateView.unsupportedImage` (ref: `design/empty_state_unsupported_image/`)
- **Commit:** `feat(polish): empty + error states`

### 5.2 Animation pass
- [ ] Her primary action haptic ekle (`.haptic(.medium)` modifier)
- [ ] View transitions: `.spring(response: 0.4, dampingFraction: 0.7)` standart
- [ ] Onboarding step geçişleri matched geometry effect
- [ ] Lottie reveal: 60fps, GPU
- [ ] Streaming text: 60ms aralık (okunabilir)
- **Commit:** `feat(polish): animation + haptic pass`

### 5.3 Accessibility
- [ ] Tüm tappable elemanlara `.accessibilityLabel(_)` ekle (Türkçe)
- [ ] Dynamic Type test: en büyük boyutta layout bozulmuyor mu
- [ ] VoiceOver baştan sona dene (Splash → Result)
- [ ] Color contrast: WCAG AA pass (Y2K accent'lerin kontrastı kritik — bg üzerinde okunabilir mi)
- [ ] Reduce Motion respect (Lottie devre dışı kalır)
- **Commit:** `feat(polish): accessibility (VoiceOver, Dynamic Type, contrast)`

### 5.4 Lokalizasyon
- [ ] `Localizable.strings` (tr) — tüm string'ler
- [ ] `Localizable.strings` (en) — tüm string'ler (App Store English review için)
- [ ] String catalog'a (Xcode 15+) geç
- [ ] Hardcoded string yok kontrolü (SwiftLint rule)
- **Commit:** `feat(polish): localization tr + en`

### 5.5 App Store assets
- [ ] App Icon (1024px master + tüm boyutlar)
- [ ] Screenshots (iPhone 6.7" required + 6.1"):
  - 5 screenshot, %30+ non-dating (iş, aile, arkadaş senaryosu)
  - Tinder/Bumble logo asla görünmesin
  - Türkçe dil
  - Caption Y2K stilinde
- [ ] App Store Connect:
  - **Category:** Lifestyle (NOT Productivity, NOT Dating)
  - **Subtitle:** "ne diyeceğini değil, ne dediğini gör."
  - **Description:** ilk 3 satır iletişim koçu, dating kelimesi yok
  - **Keywords:** YASAKLI: rizz, pickup, wingman, dating, ChatGPT, GPT, Claude, Gemini
  - **Privacy Nutrition Label:** doğru doldur (Data Used, Tracking)
- [ ] Privacy Manifest (`PrivacyInfo.xcprivacy`) — iOS 17+ zorunlu
- **Commit:** `feat(polish): app store metadata + screenshots + privacy manifest`

### 5.6 Phase 5 DoD
- [ ] VoiceOver tam çalışıyor (uçtan uca dene)
- [ ] Dynamic Type max'ta crash/cutoff yok
- [ ] tr+en lokalizasyon test
- [ ] App Store Connect tüm metadata onaylanmış (henüz submit değil)
- [ ] Privacy review checklist 100%
- **Commit:** `chore: phase 5 done — app polish complete`

---

## PHASE 6 — TestFlight & Launch (1 hafta)

### 6.1 CI/CD
- [ ] `.github/workflows/ios-build.yml` — PR'da build + test
- [ ] `.github/workflows/testflight-deploy.yml` — main branch push'unda Fastlane ile TestFlight upload
- [ ] Fastlane `Fastfile`: `lane :beta` (build, sign, upload)
- [ ] App Store Connect API Key (Fastlane için)
- [ ] **Commit:** `chore: ci/cd + fastlane testflight pipeline`

### 6.2 Closed beta
- [ ] TestFlight: 50 tester ekle (Türk Gen Z, dating active)
- [ ] Onboarding email: feedback formu, PostHog survey link
- [ ] PostHog dashboard: funnel (splash → paywall → first generation)
- [ ] 5 günlük gözlem
- [ ] Bug fix iterasyonları (her gün 1-2 build)

### 6.3 Apple submission
- [ ] App Review notes:
  - Apple test hesabı (sandbox subscription test edebilsin)
  - "İletişim koçu" pozisyonlanması açıklaması
  - AI consent'in nerede olduğu
  - Demo video (3 dk, Apple reviewer için)
- [ ] Submit
- [ ] Reject olursa: sebebe göre revize, 24 saat içinde resubmit
- [ ] Onay sonrası: phased release (1% → 10% → 50% → 100%)

### 6.4 Launch
- [ ] PR + TikTok soft launch
- [ ] Press kit hazır: logo (PNG + SVG), screenshots, founder story (Oğuzhan)

### 6.5 Phase 6 DoD
- [ ] TestFlight 50 kullanıcı, 7 gün retention >40%
- [ ] App Store: Approved
- [ ] Press kit: hazır
- **Commit:** `chore: phase 6 done — launched 🥀`

---

## PHASE 7 — Post-launch (2-4 hafta)

### 7.1 A/B test infrastructure
- [ ] PostHog experiment'ler:
  - `paywall_variant` (zaten Phase 4'te)
  - `home_layout` (zaten Phase 2'de)
  - `onboarding_skip_demo` (yeni)
- [ ] PostHog dashboard: conversion rate per variant

### 7.2 Prompt admin UI
- [ ] Web admin panel (Next.js veya Supabase Studio extension)
- [ ] `prompt_versions` CRUD
- [ ] A/B test rollout (rollout_percentage slider)
- [ ] Diff viewer (v1 vs v2)
- [ ] Version revert
- [ ] **Auth:** Supabase Auth + role-based (admin only)

### 7.3 Widget (WidgetKit)
- [ ] Widget Extension target ekle
- [ ] Small + Medium widget — son cevap, hızlı erişim
- [ ] App Group ile data share
- [ ] Ref: `design/ios_widgets_small_medium/`

### 7.4 Siri Shortcut
- [ ] `AppShortcuts` provider — "Gıcık'tan cevap üret" intent
- [ ] Share extension target — Tinder/iMessage paylaşım menüsünden direkt parse
- [ ] Ref: `design/app_clip_siri_shortcut/`, `share_extension_ui/`

### 7.5 Push notification engagement
- [ ] D+1 push: "screenshot atmadın bugün — bir sıkıntı mı var?" (lowercase, ironic)
- [ ] D+3 push: "yeni özellik: davet modu"
- [ ] D+7 push: "hala 7 günlük yeni profilsin. ne öğrendi gıcık seninle? gör."
- [ ] Push token Supabase'a yaz, edge function ile schedule (cron)

---

## Acceptance Master Checklist

Hangi phase'de olduğunu kaybettiğinde buraya bak:

- [ ] **Phase 0:** Sign in with Apple çalışıyor, HomeView placeholder, Sentry crash testi ✓
- [ ] **Phase 1:** 12 ekran onboarding, kalibrasyon arketip atıyor, AI consent kayıtlı
- [ ] **Phase 2:** Screenshot → parse → tone → 3 streaming reply, latency budget içinde
- [ ] **Phase 3:** 5 mod (cevap/açılış/bio/hayalet/davet), profile screen
- [ ] **Phase 4:** Trial + paywall + free tier limits + RevenueCat webhook
- [ ] **Phase 5:** Empty/error states, accessibility, lokalizasyon, App Store assets
- [ ] **Phase 6:** TestFlight 50 user, Apple approved, launched
- [ ] **Phase 7:** A/B test, prompt admin, widget, siri shortcut, push series

---

## Phase 0'a şimdi başla

İlk komut:

```
cd ~/Desktop/gicik
mkdir -p gicik-ios gicik-backend
mv design gicik-ios/Resources/design-references
git mv prompt.md prompt.md  # zaten root'ta
```

Sonra **Phase 0.1**'den başla, checkbox'ları tek tek işaretle, her sub-section'da bir commit at.

İyi şanslar, Oğuzhan. — Plan
