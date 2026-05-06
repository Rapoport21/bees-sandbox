import Foundation

struct Shipment: Identifiable, Hashable {
    let id: UUID
    var jarCount: Int
    var status: Status
    var scheduledShipDate: Date
    var lockInDate: Date
    var deliveredAt: Date?
    var trackingNumber: String?
    var carrier: Carrier?
    var design: StickerDesign

    enum Status: String, Hashable {
        case customizing
        case approachingLock
        case locked
        case preparing
        case shipped
        case outForDelivery
        case delivered
        case delayed
        case lost

        var displayName: String {
            switch self {
            case .customizing:     return "Customizing"
            case .approachingLock: return "Locks soon"
            case .locked:          return "Locked"
            case .preparing:       return "Preparing"
            case .shipped:         return "Shipped"
            case .outForDelivery:  return "Out for delivery"
            case .delivered:       return "Delivered"
            case .delayed:         return "Delayed"
            case .lost:            return "Lost"
            }
        }
    }

    enum Carrier: String, Hashable {
        case usps, ups, fedex
        var displayName: String { rawValue.uppercased() }
    }
}
