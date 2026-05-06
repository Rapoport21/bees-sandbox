import Foundation

enum StatType: String, CaseIterable, Hashable {
    case temperature, humidity, weight, population, takeoffs, landings, sound

    var displayName: String {
        switch self {
        case .temperature: return "Temperature"
        case .humidity:    return "Humidity"
        case .weight:      return "Weight"
        case .population:  return "Population"
        case .takeoffs:    return "Take-offs"
        case .landings:    return "Landings"
        case .sound:       return "Sound activity"
        }
    }

    var unit: String {
        switch self {
        case .temperature: return "°F"
        case .humidity:    return "%"
        case .weight:      return "lb"
        case .population:  return "bees"
        case .takeoffs, .landings: return "/24h"
        case .sound:       return ""
        }
    }

    var iconName: String {
        switch self {
        case .temperature: return "thermometer"
        case .humidity:    return "humidity"
        case .weight:      return "scalemass"
        case .population:  return "ant"
        case .takeoffs:    return "arrow.up.forward"
        case .landings:    return "arrow.down.left"
        case .sound:       return "waveform"
        }
    }

    var explanation: String {
        switch self {
        case .temperature:
            return "Bees regulate hive temperature with remarkable precision. A consistent reading of 90–95°F means a healthy colony. Big swings can mean ventilation issues or a problem with the queen."
        case .humidity:
            return "Healthy hives stay between 50% and 70% humidity. Too dry and larvae struggle. Too wet and mold becomes a risk."
        case .weight:
            return "Hive weight tracks honey production over time. Big drops are usually harvests — we label these on your chart. Slow gains in summer are normal."
        case .population:
            return "We estimate population from sensor readings — actual count varies. A typical hive runs 30,000–80,000 bees depending on season."
        case .takeoffs:
            return "Daily take-offs reflect how active the colony is. High numbers on warm days are a great sign."
        case .landings:
            return "Landings should track close to take-offs over time. Persistent imbalance can hint at trouble."
        case .sound:
            return "Sound tells us a lot about hive mood. Loud doesn't mean angry — could be excited foraging. Sudden silence is the one to watch."
        }
    }
}

enum TimeRange: String, CaseIterable, Hashable, Identifiable {
    case hour, day, week, month, season, lifetime

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .hour:     return "1h"
        case .day:      return "24h"
        case .week:     return "7d"
        case .month:    return "30d"
        case .season:   return "Season"
        case .lifetime: return "Lifetime"
        }
    }
}

struct StatChartPoint: Identifiable, Hashable {
    var id: Date { date }
    let date: Date
    let value: Double
}
