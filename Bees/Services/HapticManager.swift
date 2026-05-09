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
    /// Four-phase ~2s bee-swarm sequence:
    ///
    /// 1. **Approach (0.0 – 0.4s)** — sparse light taps over a low
    ///    distant buzz; first bee.
    /// 2. **Build (0.4 – 1.0s)** — taps cluster, buzz climbs in
    ///    intensity and sharpness; the swarm gathers.
    /// 3. **Climax (1.0 – 1.55s)** — dense rapid taps with peak
    ///    intensity and bright sharpness; full swarm.
    /// 4. **Settle (1.55 – 1.95s)** — a single hard low-sharpness
    ///    thud (the hive landing) followed by two soft echoes.
    ///
    /// Idempotent — subsequent calls in the same session no-op.
    func playLaunchSequence() {
        guard !hasFiredLaunchSequence else { return }
        hasFiredLaunchSequence = true

        guard supportsHaptics, let engine else {
            // Fallback: stock notification feedback if Core Haptics is
            // unavailable (older device, simulator).
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }

        var events: [CHHapticEvent] = []

        // Continuous buzz bed — runs almost the whole pattern. The
        // intensity and sharpness CONTROL curves sculpt it over time
        // so the same continuous event reads as approaching → building
        // → climaxing → tapering.
        events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ], relativeTime: 0.0, duration: 1.85))

        // Transient taps over the bed. (time, intensity, sharpness)
        // Times are absolute relative to the pattern start.
        let taps: [(TimeInterval, Float, Float)] = [
            // Phase 1 — Approach (sparse, light, fairly sharp)
            (0.05, 0.35, 0.75),
            (0.22, 0.45, 0.78),
            (0.35, 0.40, 0.80),
            // Phase 2 — Build (clustering, mid intensity, sharper)
            (0.48, 0.55, 0.82),
            (0.58, 0.65, 0.85),
            (0.70, 0.55, 0.88),
            (0.80, 0.70, 0.85),
            (0.92, 0.75, 0.80),
            // Phase 3 — Climax (dense, peak, brightest)
            (1.05, 0.85, 0.78),
            (1.13, 0.90, 0.72),
            (1.22, 0.95, 0.62),
            (1.30, 0.95, 0.48),
            (1.38, 0.90, 0.38),
            // Phase 4 — Settle (heavy thud + soft echoes)
            (1.52, 1.00, 0.18),  // hard hive-lands thud, low sharpness = bass
            (1.72, 0.45, 0.55),  // first echo
            (1.86, 0.30, 0.65),  // second echo
        ]
        for (time, intensity, sharpness) in taps {
            events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: time))
        }

        // Intensity curve for the continuous bed: starts at 0 (silent
        // bed), builds, peaks during climax, then drops sharply to
        // give the settle phase room to breathe.
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0.00, value: 0.00),
                .init(relativeTime: 0.30, value: 0.40),
                .init(relativeTime: 0.65, value: 0.65),
                .init(relativeTime: 1.05, value: 0.90),
                .init(relativeTime: 1.40, value: 1.00),
                .init(relativeTime: 1.55, value: 0.20),  // hard drop after thud
                .init(relativeTime: 1.85, value: 0.00),
            ],
            relativeTime: 0
        )

        // Sharpness curve: starts round/muddy (distant buzz), gets
        // bright at the climax (alarming swarm), drops to bass at the
        // settle (low rumble landing).
        let sharpnessCurve = CHHapticParameterCurve(
            parameterID: .hapticSharpnessControl,
            controlPoints: [
                .init(relativeTime: 0.00, value: 0.30),
                .init(relativeTime: 0.60, value: 0.55),
                .init(relativeTime: 1.10, value: 0.80),
                .init(relativeTime: 1.40, value: 0.65),
                .init(relativeTime: 1.55, value: 0.20),
                .init(relativeTime: 1.85, value: 0.30),
            ],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: [intensityCurve, sharpnessCurve])
            let player = try engine.makePlayer(with: pattern)
            try engine.start()
            try player.start(atTime: 0)
        } catch {
            // Silent — fall back to a single notification haptic.
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
