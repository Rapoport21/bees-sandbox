import SwiftUI

struct TutorialFlow: View {
    let variant: OnboardingVariant
    var onComplete: () -> Void

    @State private var currentPage = 0

    private var items: [TutorialItem] { TutorialItem.sequence(for: variant) }

    var body: some View {
        ZStack {
            backgroundLayer
            if isCurrentVideo {
                bottomGradient
            }
            content
            topBar
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
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

    private var backgroundLayer: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if index == currentPage {
                    pageBackground(for: item)
                        .id(itemKey(item))
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }

    @ViewBuilder
    private func pageBackground(for item: TutorialItem) -> some View {
        switch item {
        case .video(let name, _, _):
            videoView(name: name)
        case .card:
            BeesColors.honey100.opacity(0.4)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private func videoView(name: String) -> some View {
        if let url = BundledVideo.url(named: name) {
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
                    Text("Drop \(name).mp4 in Bees/Videos/")
                        .font(BeesType.captionM)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
    }

    private var bottomGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.55), .black.opacity(0.92)],
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
                if case .card(let icon, _, _) = currentItem {
                    Image(systemName: icon)
                        .font(.system(size: 56))
                        .foregroundStyle(BeesColors.honey500)
                        .padding(.bottom, BeesSpacing.s)
                }

                Text(currentTitle)
                    .font(BeesType.displayL)
                    .foregroundStyle(textPrimary)

                Text(currentBody)
                    .font(BeesType.bodyL)
                    .foregroundStyle(textSecondary)
            }
            .id(currentPage)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: currentPage)

            Button(currentPage == items.count - 1 ? "Got it" : "Next") {
                advance()
            }
            .buttonStyle(.beesPrimary)
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.bottom, BeesSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            SegmentedProgressBar(
                total: items.count,
                current: currentPage,
                color: progressColor,
                trackOpacity: isCurrentVideo ? 0.3 : 0.25
            )
            Spacer()
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.top, BeesSpacing.l)
    }

    // MARK: - Helpers

    private var currentItem: TutorialItem { items[currentPage] }

    private var isCurrentVideo: Bool {
        if case .video = currentItem { return true }
        return false
    }

    private var currentTitle: String {
        switch currentItem {
        case .card(_, let title, _),
             .video(_, let title, _):
            return title
        }
    }

    private var currentBody: String {
        switch currentItem {
        case .card(_, _, let body): return body
        case .video(_, _, let subtitle): return subtitle
        }
    }

    private var textPrimary: Color {
        isCurrentVideo ? .white : BeesColors.charcoal900
    }

    private var textSecondary: Color {
        isCurrentVideo ? .white.opacity(0.85) : BeesColors.charcoal600
    }

    private var progressColor: Color {
        isCurrentVideo ? .white : BeesColors.honey500
    }

    private func itemKey(_ item: TutorialItem) -> String {
        switch item {
        case .card(_, let title, _): return "card_\(title)"
        case .video(let name, _, _): return "video_\(name)"
        }
    }

    private func advance() {
        if currentPage < items.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            onComplete()
        }
    }

    private func retreat() {
        guard currentPage > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage -= 1
        }
    }
}

#Preview("Variant A — videos") {
    TutorialFlow(variant: .carouselFirst, onComplete: {})
}

#Preview("Variant B — cards") {
    TutorialFlow(variant: .videosFirst, onComplete: {})
}
