# Gıcık — Production Readiness Handoff

**Son güncelleme:** 2026-05-01
**Durum:** Submission-ready dilim ✅ + polish kalan ⏳

---

## Bir bakışta

**Şu an submit edilebilir mi?** Evet, ama **2 user-action** kalıyor:
1. `gicik.app/privacy` + `/terms` HTML sayfalarını yayına al (DNS + content). Kod hazır (`SFSafariViewController` ile direkt açılır).
2. Sandbox'ta trial flow + RevenueCat → Supabase webhook senkronu canlı doğrula (RC test config + 1-2 deneme satın alma).

Bunlar dışında kod tarafı App Store'a archive + submit'e hazır.

---

## Tamamlanan fazlar

### ✅ Faz A — 8 submission blocker
| # | Sorun | Fix |
|---|---|---|
| S1 | armv7 capability | project.yml + Info.plist'ten silindi |
| S2 | ITSAppUsesNonExemptEncryption | `false` eklendi |
| S3 | AppIcon PNG yok | 1024×1024 placeholder generate (bg0 + pink halo + lime "g") |
| S4 | Version uyuşmazlığı | `MARKETING_VERSION 1.0.0`, Info.plist `$(MARKETING_VERSION)` substitute |
| S5 | Privacy/Terms placeholder warning | LegalSheet → SFSafariViewController, gicik.app live olunca otomatik çalışır |
| S6 | "tinder"/"bumble" UI'da | 3 site temizlendi: ValueIntroView, Mode.swift, TypewriterText preview |
| S7 | NSCameraUsageDescription | tamamen kaldırıldı |
| S8 | 24h cron | pg_cron + pg_net + vault.service_role_key + cron.schedule **live** |

