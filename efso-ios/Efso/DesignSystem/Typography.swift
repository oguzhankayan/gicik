import SwiftUI

// efso — typography (refined y2k)
// Display: Fraunces italic (editorial serif). Henüz font dosyası eklenmedi —
// `.serif` tasarım + .italic ile sistem serif fallback kullanılır (Apple "New York").
// Fraunces .ttf eklenince `displayItalic` içindeki TBD bloğu açılır.
// Body: Geist sans (henüz dosya yok → sistem default sans). Hedef: SF Pro yerine Geist.
// Mono: JetBrains Mono → hedef Geist Mono. Mevcut JetBrains tutuldu (uyumlu fallback).

// TBD: Dynamic Type — displayItalic ve body şu an .system(size:...) ile sabit boyut üretiyor.
// Custom font dosyaları (Fraunces, Geist) eklenince .custom(face, size:, relativeTo:) ile
// Dynamic Type desteği sağlanacak. mono() zaten bu pattern'i kullanıyor.
// Post-launch Phase 7 backlog'unda takip ediliyor.

enum AppFont {
    /// Display — eski Y2K ALL CAPS yerine: küçük harf, italik serif, büyük etki.
    /// Refined Y2K'de display sadece bir-iki kelime için kullanılır.
    static func displayItalic(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        // TBD: Fraunces-Italic.ttf eklenince:
        //   .custom("Fraunces-Italic", size: size, relativeTo: .title).weight(weight)
        .system(size: size, weight: weight, design: .serif).italic()
    }

    /// Display (legacy) — Space Grotesk variable. Yeni ekranlarda `displayItalic` tercih edin.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom("SpaceGrotesk-Light", size: size).weight(weight)
    }

    /// Body — Geist sans hedefi; şu an SF Pro fallback.
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // TBD: Geist eklenince `.custom("Geist-Regular", size: size, relativeTo: .body).weight(weight)`.
        .system(size: size, weight: weight, design: .default)
    }

    /// Mono — UPPERCASE label tarzı (mod prefix, etiket, mono açıklama).
    /// Hedef: Geist Mono. Şu an JetBrains Mono fallback.
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        let face = weight == .medium ? "JetBrainsMono-Medium" : "JetBrainsMono-Regular"
        return .custom(face, size: size, relativeTo: .body)
    }
}
