import Foundation
import Observation

@Observable
final class ServiceContainer {
    let hiveService: HiveService
    let shipmentService: ShipmentService
    let stickerService: StickerService
    var currentTier: Tier
    var hasCompletedOnboarding: Bool

    init(
        hiveService: HiveService,
        shipmentService: ShipmentService,
        stickerService: StickerService,
        currentTier: Tier,
        hasCompletedOnboarding: Bool
    ) {
        self.hiveService = hiveService
        self.shipmentService = shipmentService
        self.stickerService = stickerService
        self.currentTier = currentTier
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    func completeOnboarding(tier: Tier, hiveName: String) {
        currentTier = tier
        if let mock = hiveService as? MockHiveService, !hiveName.isEmpty {
            mock.rename(hiveName)
        }
        hasCompletedOnboarding = true
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }

    static func preview() -> ServiceContainer {
        let hive = MockHiveService(
            hive: Fixtures.demoHive,
            snapshot: Fixtures.demoSnapshot,
            activity: Fixtures.demoActivity
        )
        hive.startSimulating()

        return ServiceContainer(
            hiveService: hive,
            shipmentService: MockShipmentService(active: Fixtures.demoActiveShipment, history: Fixtures.demoHistory),
            stickerService: MockStickerService(savedStickers: Fixtures.demoSavedStickers, maxSaved: 5),
            currentTier: .forager,
            hasCompletedOnboarding: true
        )
    }

    static func freshLaunch() -> ServiceContainer {
        let hive = MockHiveService(
            hive: Fixtures.demoHive,
            snapshot: Fixtures.demoSnapshot,
            activity: Fixtures.demoActivity
        )
        hive.startSimulating()

        return ServiceContainer(
            hiveService: hive,
            shipmentService: MockShipmentService(active: Fixtures.demoActiveShipment, history: Fixtures.demoHistory),
            stickerService: MockStickerService(savedStickers: Fixtures.demoSavedStickers, maxSaved: 5),
            currentTier: .forager,
            hasCompletedOnboarding: false
        )
    }
}
