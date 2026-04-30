import Foundation
import Photos
import UIKit
import SwiftUI

/// PhotoKit `smartAlbumScreenshots` üzerinden son ekran görüntülerini yükler.
/// Picker ekranında Recent Strip için kullanılır.
///
/// İzin akışı: kullanıcı .notDetermined ise strip yerine "izin ver" chip'i
/// gösterilir; kullanıcı tap edince istenir. .denied ise strip tamamen gizlenir.
/// .authorized / .limited ise async fetch + UIImage thumbnail üretilir.
@Observable
@MainActor
final class RecentScreenshotsLoader {
    enum State: Equatable {
        case idle              // henüz check edilmedi
        case needsPermission   // .notDetermined — strip yerine "izin ver" CTA
        case loading
        case ready([Item])
        case denied            // .denied veya .restricted
        case empty             // izin var ama screenshots album'u boş

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.needsPermission, .needsPermission),
                 (.loading, .loading), (.denied, .denied), (.empty, .empty):
                return true
            case let (.ready(a), .ready(b)):
                return a.map(\.id) == b.map(\.id)
            default:
                return false
            }
        }
    }

    /// Strip'te gösterilen tek bir ekran görüntüsü kalemi.
    /// `id` = PHAsset.localIdentifier; `thumbnail` küçük preview;
    /// `fullData` lazy yüklenir (kullanıcı tap edince).
    struct Item: Identifiable {
        let id: String
        let asset: PHAsset
        let thumbnail: UIImage
        let createdAt: Date?
    }

    var state: State = .idle

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 240, height: 240)
    private let limit = 6

    /// Strip'i first-load'da çağır. Auth status'a göre dallanır.
    func bootstrap() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            state = .needsPermission
        case .authorized, .limited:
            Task { await fetch() }
        case .denied, .restricted:
            state = .denied
        @unknown default:
            state = .denied
        }
    }

    /// "izin ver" chip'inden çağrılır.
    func requestPermission() {
        Task { @MainActor in
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            switch status {
            case .authorized, .limited:
                await fetch()
            case .denied, .restricted:
                state = .denied
            case .notDetermined:
                state = .needsPermission
            @unknown default:
                state = .denied
            }
        }
    }

    /// Selected PHAsset → full image data. Picker tap'inde kullanılır.
    /// `deliveryMode = .highQualityFormat`, network access on (iCloud).
    func loadFullData(for asset: PHAsset) async -> Data? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            options.resizeMode = .none

            imageManager.requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { data, _, _, _ in
                continuation.resume(returning: data)
            }
        }
    }

    private func fetch() async {
        state = .loading

        let collections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumScreenshots,
            options: nil
        )
        guard let album = collections.firstObject else {
            state = .empty
            return
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false),
        ]
        fetchOptions.fetchLimit = limit

        let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        if assets.count == 0 {
            state = .empty
            return
        }

        // PHFetchResult.enumerateObjects @escaping closure'da inout group
        // capture edilemiyor — önce flat array'e dökelim, sonra task group'a besleyelim.
        var orderedAssets: [(Int, PHAsset)] = []
        assets.enumerateObjects { asset, idx, _ in
            orderedAssets.append((idx, asset))
        }

        var collected: [(Int, Item)] = []
        await withTaskGroup(of: (Int, Item?).self) { group in
            for (idx, asset) in orderedAssets {
                group.addTask { [weak self] in
                    guard let self else { return (idx, nil) }
                    let thumb = await self.requestThumbnail(for: asset)
                    guard let thumb else { return (idx, nil) }
                    let item = Item(
                        id: asset.localIdentifier,
                        asset: asset,
                        thumbnail: thumb,
                        createdAt: asset.creationDate
                    )
                    return (idx, item)
                }
            }
            for await (idx, item) in group {
                if let item { collected.append((idx, item)) }
            }
        }

        let ordered = collected.sorted { $0.0 < $1.0 }.map { $0.1 }
        state = ordered.isEmpty ? .empty : .ready(ordered)
    }

    private func requestThumbnail(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            // `.highQualityFormat` callback'i tek kez çağırır; opportunistic'te
            // continuation çift resume hatası riski var.
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.resizeMode = .fast

            imageManager.requestImage(
                for: asset,
                targetSize: thumbnailSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
