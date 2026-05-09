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

    /// Matches the productID values declared in `Bees.storekit`. Updating
    /// these IDs requires updating the StoreKit configuration file too —
    /// product IDs are the join key between the app and the store.
    var productID: String {
        switch self {
        case .pollinator:  return "com.rapoportn21.bees.pollinator.monthly"
        case .forager:     return "com.rapoportn21.bees.forager.monthly"
        case .queenKeeper: return "com.rapoportn21.bees.queenkeeper.monthly"
        }
    }

    static func from(productID: String) -> Tier? {
        Tier.allCases.first { $0.productID == productID }
    }
}
