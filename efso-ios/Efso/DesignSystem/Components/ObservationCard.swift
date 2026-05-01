import SwiftUI

/// Asistan sesi — Efso'ın kullanıcıya konuşması.
/// Italic body + leading sparkles icon (lime accent) + glass card.
/// ASLA çıktı mesajı içermez.
///
/// Önceki tasarımdaki 3pt side-stripe banlanmış pattern'di;
/// leading icon onun yerini alıyor.
struct ObservationCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColor.lime)
                .padding(.top, 3)
                .accessibilityHidden(true)

            Text(text.trLower)
                .font(AppFont.body(15))
                .italic()
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(15 * 0.45)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel("gözlem: \(text)")

            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColor.bg1.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AppColor.text05, lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        ObservationCard(text: "3 gün cevap yok, sonra 'selam'. yazmamış sayılır.")
        ObservationCard(text: "konuşma 5 turdur dönüyor. kim daveti açacak?")
    }
    .padding(24)
    .background(CosmicBackground())
    .preferredColorScheme(.dark)
}
