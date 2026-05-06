import SwiftUI

struct TutorialCardsView: View {
    let index: Int
    let total: Int
    var onNext: () -> Void
    var onSkip: () -> Void

    var body: some View {
        VStack(spacing: BeesSpacing.l) {
            HStack {
                Spacer()
                Button("Skip") { onSkip() }
                    .buttonStyle(.beesGhost)
            }

            Spacer()

            Image(systemName: cards[index].icon)
                .font(.system(size: 80))
                .foregroundStyle(BeesColors.honey500)
                .padding(.bottom, BeesSpacing.l)

            Text(cards[index].title)
                .font(BeesType.displayL)
                .foregroundStyle(BeesColors.charcoal900)
                .multilineTextAlignment(.center)

            Text(cards[index].body)
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeesSpacing.l)

            Spacer()

            HStack(spacing: BeesSpacing.xs) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i == index ? BeesColors.honey500 : BeesColors.charcoal300)
                        .frame(width: 8, height: 8)
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

    private var cards: [(icon: String, title: String, body: String)] {
        [
            (icon: "hexagon.fill",
             title: "What is a hive?",
             body: "Your hive is a real beehive on a partner farm. It has thousands of bees, a queen, and produces honey through the year."),
            (icon: "video.fill",
             title: "How the cameras work",
             body: "We stream live video from cameras at the entrance, inside, and on top of your hive. Watch anytime, day or night."),
            (icon: "chart.line.uptrend.xyaxis",
             title: "What the stats mean",
             body: "Temperature, humidity, weight, and bee activity all tell us how your hive is doing. We turn that into a simple health rating."),
            (icon: "drop.fill",
             title: "Honey & stickers",
             body: "Every shipment, you customize a sticker for your jar. We print, pack, and ship to your door."),
        ]
    }
}

#Preview {
    NavigationStack {
        TutorialCardsView(index: 0, total: 4, onNext: {}, onSkip: {})
    }
}
