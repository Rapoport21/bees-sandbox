import Foundation
import Observation

protocol AchievementService: AnyObject {
    var all: [Achievement] { get }
    var earned: [Achievement] { get }
    var locked: [Achievement] { get }
}

@Observable
final class MockAchievementService: AchievementService {
    private(set) var all: [Achievement]

    var earned: [Achievement] { all.filter { $0.isEarned } }
    var locked: [Achievement] { all.filter { !$0.isEarned } }

    init(all: [Achievement]) {
        self.all = all
    }
}
