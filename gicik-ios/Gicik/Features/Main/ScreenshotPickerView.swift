import SwiftUI
import PhotosUI

/// Screenshot picker — 3 state: empty (PhotosPicker), uploading (shimmer overlay),
/// done (full-fit preview + holographic border + checkmark).
struct ScreenshotPickerView: View {
    @Bindable var vm: HomeViewModel
    let mode: Mode

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    contentArea
                        .padding(.top, 22)
                    privacyHint
                        .padding(.top, 14)
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - TopBar

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
            Color.clear.frame(width: 24, height: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("KONUŞMANIN EKRAN\nGÖRÜNTÜSÜNÜ YÜKLE")
                .font(AppFont.display(22, weight: .bold))
                .tracking(-0.02 * 22)
                .foregroundColor(.white)
                .lineSpacing(22 * 0.06)
                .fixedSize(horizontal: false, vertical: true)

            Text("konuşmanın olduğu kadarı göstermen yeter. kim olduğun gizli kalır.")
                .font(AppFont.body(13))
                .foregroundColor(AppColor.text60)
                .lineSpacing(13 * 0.40)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Content

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
        PhotosPicker(selection: $vm.pickedItem, matching: .images, photoLibrary: .shared()) {
            VStack(spacing: 14) {
                Image(systemName: "arrow.up.to.line.compact")
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(AppColor.text60)
                Text("fotoğraflardan seç")
                    .font(AppFont.body(16, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                Text("tek karede tüm konuşma görünsün")
                    .font(AppFont.body(12))
                    .foregroundColor(AppColor.text40)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        AppColor.text20,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 6])
                    )
            )
        }
    }

    private var uploadingState: some View {
        VStack(spacing: 18) {
            if let data = vm.pickedScreenshot, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(AppColor.text10, lineWidth: 1)
                    )
                    .opacity(0.75)
                    .accessibilityLabel("yüklenen ekran görüntüsü")
            }

            HStack(spacing: 10) {
                ProgressView()
                    .tint(AppColor.lime)
                    .scaleEffect(0.9)
                Text("yorumlanıyor")
                    .font(AppFont.body(14, weight: .medium))
                    .foregroundColor(AppColor.text60)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("ekran görüntüsü yorumlanıyor")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func doneState(thumbnail data: Data) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            // Arketip etiketi (kim olduğun)
            HStack(spacing: 8) {
                Text(archetypeEmoji)
                    .font(.system(size: 16))
                Text("\(archetypeShortLabel) tarzında")
                    .font(AppFont.mono(11))
                    .tracking(0.04 * 11)
                    .foregroundColor(AppColor.text60)
                Spacer()
            }

            ZStack(alignment: .topTrailing) {
                if let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                }
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
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(AppColor.lime, lineWidth: 1.5)
            )
        }
    }

    // MARK: - Privacy hint

    private var privacyHint: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
                .foregroundColor(AppColor.text40)
                .padding(.top, 1)
            Text("yüklediğin ekran görüntüsü 24 saat sonra otomatik silinir.")
                .font(AppFont.body(12))
                .foregroundColor(AppColor.text40)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        switch vm.pickerState {
        case .done:
            HStack(spacing: 10) {
                SecondaryButton(title: "değiştir") {
                    vm.resetPicker()
                }
                PrimaryButton("devam") {
                    vm.proceedToGeneration()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        case .empty, .uploading:
            EmptyView()
        }
    }

    // MARK: - Computed

    private var archetypeEmoji: String {
        guard let a = vm.archetype else { return "✨" }
        return String(a.label.first ?? "✨")
    }

    private var archetypeShortLabel: String {
        guard let a = vm.archetype else { return "" }
        let parts = a.label.split(separator: " ", maxSplits: 1)
        return (parts.last.map(String.init) ?? "").lowercased()
    }
}
