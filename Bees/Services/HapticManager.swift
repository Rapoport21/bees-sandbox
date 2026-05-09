import Foundation
import CoreHaptics
import UIKit

/// Custom Core Haptics patterns for moments that need more than the
/// stock UIImpactFeedbackGenerator. Single shared engine — Core Haptics
/// handles its own thread safety and stops automatically when the app
/// backgrounds.
final class HapticManager {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?
    private let supportsHaptics: Bool
    private var hasFiredLaunchSequence = false

    private init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            // The engine stops automatically on certain events
            // (audio session interruption, app backgrounded). Restart
            // it on the next play attempt rather than holding it open.
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            engine?.stoppedHandler = { _ in /* will lazy-restart */ }
            try engine?.start()
        } catch {
            // Silent failure — haptics are polish, not core function.
            engine = nil
        }
    }

    /// Plays once on the first ContentView render after a cold launch.
    /// All-transient (no continuous bed) percussive pattern — punchy
    /// staccato instead of a swelling buzz. ~1.85s, 19 taps:
    ///
    /// - **Intro (0.00 – 0.15s)** — dot-dot-TAP, three crisp clicks
    ///   ending on an accent
    /// - **Build (0.32 – 0.53s)** — quick four-step roll climbing in
    ///   intensity, accent on beat 4
    /// - **Climax (0.70 – 1.00s)** — six rapid sharp taps, ending on
    ///   the first BIG HIT (intensity 1.0, sharpness 0.85)
    /// - **Aftermath (1.18 – 1.34s)** — three-tap follow-up to a
    ///   second big hit
    /// - **Fade (1.54 – 1.78s)** — three sharp echoes tapering
    ///
    /// All taps run at high sharpness (0.85–1.0) for clicky, crisp
    /// feel; only the two big hits drop to ~0.85 so they read as
    /// impact rather than ping. Intensity ranges 0.2 – 1.0 for
    /// dynamics. Idempotent — subsequent calls in the same session
    /// no-op.
    func playLaunchSequence() {
        guard !hasFiredLaunchSequence else { return }
        hasFiredLaunchSequence = true

        guard supportsHaptics, let engine else {
            // Fallback: stock notification feedback if Core Haptics is
            // unavailable (older device, simulator).
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }

        // (time, intensity, sharpness)
        let taps: [(TimeInterval, Float, Float)] = [
            // Intro — dot dot TAP
            (0.00, 0.55, 1.0),
            (0.07, 0.55, 1.0),
            (0.15, 0.80, 1.0),

            // Build — four-step roll, accent on beat 4
            (0.32, 0.45, 0.95),
            (0.39, 0.55, 0.95),
            (0.46, 0.65, 0.95),
            (0.54, 0.85, 1.0),

            // Climax — rapid burst into a BIG HIT
            (0.70, 0.55, 1.0),
            (0.76, 0.65, 1.0),
            (0.82, 0.75, 1.0),
            (0.88, 0.85, 1.0),
            (0.94, 0.95, 1.0),
            (1.00, 1.00, 0.85),  // BIG HIT — slight bass for impact

            // Aftermath — three taps into second big hit
            (1.20, 0.60, 1.0),
            (1.27, 0.80, 1.0),
            (1.34, 1.00, 0.90),  // SECOND BIG HIT

            // Fade — three crisp echoes
            (1.54, 0.50, 1.0),
            (1.66, 0.35, 1.0),
            (1.78, 0.25, 1.0),
        ]

        let events = taps.map { (time, intensity, sharpness) in
            CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: time)
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try engine.start()
            try player.start(atTime: 0)
        } catch {
            // Silent — fall back to a single notification haptic.
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
