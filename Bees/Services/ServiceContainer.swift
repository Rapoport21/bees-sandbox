import Foundation
import Observation

@Observable
final class ServiceContainer {
    let hiveService: HiveService
    var currentTier: Tier

    init(hiveService: HiveService, currentTier: Tier) {
        self.hiveService = hiveService
        self.currentTier = currentTier
    }

    static func preview() -> ServiceContainer {
        let mock = MockHiveService(
            hive: Fixtures.demoHive,
            snapshot: Fixtures.demoSnapshot,
            activity: Fixtures.demoActivity
        )
        mock.startSimulating()
        return ServiceContainer(hiveService: mock, currentTier: .forager)
    }
}
