import Foundation

struct HiveSnapshot: Hashable, Codable {
    var temperatureF: Double
    var humidityPct: Double
    var weightLb: Double
    var honeyEstimateLb: Double
    var populationEstimate: Int
    var takeoffsLast24h: Int
    var landingsLast24h: Int
    var soundLevel: SoundLevel
    var health: Health
    var lastReadingAt: Date

    enum SoundLevel: String, Codable {
        case quiet, calm, active, loud, alarmed
        var displayName: String { rawValue.capitalized }
    }

    enum Health: String, Codable, CaseIterable {
        case thriving, steady, watch, alert, dormant
        var displayName: String { rawValue.uppercased() }
    }
}

struct LiveActivity: Hashable, Codable {
    var takeoffsLast60s: Int
    var landingsLast60s: Int
    var rollingTakeoffs: Int
    var rollingLandings: Int
}
