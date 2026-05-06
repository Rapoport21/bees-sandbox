import Foundation
import Observation

protocol ShipmentService: AnyObject {
    var activeShipment: Shipment? { get }
    var history: [Shipment] { get }

    func updateActiveDesign(_ design: StickerDesign)
    func lockActiveDesign()
    func advanceStateForDemo()
}

@Observable
final class MockShipmentService: ShipmentService {
    private(set) var activeShipment: Shipment?
    private(set) var history: [Shipment]

    init(active: Shipment, history: [Shipment]) {
        self.activeShipment = active
        self.history = history
    }

    func updateActiveDesign(_ design: StickerDesign) {
        guard var shipment = activeShipment else { return }
        guard shipment.status == .customizing || shipment.status == .approachingLock else { return }
        shipment.design = design
        activeShipment = shipment
    }

    func lockActiveDesign() {
        guard var shipment = activeShipment else { return }
        shipment.status = .locked
        activeShipment = shipment
    }

    func advanceStateForDemo() {
        guard var shipment = activeShipment else { return }
        let next: Shipment.Status
        switch shipment.status {
        case .customizing:     next = .approachingLock
        case .approachingLock: next = .locked
        case .locked:          next = .preparing
        case .preparing:       next = .shipped
        case .shipped:         next = .outForDelivery
        case .outForDelivery:  next = .delivered
        case .delivered:       next = .customizing
        case .delayed, .lost:  next = .preparing
        }
        shipment.status = next
        if next == .delivered { shipment.deliveredAt = Date() }
        activeShipment = shipment
    }
}
