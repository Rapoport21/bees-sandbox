import Foundation
import SwiftUI
import Observation

enum OnboardingVariant: String, CaseIterable, Hashable, Identifiable {
    case carouselFirst
    case videosFirst

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .carouselFirst: return "A · Carousel first"
        case .videosFirst:   return "B · Videos first"
        }
    }
}

enum AppTheme: String, CaseIterable, Hashable, Identifiable {
    case system, light, dark

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

enum TemperatureUnit: String, CaseIterable, Hashable, Identifiable {
    case auto, fahrenheit, celsius

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .auto:       return "Auto"
        case .fahrenheit: return "°F"
        case .celsius:    return "°C"
        }
    }
}

enum WeightUnit: String, CaseIterable, Hashable, Identifiable {
    case auto, lb, kg

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum VideoQuality: String, CaseIterable, Hashable, Identifiable {
    case auto, sd, hd

    var id: String { rawValue }
    var displayName: String { self == .auto ? "Auto" : rawValue.uppercased() }
}

@Observable
final class ServiceContainer {
    let authService: AuthService
    let hiveService: HiveService
    let shipmentService: ShipmentService
    let stickerService: StickerService
    let achievementService: AchievementService
    let subscriptionService: SubscriptionService

    var currentTier: Tier
    var hasCompletedOnboarding: Bool
    var billingHistory: [BillingRecord]
    var subscriptionStatus: SubscriptionStatus
    var trialEndsAt: Date?
    var onboardingVariant: OnboardingVariant = .carouselFirst

    // Display preferences
    var theme: AppTheme = .system
    var temperatureUnit: TemperatureUnit = .auto
    var weightUnit: WeightUnit = .auto

    // Hive preferences
    var hiveComparisonEnabled: Bool = false
    var showHiveMap: Bool = false
    var multiHiveEnabled: Bool = false
    var defaultAudioOn: Bool = false
    var defaultVideoQuality: VideoQuality = .auto
    var liveActivityEnabled: Bool = false

    enum SubscriptionStatus: Hashable {
        case trial, active, paused, pastDue, canceled
        var displayName: String {
            switch self {
            case .trial:    return "Free trial"
            case .active:   return "Active"
            case .paused:   return "Paused"
            case .pastDue:  return "Past due"
            case .canceled: return "Canceled"
            }
        }
    }

    init(
        authService: AuthService,
        hiveService: HiveService,
        shipmentService: ShipmentService,
        stickerService: StickerService,
        achievementService: AchievementService,
        subscriptionService: SubscriptionService,
        currentTier: Tier,
        hasCompletedOnboarding: Bool,
        billingHistory: [BillingRecord],
        subscriptionStatus: SubscriptionStatus,
        trialEndsAt: Date? = nil
    ) {
        self.authService = authService
        self.hiveService = hiveService
        self.shipmentService = shipmentService
        self.stickerService = stickerService
        self.achievementService = achievementService
        self.subscriptionService = subscriptionService
        self.currentTier = currentTier
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.billingHistory = billingHistory
        self.subscriptionStatus = subscriptionStatus
        self.trialEndsAt = trialEndsAt
    }

    func completeOnboarding(tier: Tier, hiveName: String) {
        currentTier = tier
        if let mock = hiveService as? MockHiveService, !hiveName.isEmpty {
            mock.rename(hiveName)
        }
        hasCompletedOnboarding = true
        subscriptionStatus = .trial
        trialEndsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }

    func cancelSubscription() {
        subscriptionStatus = .canceled
    }

    func reactivateSubscription() {
        subscriptionStatus = .active
    }

    func switchTier(_ newTier: Tier) {
        currentTier = newTier
    }

    static func preview() -> ServiceContainer {
        build(authenticated: true, completedOnboarding: true)
    }

    static func freshLaunch() -> ServiceContainer {
        build(authenticated: false, completedOnboarding: false)
    }

    private static func build(authenticated: Bool, completedOnboarding: Bool) -> ServiceContainer {
        let hive = MockHiveService(
            hive: Fixtures.demoHive,
            snapshot: Fixtures.demoSnapshot,
            activity: Fixtures.demoActivity
        )
        hive.startSimulating()

        return ServiceContainer(
            authService: MockAuthService(
                isAuthenticated: authenticated,
                displayName: "Nick",
                email: authenticated ? "nick@example.com" : nil,
                provider: authenticated ? .apple : nil
            ),
            hiveService: hive,
            shipmentService: MockShipmentService(active: Fixtures.demoActiveShipment, history: Fixtures.demoHistory),
            stickerService: MockStickerService(savedStickers: Fixtures.demoSavedStickers, maxSaved: 5),
            achievementService: MockAchievementService(all: Fixtures.demoAchievements),
            subscriptionService: SubscriptionService(),
            currentTier: .forager,
            hasCompletedOnboarding: completedOnboarding,
            billingHistory: Fixtures.demoBilling,
            subscriptionStatus: completedOnboarding ? .active : .trial
        )
    }
}
