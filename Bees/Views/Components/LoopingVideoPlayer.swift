import SwiftUI
import AVKit

struct LoopingVideoPlayer: UIViewRepresentable {
    let url: URL
    var isMuted: Bool = true

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
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

        return view
    }

    func updateUIView(_ view: PlayerContainerView, context: Context) {
        context.coordinator.player?.isMuted = isMuted
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var looper: AVPlayerLooper?
        var player: AVQueuePlayer?
    }
}

final class PlayerContainerView: UIView {
    let playerLayer = AVPlayerLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(playerLayer)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layer.addSublayer(playerLayer)
        backgroundColor = .black
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
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
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                return url
            }
            if let url = Bundle.main.url(forResource: "Videos/\(name)", withExtension: ext) {
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
