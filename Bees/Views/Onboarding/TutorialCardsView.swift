import SwiftUI

enum TutorialItem {
    case card(icon: String, title: String, body: String)
    case video(name: String, title: String, subtitle: String)

    static let sequence: [TutorialItem] = [
        .card(
            icon: "hexagon.fill",
            title: "What is a hive?",
            body: "Your hive is a real beehive on a partner farm. Thousands of bees, a queen, and honey through the year — all yours to watch and care about."
        ),
        .video(
            name: "onboarding-bee",
            title: "Watch in real time.",
            subtitle: "Live cameras at your hive, day and night."
        ),
        .video(
            name: "onboarding-beekeeper",
            title: "Tended by a real beekeeper.",
            subtitle: "Your hive sits on a small partner farm. We work with people who know what they're doing."
        ),
        .card(
            icon: "drop.fill",
            title: "Honey & stickers",
            body: "Every shipment, you customize a sticker for your jar. We print it, fill it, and ship it to your door."
        ),
    ]
}

struct TutorialCardsView: View {
    let index: Int
    let total: Int
    var onNext: () -> Void
    var onSkip: () -> Void

    var card: (icon: String, title: String, body: String)?

    var body: some View {
        VStack(spacing: BeesSpacing.l) {
            HStack {
                Spacer()
                Button("Skip") { onSkip() }
                    .buttonStyle(.beesGhost)
            }

            Spacer()

            if let card {
                Image(systemName: card.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(BeesColors.honey500)
                    .padding(.bottom, BeesSpacing.l)

                Text(card.title)
                    .font(BeesType.displayL)
                    .foregroundStyle(BeesColors.charcoal900)
                    .multilineTextAlignment(.center)

                Text(card.body)
                    .font(BeesType.bodyL)
                    .foregroundStyle(BeesColors.charcoal600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BeesSpacing.l)
            }

            Spacer()

            HStack(spacing: BeesSpacing.xs) {
                ForEach(0..<total, id: \.self) { i in
                    Capsule()
                        .fill(i == index ? BeesColors.honey500 : BeesColors.charcoal300)
                        .frame(width: i == index ? 18 : 6, height: 6)
                }
            }
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.vertical, BeesSpacing.l)
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Button(index < total - 1 ? "Next" : "Got it") { onNext() }
                .buttonStyle(.beesPrimary)
                .padding(.horizontal, BeesSpacing.m)
                .padding(.vertical, BeesSpacing.s)
                .background(.regularMaterial)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        TutorialCardsView(
            index: 0,
            total: 4,
            onNext: {},
            onSkip: {},
            card: ("hexagon.fill", "What is a hive?", "Your hive is a real beehive on a partner farm.")
        )
    }
}
