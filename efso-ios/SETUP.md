# efso-ios — Setup Guide

Sıfırdan Xcode projesini ayağa kaldırma. **5-10 dakika.**

## Önkoşul

```bash
brew install xcodegen
brew install supabase/tap/supabase
```

## Adımlar

### 1. xcconfig dosyalarını oluştur

```bash
cd efso-ios
cp Debug.xcconfig.template Debug.xcconfig
cp Release.xcconfig.template Release.xcconfig
```

İkisi de gitignore'da. Gerçek anahtarları içlerine yaz:
- `SUPABASE_URL` + `SUPABASE_ANON_KEY` (zorunlu)
- `REVENUECAT_API_KEY` (Phase 4 — yoksa premium DEBUG'da otomatik açık, asserts release'de fail eder)
- `SENTRY_DSN`, `POSTHOG_API_KEY`, `MIXPANEL_TOKEN` (opsiyonel, boşsa no-op)

### 2. Xcode projesini üret

```bash
xcodegen generate
```

`project.yml`'den `Efso.xcodeproj` üretir. SPM dependencies otomatik:
- supabase-swift (≥2.21), RevenueCat (≥5.20), PostHog (≥3.16), Sentry (≥8.36), Mixpanel (≥4.3), Lottie (≥4.5)

Min versiyonlar Privacy Manifest taşıyan sürümler — App Store submission için.

### 3. Xcode'da aç

```bash
open Efso.xcodeproj
```

İlk açılışta Xcode SPM paketlerini indirir (1-2 dakika).

### 4. Apple Developer Team + capabilities

1. `Efso` target → `Signing & Capabilities` tab
2. **Team** seç (Apple Developer Team ID)
3. project.yml içindeki `DEVELOPMENT_TEAM` boş — Xcode'dan team seçince auto-doldurur, ya da `project.yml` settings.base.DEVELOPMENT_TEAM kendin yaz, regen et.
4. Capability'ler zaten entitlements üzerinden tanımlı:
   - **Sign in with Apple** ✓ (Default)
   - **Push Notifications** — Debug `aps-environment=development`, Release `production` (ayrı entitlements file)

### 5. Fontları indir + ekle

1. **Space Grotesk** — https://fonts.google.com/specimen/Space+Grotesk (Regular/Medium/SemiBold/Bold)
2. **JetBrains Mono** — https://fonts.google.com/specimen/JetBrains+Mono (Regular/Medium)

`Efso/Resources/Fonts/` klasörüne kopyala. xcodegen `UIAppFonts` Info.plist'e otomatik ekler.

### 6. Supabase backend

Backend kurulumu için: `efso-backend/README.md`. Hızlı versiyon:

```bash
cd ../efso-backend
supabase login
supabase link --project-ref <project-ref>
supabase db push
deno run --allow-read --allow-net --allow-env scripts/seed-prompts.ts
supabase functions deploy parse-screenshot generate-replies calibrate \
  delete-account cleanup-storage prompt-feedback create-text-conversation
```

Supabase Dashboard'da:
- **Auth → Providers → Apple** → enable, bundle ID + key
- **Storage → Buckets** → `screenshots` (migration auto-create)
- **Database → Extensions** → pg_cron + pg_net ON
- **Vault** → `service_role_key` ekle (cron için)

### 7. Build + Run

Xcode → Scheme `Efso`, Destination iPhone simulator (iOS 17+) → ⌘R.

İlk build kontrol:
- SignInView: logo + "yazma. efso yazsın." + Apple butonu
- Apple SSO → onboarding (12 ekran) → calibration reveal → demo upload → paywall → home

## TestFlight (Faz D)

Submission'a hazırsın. Adımlar:

1. **Archive**: Xcode → Product → Destination "Any iOS Device (arm64)" → Product → Archive
2. **Distribute**: Organizer → Distribute App → TestFlight & App Store → Upload
3. **App Store Connect**:
   - Bundle ID `to.tikla.efso` register
   - App icon (1024×1024) — placeholder zaten var, custom hazır olunca değiştir
   - Screenshots (en az 6.7" iPhone — 1290×2796), %30+ non-dating
   - Privacy questionnaire — `PrivacyInfo.xcprivacy` referansla doldur
   - Subscription product `efso_weekly` — price + duration + auto-renew terms
4. **Internal Testing** → 1-2 kişi invite
5. **External Testing** → 50 closed beta (Apple review 1-2 gün)

Detay: root `HANDOFF.md`.

## Manuel Xcode (xcodegen olmadan)

Tercih etmiyorsan:
1. Xcode → New Project → iOS App, SwiftUI, Swift 6
2. Bundle ID: `to.tikla.efso`
3. `Efso/` altındaki tüm `.swift` dosyalarını sürükleyip bırak
4. SPM dependencies tek tek ekle (project.yml `packages:`)
5. Capability'leri ekle, fontları kopyala, xcconfig'leri bağla

xcodegen yolu çok daha hızlı.

## Sorun çıkarsa

Skill: `/axiom:build-fixer` — zombi process, Derived Data, SPM cache temizler.
