import SwiftUI
import AVKit

/// Single shared AVQueuePlayer for the hive entrance video, so the
/// reveal screen and the Hive tab can render the *same* live stream
/// without reloading or going out of sync during the morph hand-off.
@MainActor
final class HiveVideoCoordinator {
    static let shared = HiveVideoCoordinator()

    let player: AVQueuePlayer
    private var looper: AVPlayerLooper?

    private init() {
        player = AVQueuePlayer()
        player.isMuted = true
        load()
    }

    private func load() {
        guard let url = BundledVideo.url(named: "hive-entrance") else { return }
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        looper = AVPlayerLooper(player: player, templateItem: item)
        player.play()
    }
}

/// Renders the shared hive entrance video. Multiple instances share
/// one underlying AVQueuePlayer — when SwiftUI swaps views, only the
/// AVPlayerLayer is created/destroyed; the player itself keeps
/// playing without flicker.
struct SharedHiveVideoPlayer: UIViewRepresentable {
    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.player = HiveVideoCoordinator.shared.player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ view: PlayerContainerView, context: Context) {
        if view.playerLayer.player !== HiveVideoCoordinator.shared.player {
            view.playerLayer.player = HiveVideoCoordinator.shared.player
        }
    }
}

struct LoopingVideoPlayer: UIViewRepresentable {
    let url: URL
    var isMuted: Bool = true

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        configure(view: view, url: url, context: context)
        return view
    }

    func updateUIView(_ view: PlayerContainerView, context: Context) {
        if context.coordinator.currentURL != url {
            configure(view: view, url: url, context: context)
        }
        context.coordinator.player?.isMuted = isMuted
    }

    private func configure(view: PlayerContainerView, url: URL, context: Context) {
        // Tear down previous player so we don't leak items.
        context.coordinator.player?.pause()
        context.coordinator.player?.removeAllItems()
        context.coordinator.looper = nil
        context.coordinator.player = nil

        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer()
        let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)

        view.playerLayer.player = queuePlayer
        view.playerLayer.videoGravity = .resizeAspectFill

        queuePlayer.isMuted = isMuted
        queuePlayer.play()

        context.coordinator.looper = looper
        context.coordinator.player = queuePlayer
        context.coordinator.currentURL = url
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var looper: AVPlayerLooper?
        var player: AVQueuePlayer?
        var currentURL: URL?
    }
}

final class PlayerContainerView: UIView {
    // Make the view's backing layer an AVPlayerLayer directly. When
    // the parent UIView's bounds animate (e.g. SwiftUI .frame change
    // during the reveal→hive morph), this layer's bounds animate in
    // lockstep — no separate sublayer means no black bars while the
    // rounded rect widens.
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
    }
}

enum BundledVideo {
    static let preferredCameras = ["hive-entrance", "hive-internal", "hive-topdown"]
    static let supportedExtensions = ["mp4", "mov", "m4v"]

    static func firstAvailable() -> URL? {
        for name in preferredCameras {
            if let url = url(named: name) { return url }
        }
        return discoverAny()
    }

    static func url(named name: String) -> URL? {
        for ext in supportedExtensions {
            // Bundle root
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
            // Videos/ subdirectory (folder reference)
            if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Videos") {
                return url
            }
        }
        return nil
    }

    private static func discoverAny() -> URL? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let videosDir = (resourcePath as NSString).appendingPathComponent("Videos")
        let fm = FileManager.default
        let candidates = [videosDir, resourcePath]
        for dir in candidates {
            guard let files = try? fm.contentsOfDirectory(atPath: dir) else { continue }
            for file in files {
                let lower = file.lowercased()
                if supportedExtensions.contains(where: { lower.hasSuffix(".\($0)") }) {
                    return URL(fileURLWithPath: (dir as NSString).appendingPathComponent(file))
                }
            }
        }
        return nil
    }
}
