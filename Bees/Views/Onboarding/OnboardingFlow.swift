import SwiftUI

enum OnboardingStep: Hashable {
    case tierComparison
    case tutorial(Int)
    case reveal
    case naming
    case welcome
}

struct OnboardingFlow: View {
    @Environment(ServiceContainer.self) private var services
    @State private var path: [OnboardingStep] = []
    @State private var pickedTier: Tier = .forager
    @State private var hiveName: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            TierComparisonView(
                pickedTier: $pickedTier,
                onContinue: { path.append(.tutorial(0)) }
            )
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .tierComparison:
                    EmptyView()
                case .tutorial(let index):
                    TutorialCardsView(index: index, total: 4) {
                        if index < 3 {
                            path.append(.tutorial(index + 1))
                        } else {
                            path.append(.reveal)
                        }
                    } onSkip: {
                        path.append(.reveal)
                    }
                case .reveal:
                    HiveRevealView { path.append(.naming) }
                case .naming:
                    HiveNamingView(hiveName: $hiveName) {
                        path.append(.welcome)
                    }
                case .welcome:
                    WelcomeView(hiveName: hiveName, tier: pickedTier) {
                        services.completeOnboarding(tier: pickedTier, hiveName: hiveName)
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingFlow()
        .environment(ServiceContainer.preview())
}
