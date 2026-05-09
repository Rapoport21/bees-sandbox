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
    /// Pattern: two quick light taps (bee landing), a soft continuous
    /// buzz (wings), then a solid settle thud (the hive crystallizing).
    /// ~0.7s total. Idempotent — subsequent calls in the same app
    /// session no-op.
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

        // Beat 1 — quick tap (bee approaches)
        events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.55),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.85)
        ], relativeTime: 0))

        // Beat 2 — second tap (lands)
        events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.85)
        ], relativeTime: 0.09))

        // Beat 3 — continuous buzz (wings, hive activity)
        events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
        ], relativeTime: 0.2, duration: 0.32))

        // Beat 4 — solid settle (hive crystallizes)
        events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
        ], relativeTime: 0.6))

        // Continuous-event intensity ramp: fade in then out so the
        // buzz feels alive, not a flat hum.
        let intensityCurve = CHHapticParameterCurve(
            parameterID: .hapticIntensityControl,
            controlPoints: [
                .init(relativeTime: 0.0, value: 0.0),
                .init(relativeTime: 0.12, value: 0.55),
                .init(relativeTime: 0.32, value: 0.0)
            ],
            relativeTime: 0.2
        )

        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: [intensityCurve])
            let player = try engine.makePlayer(with: pattern)
            try engine.start()
            try player.start(atTime: 0)
        } catch {
            // Silent — fall back to a single notification haptic.
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
