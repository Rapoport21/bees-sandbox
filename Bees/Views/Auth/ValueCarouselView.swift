import SwiftUI

struct ValueCarouselView: View {
    var onAdopt: () -> Void
    var onDemo: () -> Void
    var onSignIn: () -> Void

    @State private var currentPage = 0

    private let cards: [Card] = [
        Card(icon: "video.fill",
             title: "Watch your hive 24/7",
             body: "Live video from your real beehive on a partner farm."),
        Card(icon: "chart.line.uptrend.xyaxis",
             title: "See exactly how it's doing",
             body: "Real-time temperature, humidity, weight, and bee activity."),
        Card(icon: "drop.fill",
             title: "Your honey, your sticker",
             body: "Customize the jar. We print it, fill it, and ship it."),
    ]

    var body: some View {
        VStack(spacing: BeesSpacing.l) {
            HStack {
                Spacer()
                Button("Sign in") { onSignIn() }
                    .buttonStyle(.beesGhost)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.top, BeesSpacing.s)

            TabView(selection: $currentPage) {
                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                    cardView(card)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: BeesSpacing.s) {
                Button("Adopt your hive") { onAdopt() }
                    .buttonStyle(.beesPrimary)
                Button("See a demo first") { onDemo() }
                    .buttonStyle(.beesGhost)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.l)
        }
        .background(
            LinearGradient(colors: [BeesColors.honey100, BeesColors.comb500.opacity(0.5)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .navigationBarHidden(true)
    }

    private func cardView(_ card: Card) -> some View {
        VStack(spacing: BeesSpacing.l) {
            Spacer()
            Image(systemName: card.icon)
                .font(.system(size: 100))
                .foregroundStyle(BeesColors.honey500)
            Text(card.title)
                .font(BeesType.displayL)
                .foregroundStyle(BeesColors.charcoal900)
                .multilineTextAlignment(.center)
            Text(card.body)
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeesSpacing.l)
            Spacer()
        }
        .padding(.horizontal, BeesSpacing.m)
    }

    private struct Card {
        let icon: String
        let title: String
        let body: String
    }
}

#Preview {
    NavigationStack {
        ValueCarouselView(onAdopt: {}, onDemo: {}, onSignIn: {})
    }
}
