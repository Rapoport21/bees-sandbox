import Foundation

enum Tier: String, CaseIterable, Hashable, Codable {
    case pollinator
    case forager
    case queenKeeper

    var displayName: String {
        switch self {
        case .pollinator:  return "Pollinator"
        case .forager:     return "Forager"
        case .queenKeeper: return "Queen Keeper"
        }
    }

    var monthlyPrice: Decimal {
        switch self {
        case .pollinator:  return 14.99
        case .forager:     return 24.99
        case .queenKeeper: return 49.99
        }
    }

    var canCustomizeText: Bool { self != .pollinator }
    var canPickFont: Bool { self != .pollinator }
    var canPickColor: Bool { self != .pollinator }
    var canSaveFavorites: Bool { self != .pollinator }
    var canRecordClips: Bool { self != .pollinator }
    var canSwitchCameras: Bool { self != .pollinator }
    var canSendGifts: Bool { self != .pollinator }
    var canSendSubscriptionGifts: Bool { self == .queenKeeper }
}
