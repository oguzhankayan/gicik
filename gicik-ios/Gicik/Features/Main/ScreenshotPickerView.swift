import SwiftUI
import PhotosUI

/// Screenshot picker — 3 state: empty (PhotosPicker), uploading (shimmer overlay),
/// done (holographic border + checkmark).
/// design-source/parts/main.jsx → PickerEmpty / PickerProgress / PickerComplete
struct ScreenshotPickerView: View {
    @Bindable var vm: HomeViewModel
    let mode: Mode

    var body: some View {
        VStack(spacing: 0) {
            topBar
            header
            contentArea
            Spacer()
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var topBar: some View {
        HStack {
            Button { vm.backToHome() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            Spacer()
            Text("\(mode.label.lowercased()) modu")
                .font(AppFont.body(16))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Color.clear.frame(width: 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EKRAN GÖRÜNTÜSÜNÜ\nYÜKLE")
                .font(AppFont.display(24, weight: .bold))
                .tracking(-0.02 * 24)
                .foregroundColor(.white)
                .lineSpacing(24 * 0.05)

            Text("konuşmanın olduğu kadar göstermen yeter.\nkim olduğun gizli kalır.")
                .font(AppFont.body(14))
                .foregroundColor(AppColor.text60)
                .lineSpacing(14 * 0.45)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var contentArea: some View {
        switch vm.pickerState {
        case .empty:
            emptyState
        case .uploading:
            uploadingState
        case .done(let data):
            doneState(thumbnail: data)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $vm.pickedItem, matching: .images, photoLibrary: .shared()) {
                VStack(spacing: 14) {
                    Image(systemName: "arrow.up.to.line.compact")
                        .font(.system(size: 42, weight: .light))
                        .foregroundColor(AppColor.text60)
                    Text("fotoğraflardan seç")
                        .font(AppFont.body(16))
                        .foregroundColor(.white.opacity(0.85))
                    Text("veya buraya sürükle")
                        .font(AppFont.body(13))
                        .foregroundColor(AppColor.text40)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(AppColor.text20,
                                      style: StrokeStyle(lineWidth: 1.5, dash: [6, 6]))
                )
            }

            // Privacy obs (non-italic, smaller)
            HStack(alignment: .top, spacing: 14) {
                Capsule()
                    .fill(AppColor.lime)
                    .frame(width: 3)
                Text("screenshot 24 saat sonra silinir. isimleri otomatik bulanıklaştırırız (deneysel).")
                    .font(AppFont.body(13))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(13 * 0.40)
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
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    private var uploadingState: some View {
        ZStack(alignment: .bottomLeading) {
            // Faux gradient bg
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0x2D1B4E), Color(hex: 0x1A0F2E)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let data = vm.pickedScreenshot, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 4)
                    .clipped()
            }

            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.6)
                .shimmer()

            HStack {
                Circle().fill(AppColor.lime).frame(width: 8, height: 8)
                Text("yorumlanıyor…")
                    .font(AppFont.body(14))
                    .foregroundColor(.white)
            }
            .padding(16)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color(hex: 0x0A0612, alpha: 0.95), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(AppColor.text10, lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    private func doneState(thumbnail data: Data) -> some View {
        ZStack(alignment: .topTrailing) {
            if let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 280)
                    .clipped()
            }

            // Holographic border overlay
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(AppColor.holographic, lineWidth: 1.5)
                .frame(height: 280)

            Circle()
                .fill(AppColor.lime)
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColor.bg0)
                )
                .padding(10)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    @ViewBuilder
    private var footer: some View {
        switch vm.pickerState {
        case .done:
            PrimaryButton("devam") {
                vm.proceedToGeneration()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        case .empty, .uploading:
            SecondaryButton(title: "örnek görüntü kullan", action: {
                // TODO: load bundled sample, advance.
            })
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
