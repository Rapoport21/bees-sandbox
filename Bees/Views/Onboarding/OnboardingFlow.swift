import SwiftUI

enum OnboardingStep: Hashable {
    case tierComparison
    case tutorial
    case reveal
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
                onContinue: { path.append(.tutorial) }
            )
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .tierComparison:
                    EmptyView()
                case .tutorial:
                    TutorialFlow(
                        variant: services.onboardingVariant,
                        onComplete: { path.append(.reveal) }
                    )
                case .reveal:
                    HiveRevealView(hiveName: $hiveName) {
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
