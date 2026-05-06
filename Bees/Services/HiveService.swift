import Foundation
import Observation

protocol HiveService: AnyObject {
    var current: HiveSnapshot { get }
    var hive: Hive { get }
    var activity: LiveActivity { get }

    func startSimulating()
    func stopSimulating()
}

@Observable
final class MockHiveService: HiveService {
    private(set) var current: HiveSnapshot
    private(set) var hive: Hive
    private(set) var activity: LiveActivity

    private var timer: Timer?

    init(hive: Hive, snapshot: HiveSnapshot, activity: LiveActivity) {
        self.hive = hive
        self.current = snapshot
        self.activity = activity
    }

    func startSimulating() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func rename(_ name: String) {
        hive.name = name
    }

    func stopSimulating() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let takeoffDelta = Int.random(in: 0...3)
        let landingDelta = Int.random(in: 0...3)

        activity = LiveActivity(
            takeoffsLast60s: max(0, activity.takeoffsLast60s + takeoffDelta - 1),
            landingsLast60s: max(0, activity.landingsLast60s + landingDelta - 1),
            rollingTakeoffs: activity.rollingTakeoffs + takeoffDelta,
            rollingLandings: activity.rollingLandings + landingDelta
        )

        let tempDrift = Double.random(in: -0.3...0.3)
        let humDrift = Double.random(in: -0.5...0.5)

        current = HiveSnapshot(
            temperatureF: clamp(current.temperatureF + tempDrift, 80...96),
            humidityPct: clamp(current.humidityPct + humDrift, 50...75),
            weightLb: current.weightLb + Double.random(in: -0.05...0.08),
            honeyEstimateLb: current.honeyEstimateLb + Double.random(in: 0...0.004),
            populationEstimate: current.populationEstimate,
            takeoffsLast24h: activity.rollingTakeoffs,
            landingsLast24h: activity.rollingLandings,
            soundLevel: current.soundLevel,
            health: current.health,
            lastReadingAt: Date()
        )
    }

    private func clamp(_ value: Double, _ range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
