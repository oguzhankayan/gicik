import SwiftUI

/// Asistan sesi — Gıcık'ın kullanıcıya konuşması.
/// Italik body + lime stripe + glass card. ASLA çıktı mesajı içermez.
struct ObservationCard: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Capsule()
                .fill(AppColor.lime)
                .frame(width: 3)

            Text(text.lowercased())
                .font(AppFont.body(15))
                .italic()
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(15 * 0.45)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 14)
        .padding(.leading, 13)
        .padding(.trailing, 16)
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
