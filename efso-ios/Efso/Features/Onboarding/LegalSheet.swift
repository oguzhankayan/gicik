import SwiftUI
import SafariServices

/// Şartlar & gizlilik için in-app SafariView wrapper.
/// efso.app/terms ve efso.app/privacy yayına alındığında doğrudan
/// çalışır. Yayına alınmadıysa kullanıcı 404 görür; submission öncesi
/// URL'lerin live olduğundan emin ol.
///
/// Submission blocker: efso.app/{terms,privacy} sayfaları yayına alınmalı.
struct LegalSheet: View {
    enum Kind { case terms, privacy }

    let kind: Kind
    let onClose: () -> Void

    var body: some View {
        SafariViewWrapper(url: url)
            .ignoresSafeArea()
    }

    private var url: URL {
        switch kind {
        case .terms: URL(string: "https://efso.app/terms")!
        case .privacy: URL(string: "https://efso.app/privacy")!
        }
    }
}

private struct SafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(AppColor.bg0)
        vc.preferredControlTintColor = UIColor(AppColor.lime)
        vc.dismissButtonStyle = .close
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview("terms") {
    LegalSheet(kind: .terms, onClose: {})
        .preferredColorScheme(.dark)
}

#Preview("privacy") {
    LegalSheet(kind: .privacy, onClose: {})
        .preferredColorScheme(.dark)
}
