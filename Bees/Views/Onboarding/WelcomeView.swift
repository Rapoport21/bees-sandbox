import SwiftUI

struct WelcomeView: View {
    let hiveName: String
    let tier: Tier
    var onComplete: () -> Void
    @State private var confetti = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [BeesColors.honey100, BeesColors.comb500.opacity(0.5)],
                startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: BeesSpacing.l) {
                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 64))
                    .foregroundStyle(BeesColors.honey500)
                    .symbolEffect(.bounce, value: confetti)

                VStack(spacing: BeesSpacing.s) {
                    Text("Welcome to Bees!")
                        .font(BeesType.displayXL)
                        .foregroundStyle(BeesColors.charcoal900)

                    Text("\(hiveName) is ready at Sunny Acre Farm.")
                        .font(BeesType.bodyL)
                        .foregroundStyle(BeesColors.charcoal600)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    bullet("Watch your hive live")
                    bullet("Customize your first sticker anytime")
                    bullet("Free trial ends in 7 days — we'll remind you")
                    bullet("First jar ships in ~6 weeks")
                }
                .padding(BeesSpacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))

                Spacer()

                Button("See my hive") { onComplete() }
                    .buttonStyle(.beesPrimary)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.l)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { confetti = true }
    }

    private func bullet(_ text: String) -> some View {
        HStack(spacing: BeesSpacing.s) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BeesColors.honey500)
            Text(text)
                .font(BeesType.bodyM)
                .foregroundStyle(BeesColors.charcoal900)
        }
    }
}

#Preview {
    WelcomeView(hiveName: "Buzzy McHive", tier: .forager, onComplete: {})
}
