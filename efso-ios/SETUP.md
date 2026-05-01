# efso-ios — Setup Guide

Phase 0.3 — sıfırdan Xcode projesini ayağa kaldırma. **5-10 dakika.**

## Önkoşul

```bash
brew install xcodegen
```

(xcodegen istemiyorsan en alttaki "manuel Xcode" yolunu izle.)

## Adımlar

### 1. xcconfig dosyalarını oluştur

```bash
cd efso-ios
cp Debug.xcconfig.template Debug.xcconfig
cp Release.xcconfig.template Release.xcconfig
```

`Debug.xcconfig` ve `Release.xcconfig` zaten `.gitignore`'da. **Gerçek anahtarları içlerine yaz** (Supabase URL, anon key, vb.).

İlk başta sadece Supabase URL + anon key yeterli. Diğerleri (Sentry, PostHog, Mixpanel, RevenueCat) Phase 0+'da boş kalabilir; ilgili `bootstrap` fonksiyonları `nil`/`empty` durumunda no-op davranır.

### 2. Xcode projesini üret

```bash
xcodegen generate
```

Bu `project.yml`'den `Efso.xcodeproj` üretir. SPM dependencies otomatik tanımlı:
- supabase-swift
- RevenueCat
- PostHog
- Sentry
- Mixpanel
- Lottie

### 3. Xcode'da aç

```bash
open Efso.xcodeproj
```

İlk açılışta Xcode SPM paketlerini indirir (1-2 dakika).

### 4. xcconfig'leri Xcode'a bağla

Xcode'da:
1. Proje navigator'da `Efso` (en üst) → seç
2. `Project` (target değil, project) → `Info` tab
3. `Configurations` altında:
   - **Debug** → `Efso` target'ı için → `Debug` config seç
   - **Release** → `Efso` target'ı için → `Release` config seç

> xcodegen otomatik bağlamadıysa manuel yap. Sonra `Configuration.swift`'teki env vars çalışır.

### 5. Apple Sign In capability

1. `Efso` target → `Signing & Capabilities` tab
2. Team seç (Apple Developer Team ID)
3. `+ Capability` → "Sign in with Apple" ekle
4. Push Notifications capability'sini de ekle (Phase 7'de kullanılacak)

### 6. Fontları indir + ekle

1. **Space Grotesk** — https://fonts.google.com/specimen/Space+Grotesk
   - Regular, Medium, SemiBold, Bold (4 dosya)
2. **JetBrains Mono** — https://fonts.google.com/specimen/JetBrains+Mono
   - Regular, Medium (2 dosya)

İndirilenleri `Efso/Resources/Fonts/` klasörüne kopyala. xcodegen sonra `UIAppFonts` Info.plist'e ekledi (project.yml'de tanımlı).

### 7. Supabase backend'i deploy et

Önce backend kuralım — bu olmadan auth çalışmaz.

```bash
cd ../efso-backend
brew install supabase/tap/supabase

supabase login
supabase link --project-ref <senin-supabase-project-ref>
supabase db push       # migrations'ı uygula
supabase functions deploy calibrate
```

Supabase Dashboard'da:
- **Auth → Providers → Apple** → enable, Apple bundle ID + key bilgilerini gir
- **Storage → Buckets** → `screenshots` bucket'ı görmeli (migration auto-create)

### 8. Build + Run

Xcode'a dön:
- Scheme: `Efso`
- Destination: `iPhone 17 Pro` simulator (iOS 17+)
- ⌘R çalıştır

İlk build:
- `SignInView` görünmeli (logo + "yazma. efso yazsın." + Apple butonu)
- Apple ile giriş → Supabase Apple SSO → success → `HomeView` (placeholder)
- "çıkış yap" butonu → `SignInView`'e dönüş

### 9. Sentry crash test

`HomeView.swift`'te geçici olarak ekle:
```swift
PrimaryButton("crash") { fatalError("test crash") }
```

Çalıştır, butonua bas, crash'i Sentry dashboard'da gör. Sonra sil.

## Phase 0 DoD ✅

- [ ] Sign in with Apple çalışıyor
- [ ] HomeView placeholder görünüyor
- [ ] Sign out → SignInView dönüş
- [ ] Sentry crash test ✓
- [ ] Build warning'siz

## Sonraki

**Phase 1 Onboarding** — `BUILD_PLAN.md` Phase 1'i oku, sırasıyla 1.1'den başla.

---

## Manuel Xcode (xcodegen olmadan)

Tercih etmiyorsan:
1. Xcode → New Project → iOS App, SwiftUI, Swift 6
2. Bundle ID: `to.tikla.efso`
3. `efso-ios/Efso/` altındaki tüm `.swift` dosyalarını sürükleyip bırak
4. SPM dependencies'i tek tek ekle (project.yml'deki `packages:` listesi)
5. Capability'leri ekle, fontları kopyala, xcconfig'leri bağla

xcodegen yolu çok daha hızlı.

## Sorun çıkarsa

Skill: `/axiom:build-fixer` — zombi process, Derived Data, SPM cache temizler.