### ✅ Faz B — 4 prod bug + 6 dead-tap
| # | Sorun | Fix |
|---|---|---|
| U1 | `ReplyCard(onCopy: {})` GenerationView | UIPasteboard + success haptic |
| U2 | Aynı, DemoUploadView | UIPasteboard + haptic |
| U3 | Calibration "ikisi de değil" stuck | JSON'a `optional: true` |
| U4 | AI consent revoke zombie state | Revoke'da `onboardingCompleted=false` da, re-onboard zorunlu |
| U5 | ManualProfile submit hint yok | Inline hint "en az bir alan doldur..." |
| U6 | PhotoKit denied recovery yok | iOS Ayarlar deeplink satırı |
| B1 | Free quota chip lokal yalan | `historyLoadedOnce` gate (palyatif), Faz C'de **server-truth `remaining_today`** ile düzeltildi |
| B2 | SSE drop sessizce başarı | 3 reply guard + Sentry capture (3 generation method'da) |
| B3 | RC purchase race | Purchase başarılı sonra 4s grace + refreshCustomerInfo |
| B4 | Auth cold-launch flicker | `isRestoring` flag + `AuthRestoreSplash` |

### ✅ Faz C kısmen — App Review + Backend correctness
| # | Sorun | Fix |
|---|---|---|
| C1 | aps-environment dev | Release ayrı entitlements, `production` |
| C2 | Apple SSO revocation | `credentialState(forUserID:)` cold-launch + `credentialRevokedNotification` listener |
| C3 | In-app account deletion | Backend `delete-account` edge function deployed + ProfileView "hesabı sil" + UD reset |
| C4 | $0.50/gün cost ceiling | generate-replies'da `usage_daily.llm_cost_usd >= 0.50` → 429 |
| C5 | `remaining_today` server-truth | SSE done event'inde, iOS VM track, HomeView chip server'a tercih veriyor |
| C6 | SDK privacy manifest minimum | Supabase 2.21+, RC 5.20+, PostHog 3.16+, Sentry 8.36+, Mixpanel 4.3+, Lottie 4.5+ |

---

## ⏳ Kalan iş

### Faz C — iOS stability (3 fix, ~1 saat)

**Generation Task cancel on backToHome**
- Şu an: SSE in-flight iken `vm.backToHome()` çağrılırsa Task devam ediyor (kota harcar, kullanıcı home'da).
- Yapılacak: HomeViewModel'a `private var generationTask: Task<Void, Never>?`, runRealGeneration/runManualGeneration/runTonlaGeneration başında set, `backToHome()`'da cancel.

**SSE idle watchdog**
- Şu an: `URLSession.bytes` 60s'e kadar stall olabiliyor, UI "yazıyor..." donar.
- Yapılacak: APIClient.invokeStream'in bytes loop'u içinde her line aralığında resetlenen Task.sleep timer; ör. 30s satır gelmezse `continuation.finish(throwing: APIError.timeout)`.

**Calendar Istanbul TZ pin**
- Şu an: iOS `Calendar.current.isDateInToday` cihaz TZ; backend `new Date().toISOString().slice(0,10)` UTC. Mismatch.
- Yapılacak:
  - `Core/Storage/Calendar+Istanbul.swift` → `static let istanbul = Calendar(...)` Europe/Istanbul.
  - `HomeView:380` ve `ScreenshotPickerView:101` `Calendar.istanbul` kullansın.
  - Backend: helper `function todayIstanbulISODate()` → `parse-screenshot` + `generate-replies`'daki `usage_daily` lookup'ları bu helper'a geçsin.

### Faz C — Settings + UX polish (5 fix, ~1.5 saat)

**Notification toggle settings'te**
- ProfileView "kişisel" section'ına yeni satır: "bildirimler" → state badge (açık/kapalı) + tap iOS Ayarlar'a gönderir (UNUserNotificationCenter.current().getNotificationSettings ile current state oku).

**EmailSignInSheet hide (CLAUDE.md Phase 6 directive)**
- SignInView:28 yorumda "Phase 6'da gizlenir" diye yazıyor. Apple SSO yeterli; email path Release config'te `#if DEBUG` ile gate.

**PaywallView restore failure UI**
- `runRestore()` false dönerse şu an sessiz. Alert: "satın alma bulunamadı. mağazadan satın aldığından emin misin?".

**VoiceSampleEditorView load fail guard**
- `load()` fail olursa editor enabled + boş, kullanıcı save edince mevcut sample'ı silebilir. Fail'de error state göster, save disable.

**Chip 44pt hit-target**
- `DesignSystem/Components/Chip.swift` şu an ~36pt. `.frame(minHeight: 44)` veya `.contentShape(Rectangle()).frame(minHeight: 44)` ekle.

### Faz D — TestFlight (~1 saat manuel)

**DEVELOPMENT_TEAM**
- `project.yml` settings.base.DEVELOPMENT_TEAM şu an boş; kendi Apple Developer Team ID'ni gir.

**Signing**
- Xcode'da Gicik target → Signing & Capabilities → Automatically manage signing tick + Team seç.
- Provisioning profile'lar otomatik üretilir.

**Archive**
- Xcode Product → Archive (Generic iOS Device).
- Organizer → Distribute App → TestFlight & App Store → Upload.

**App Store Connect**
- Bundle ID `to.tikla.gicik` register et.
- App icon (1024×1024) yükle (placeholder zaten var, custom design hazır olunca değiştir).
- Screenshots (en az 6.7" iPhone — 1290×2796).
- Privacy questionnaire doldur (PrivacyInfo zaten guideline'da).
- "App Privacy" section: Photos/Videos, Email Address, User ID, Other User Content (asistan obs, opener), Product Interaction, Crash Data, Performance Data, Purchase History.
- Subscription: weekly product ID `gicik_weekly` (CLAUDE.md), price + duration + auto-renew terms.

**Test invite**
- TestFlight → Internal Testing → 1-2 kişi email invite.
- 50 closed beta için External Testing'e geç (Apple review 1-2 gün).

---

## Skip ettiğimiz / sonraya bıraktığımız

- **Yıllık ürün (₺499)** — user direkt skip dedi.
- **Trial sandbox testing** — manuel, sende.
- **Webhook canlı test (RC → Supabase)** — manuel, sende.
- **AI consent backend sync** — Phase 7+ (UD lokal şu an, server-side yok).
- **Push token send** — `AppDelegate.swift:20` TODO Phase 7.
- **AppFont scaledFont chokepoint** — 50+ site Dynamic Type, post-launch.
- **HomeView 4-bool sheet → enum HomePresentation** — refactor, post-launch.
- **Test vacuum** — 0 ViewModel/APIClient unit test, post-launch.
- **Logger / structured logging** — print yok ama Logger de yok, post-launch.
- **Empty Modes/ klasörü** silme — kozmetik.

---

## Önemli backend-side state

**Edge functions (deployed):**
- `parse-screenshot` v7+ (manual_input branch)
- `generate-replies` v11+ (cost ceiling, remaining_today)
- `calibrate` v5
- `delete-account` v1 (yeni, Apple 5.1.1)
- `cleanup-storage` v1 (cron tarafından çağrılıyor)
- `create-text-conversation` v1 (tonla)
- `prompt-feedback` v1
- `revenuecat-webhook` v1 (canlı test edilmedi)

**pg_cron jobs:**
- `cleanup-old-screenshots`: jobid=1, schedule `0 3 * * *` (UTC), aktif. service_role_key vault'tan okur.

**Supabase Vault secrets:**
- `service_role_key` (cron tarafından kullanılıyor)

**DB migrations applied:**
- `20260101000000_initial_schema.sql`
- `20260101000100_storage_screenshots.sql`
- `20260429000000_add_tonla_mode.sql`
- `20260501000000_schedule_cleanup_cron.sql` (manuel apply edildi via supabase db query --linked)

**Prompts (DB'de seeded):**
- L0 identity
- L1 cevap, acilis (v3), tonla (v2), davet (v2)
- L2 constraints
- L3 schemas
- L4 runtime template
- 5 tone (flortoz, esprili, direkt, sicak, gizemli)
- 6 archetype prompts
- stage1 vision parser

---

## Test scriptleri

```bash
cd gicik-backend
set -a && source .env.local && set +a

# Eval matrix per mode (Anthropic API kullanır)
deno run --allow-read --allow-net --allow-env scripts/test-acilis.ts
deno run --allow-read --allow-net --allow-env scripts/test-davet.ts
deno run --allow-read --allow-net --allow-env scripts/test-tonla.ts
deno run --allow-read --allow-net --allow-env scripts/test-matrix.ts        # cevap × archetype
deno run --allow-read --allow-net --allow-env scripts/test-archetypes.ts
deno run --allow-read --allow-net --allow-env scripts/test-tones.ts

# Prompt seed
deno run --allow-read --allow-net --allow-env scripts/seed-prompts.ts
```

---

## Audit raporları (referans)

- `scratch/health-check-2026-05-01.md` — unified prod-readiness
- `scratch/audit-prod-bugs-2026-05-01.md`
- `scratch/audit-ux-deadends-2026-05-01.md`
- `scratch/audit-launch-readiness-2026-05-01.md`
- `scratch/health-check-2026-04-30.md` — önceki round
