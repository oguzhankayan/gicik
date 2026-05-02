import SwiftUI

/// Asistan sesi (legacy glass card varyantı). Refined ekranlarda
/// `AssistantObservationCard` (pull-quote, mor sol-bordür) tercih edin.
/// Geriye uyumluluk için bu glass form korundu.
struct ObservationCard: View {
    let text: String

    var body: some View {
        AssistantObservationCard(text: text, fontSize: 15, showLabel: false)
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
