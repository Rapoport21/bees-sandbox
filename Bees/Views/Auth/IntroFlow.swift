import SwiftUI

struct IntroFlow: View {
    var onAdopt: () -> Void
    var onDemo: () -> Void
    var onSignIn: () -> Void

    @State private var currentPage = 0

    private let pages: [Page] = [
        Page(
            videoName: "onboarding-bee",
            title: "Watch your hive 24/7",
            subtitle: "Live cameras at a real beehive on a partner farm."
        ),
        Page(
            videoName: "hive-child-in-frame",
            title: "See exactly how it's doing",
            subtitle: "Real-time temperature, humidity, weight, and bee activity."
        ),
        Page(
            videoName: "jar-honey-pour",
            title: "Your honey, your jar.",
            subtitle: "Custom-stickered jars shipped to your door."
        ),
    ]

    var body: some View {
        ZStack {
            videoLayer
            bottomGradient
            content
            topBar
        }
        .navigationBarHidden(true)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        advance()
                    } else if value.translation.width > threshold {
                        retreat()
                    }
                }
        )
    }

    private var videoLayer: some View {
        ZStack {
            ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                if index == currentPage {
                    pageVideo(for: page)
                        .id(page.videoName)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }

    @ViewBuilder
    private func pageVideo(for page: Page) -> some View {
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
            colors: [.clear, .black.opacity(0.6), .black.opacity(0.92)],
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
                    .multilineTextAlignment(.leading)
                Text(pages[currentPage].subtitle)
                    .font(BeesType.bodyL)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
            }
            .id(currentPage)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: currentPage)

            Button(currentPage == pages.count - 1 ? "Adopt your hive" : "Next") {
                advance()
            }
            .buttonStyle(.beesPrimary)

            Button("See a demo first") { onDemo() }
                .font(BeesType.bodyM.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, BeesSpacing.xs)
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.bottom, BeesSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: BeesSpacing.s) {
                SegmentedProgressBar(total: pages.count, current: currentPage)
                    .frame(maxWidth: .infinity)

                Button("Sign in") { onSignIn() }
                    .font(BeesType.captionM.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, BeesSpacing.s)
                    .padding(.vertical, BeesSpacing.xxs)
                    .background(.black.opacity(0.3), in: Capsule())
            }
            .padding(.top, BeesSpacing.s)
            Spacer()
        }
        .padding(.horizontal, BeesSpacing.m)
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            onAdopt()
        }
    }

    private func retreat() {
        guard currentPage > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage -= 1
        }
    }

    private struct Page {
        let videoName: String
        let title: String
        let subtitle: String
    }
}

#Preview {
    IntroFlow(onAdopt: {}, onDemo: {}, onSignIn: {})
}
