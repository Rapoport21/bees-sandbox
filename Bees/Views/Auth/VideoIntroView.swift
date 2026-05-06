import SwiftUI

struct VideoIntroView: View {
    var onAdopt: () -> Void
    var onDemo: () -> Void
    var onSignIn: () -> Void

    @State private var currentPage = 0

    private let pages: [Page] = [
        Page(videoName: "onboarding-bee",
             title: "Watch your hive in real time.",
             subtitle: "Live cameras at a real beehive on a partner farm."),
        Page(videoName: "onboarding-beekeeper",
             title: "Tended by a real beekeeper.",
             subtitle: "We work with people who know what they're doing."),
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            bottomGradient
            content
            topBar
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func pageView(_ page: Page) -> some View {
        if let url = BundledVideo.url(named: page.videoName) {
            LoopingVideoPlayer(url: url)
                .ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [BeesColors.honey300, BeesColors.amber500],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: BeesSpacing.s) {
                    Image(systemName: "video.slash.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Drop \(page.videoName).mp4 in Bees/Videos/")
                        .font(BeesType.captionM)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }

    private var bottomGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.65), .black.opacity(0.92)],
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
                Text(pages[currentPage].title)
                    .font(BeesType.displayL)
                    .foregroundStyle(.white)
                Text(pages[currentPage].subtitle)
                    .font(BeesType.bodyL)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .id(currentPage)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: currentPage)

            HStack(spacing: BeesSpacing.xs) {
                ForEach(pages.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? Color.white : .white.opacity(0.35))
                        .frame(width: i == currentPage ? 18 : 6, height: 6)
                        .animation(.easeOut(duration: 0.2), value: currentPage)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: BeesSpacing.s) {
                Button("Adopt your hive") { onAdopt() }
                    .buttonStyle(.beesPrimary)
                Button("See a demo first") { onDemo() }
                    .font(BeesType.bodyM.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BeesSpacing.s)
            }
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.bottom, BeesSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var topBar: some View {
        VStack {
            HStack {
                Spacer()
                Button("Sign in") { onSignIn() }
                    .font(BeesType.bodyM.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .padding(.horizontal, BeesSpacing.s)
                    .padding(.vertical, BeesSpacing.xxs)
                    .background(.black.opacity(0.3), in: Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.top, BeesSpacing.l)
    }

    private struct Page {
        let videoName: String
        let title: String
        let subtitle: String
    }
}

#Preview {
    VideoIntroView(onAdopt: {}, onDemo: {}, onSignIn: {})
}
