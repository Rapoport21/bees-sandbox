import SwiftUI

struct OnboardingVideoView: View {
    let videoName: String
    let title: String
    let subtitle: String
    let pageIndex: Int
    let totalPages: Int
    var onNext: () -> Void
    var onSkip: () -> Void

    var body: some View {
        ZStack {
            videoLayer
            bottomGradient
            content
            topBar
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private var videoLayer: some View {
        if let url = BundledVideo.url(named: videoName) {
            LoopingVideoPlayer(url: url)
                .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [BeesColors.honey300, BeesColors.amber500],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                VStack(spacing: BeesSpacing.s) {
                    Image(systemName: "video.slash.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Drop \(videoName).mp4 in Bees/Videos/")
                        .font(BeesType.captionM)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .ignoresSafeArea()
        }
    }

    private var bottomGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.55), .black.opacity(0.85)],
            startPoint: .center,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .frame(maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.m) {
            Spacer()

            VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                Text(title)
                    .font(BeesType.displayL)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(BeesType.bodyL)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
            }

            Button("Continue") { onNext() }
                .buttonStyle(.beesPrimary)

            HStack(spacing: BeesSpacing.xs) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Capsule()
                        .fill(i == pageIndex ? Color.white : .white.opacity(0.35))
                        .frame(width: i == pageIndex ? 18 : 6, height: 6)
                        .animation(.easeOut(duration: 0.2), value: pageIndex)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.bottom, BeesSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var topBar: some View {
        VStack {
            HStack {
                Spacer()
                Button("Skip") { onSkip() }
                    .font(BeesType.bodyM.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, BeesSpacing.s)
                    .padding(.vertical, BeesSpacing.xxs)
                    .background(.black.opacity(0.25), in: Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.top, BeesSpacing.l)
    }
}

#Preview {
    OnboardingVideoView(
        videoName: "onboarding-bee",
        title: "Watch your hive in real time.",
        subtitle: "Bees foraging, returning, building — every day, all day.",
        pageIndex: 1,
        totalPages: 4,
        onNext: {},
        onSkip: {}
    )
}
