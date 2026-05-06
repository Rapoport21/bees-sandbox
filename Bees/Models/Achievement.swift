import Foundation

struct Achievement: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let criteria: String
    let icon: String
    let rarity: Rarity
    let earnedAt: Date?

    var isEarned: Bool { earnedAt != nil }

    enum Rarity: String, Hashable {
        case common, rare, epic, legendary
        var displayName: String { rawValue.capitalized }
    }
}

struct BillingRecord: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let amount: Decimal
    let tier: Tier
    let status: Status

    enum Status: String, Hashable {
        case paid, refunded, failed, pending
        var displayName: String { rawValue.capitalized }
    }
}
