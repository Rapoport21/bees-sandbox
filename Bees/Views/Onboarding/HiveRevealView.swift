import SwiftUI

struct HiveRevealView: View {
    var onContinue: () -> Void
    @State private var phase: Phase = .hush
    @State private var isMorphing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Phase: Int, Comparable {
        case hush, beesEnter, swarmCoalesce, hiveCrystallize, nameReveal, ctaAppear
        static func < (lhs: Phase, rhs: Phase) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [BeesColors.surfaceWarmHighlight, BeesColors.surfaceMuted.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if !reduceMotion && phase >= .beesEnter && phase < .hiveCrystallize && !isMorphing {
                    BeeSwarmAnimation()
                        .accessibilityHidden(true)
                        .transition(.opacity)
                }

                if phase >= .hiveCrystallize {
                    hiveVideo
                        .frame(
                            width: videoWidth(in: geo),
                            height: videoHeight
                        )
                        .position(
                            x: geo.size.width / 2,
                            y: videoCenterY(in: geo)
                        )
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                }

                if !isMorphing {
                    VStack {
                        Spacer().frame(
                            height: max(0, videoCenterY(in: geo) + videoHeight / 2 + BeesSpacing.l)
                        )

                        if phase >= .nameReveal {
                            VStack(spacing: BeesSpacing.s) {
                                Text("Meet your hive.")
                                    .font(BeesType.displayXL)
                                    .foregroundStyle(BeesColors.charcoal900)
                                Text("Hive #47 at Sunny Acre Farm")
                                    .font(BeesType.headingM)
                                    .foregroundStyle(BeesColors.charcoal900)
                                Text("Sonoma County, California")
                                    .font(BeesType.bodyM)
                                    .foregroundStyle(BeesColors.charcoal600)
                            }
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        Spacer()

                        if phase >= .ctaAppear {
                            Button("Continue") { triggerMorph() }
                                .buttonStyle(.beesPrimary)
                                .padding(.horizontal, BeesSpacing.l)
                                .padding(.bottom, BeesSpacing.l)
                                .transition(.opacity)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, BeesSpacing.m)
                    .transition(.opacity)
                }

                if !isMorphing && phase >= .beesEnter && phase < .ctaAppear {
                    VStack {
                        HStack {
                            Spacer()
                            Button("Skip") { skip() }
                                .buttonStyle(.beesGhost)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, BeesSpacing.m)
                    .transition(.opacity)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Welcome to your hive. Hive number 47, at Sunny Acre Farm, Sonoma County, California. Continue button.")
        .task { await runSequence() }
    }

    // MARK: - Hive video

    @ViewBuilder
    private var hiveVideo: some View {
        ZStack {
            if !isMorphing {
                Circle()
                    .fill(RadialGradient(
                        colors: [BeesColors.honey300.opacity(0.55), .clear],
                        center: .center, startRadius: 20, endRadius: 220))
                    .scaleEffect(1.6)
                    .blur(radius: 24)
                    .transition(.opacity)
            }

            videoContent
                .mask(
                    ZStack {
                        HexagonShape()
                            .opacity(isMorphing ? 0 : 1)
                        RoundedRectangle(cornerRadius: BeesRadius.lg)
                            .opacity(isMorphing ? 1 : 0)
                    }
                )
                .overlay(
                    HexagonShape()
                        .stroke(.white.opacity(0.5), lineWidth: 3)
                        .opacity(isMorphing ? 0 : 1)
                )
                .shadow(color: BeesColors.honey500.opacity(isMorphing ? 0 : 0.45),
                        radius: 22, x: 0, y: 10)
        }
    }

    @ViewBuilder
    private var videoContent: some View {
        if let url = BundledVideo.url(named: "hive-entrance") {
            LoopingVideoPlayer(url: url)
        } else {
            LinearGradient(
                colors: [BeesColors.honey500, BeesColors.amber500],
                startPoint: .top, endPoint: .bottom
            )
        }
    }

    // MARK: - Layout

    private var videoHeight: CGFloat { isMorphing ? 220 : 280 }

    private func videoWidth(in geo: GeometryProxy) -> CGFloat {
        isMorphing ? max(0, geo.size.width - BeesSpacing.m * 2) : 260
    }

    private func videoCenterY(in geo: GeometryProxy) -> CGFloat {
        if isMorphing {
            return geo.safeAreaInsets.top + videoHeight / 2 + BeesSpacing.l
        } else {
            return geo.size.height * 0.40
        }
    }

    // MARK: - Sequence

    private func runSequence() async {
        if reduceMotion {
            await advance(to: .hiveCrystallize, duration: 0.3)
            await advance(to: .nameReveal, duration: 0.3)
            await advance(to: .ctaAppear, duration: 0.3)
            return
        }
        await advance(to: .beesEnter, after: 0.4, duration: 0.6)
        await advance(to: .swarmCoalesce, after: 1.2, duration: 0.5)
        await advance(to: .hiveCrystallize, after: 1.0, duration: 0.6)
        await advance(to: .nameReveal, after: 0.4, duration: 0.5)
        await advance(to: .ctaAppear, after: 0.6, duration: 0.4)
    }

    private func advance(to next: Phase, after delay: TimeInterval = 0, duration: TimeInterval) async {
        if delay > 0 { try? await Task.sleep(for: .seconds(delay)) }
        await MainActor.run {
            withAnimation(.easeInOut(duration: duration)) { phase = next }
        }
    }

    private func skip() {
        withAnimation(.easeInOut(duration: 0.3)) { phase = .ctaAppear }
    }

    private func triggerMorph() {
        withAnimation(.spring(response: 0.75, dampingFraction: 0.85)) {
            isMorphing = true
        }
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            await MainActor.run { onContinue() }
        }
    }
}

private struct BeeSwarmAnimation: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { index in
                BeeGlyph()
                    .offset(
                        x: animate ? 0 : startOffset(for: index).x,
                        y: animate ? 0 : startOffset(for: index).y
                    )
                    .opacity(animate ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 1.6).delay(Double(index) * 0.1),
                        value: animate
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { animate = true }
    }

    private func startOffset(for index: Int) -> CGPoint {
        let angle = Double(index) * (2 * .pi / 10)
        let radius: CGFloat = 220
        return CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
    }
}

private struct BeeGlyph: View {
    var body: some View {
        Image(systemName: "ant.fill")
            .font(.system(size: 18))
            .foregroundStyle(BeesColors.charcoal900.opacity(0.6))
            .rotationEffect(.degrees(-20))
    }
}

#Preview {
    NavigationStack {
        HiveRevealView { }
    }
}
