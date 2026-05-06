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

    private var sequence: [TutorialItem] { TutorialItem.sequence(for: services.onboardingVariant) }
    private var totalTutorialItems: Int { sequence.count }

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
                    tutorialView(at: index)
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

    @ViewBuilder
    private func tutorialView(at index: Int) -> some View {
        let total = totalTutorialItems
        let item = sequence[index]
        let goNext: () -> Void = {
            if index < total - 1 {
                path.append(.tutorial(index + 1))
            } else {
                path.append(.reveal)
            }
        }
        let skipAll: () -> Void = { path.append(.reveal) }

        switch item {
        case .card(let icon, let title, let body):
            TutorialCardsView(
                index: index,
                total: total,
                onNext: goNext,
                onSkip: skipAll,
                card: (icon, title, body)
            )
        case .video(let name, let title, let subtitle):
            OnboardingVideoView(
                videoName: name,
                title: title,
                subtitle: subtitle,
                pageIndex: index,
                totalPages: total,
                onNext: goNext,
                onSkip: skipAll
            )
        }
    }
}

#Preview {
    OnboardingFlow()
        .environment(ServiceContainer.preview())
}
