import SwiftUI

struct HiveRevealView: View {
    @Binding var hiveName: String
    var onContinue: () -> Void

    @State private var phase: Phase = .hush
    @State private var isMorphing = false
    @FocusState private var nameFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Phase: Int, Comparable {
        case hush, beesEnter, swarmCoalesce, hiveCrystallize, nameReveal, ctaAppear
        static func < (lhs: Phase, rhs: Phase) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    private let nameLimit = 24
    private let suggestions = ["Buzzy McHive", "Honeycomb HQ", "The Hive Mind", "Bee Yoncé"]

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                background

                if !reduceMotion && phase >= .beesEnter && phase < .hiveCrystallize && !isMorphing {
                    BeeSwarmAnimation()
                        .accessibilityHidden(true)
                        .transition(.opacity)
                }

                // Video — only this stays visible through the morph.
                // It morphs from circle to rounded rect at the same Y
                // and width as HiveTabView's video, then disappears
                // when the overlay unmounts. Because both views render
                // SharedHiveVideoPlayer (same AVQueuePlayer), the
                // hand-off is invisible.
                VStack(spacing: 0) {
                    Spacer().frame(height: BeesSpacing.s)

                    if phase >= .hiveCrystallize {
                        hiveVideo
                            .frame(
                                width: videoWidth(in: geo),
                                height: videoHeight
                            )
                            .transition(.scale(scale: 0.4).combined(with: .opacity))
                    }

                    Spacer()
                }

                // Reveal text + naming + Continue. Snaps out fast at
                // the start of the morph (0.18s) so the typed hive
                // name doesn't ghost over HiveTabView's identity pill
                // when the overlay fades. The actual hive UI (pill,
                // stats, activity card) lives in HiveTabView underneath.
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: BeesSpacing.s + videoHeight + BeesSpacing.l)

                    revealContent
                        .opacity(isMorphing ? 0 : 1)
                        .allowsHitTesting(!isMorphing)
                        .animation(.easeOut(duration: 0.18), value: isMorphing)

                    Spacer()
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
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Welcome to your hive. Hive number 47, at Sunny Acre Farm, Sonoma County, California. Continue button.")
        .task { await runSequence() }
    }

    // MARK: - Layout

    private var videoHeight: CGFloat { 220 }

    private func videoWidth(in geo: GeometryProxy) -> CGFloat {
        isMorphing ? max(0, geo.size.width - BeesSpacing.m * 2) : 220
    }

    // MARK: - Background — stays fully opaque through the morph.
    // The fade-to-hive-tab happens at the OnboardingFlow level via
    // an opacity transition, so the gradient never visibly swaps to
    // surfacePage mid-morph.

    private var background: some View {
        LinearGradient(
            colors: [BeesColors.surfaceWarmHighlight, BeesColors.surfaceMuted.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Video

    @ViewBuilder
    private var hiveVideo: some View {
        let radius: CGFloat = isMorphing ? BeesRadius.lg : videoHeight / 2

        ZStack {
            if !isMorphing {
                Circle()
                    .fill(RadialGradient(
                        colors: [BeesColors.honey300.opacity(0.55), .clear],
                        center: .center, startRadius: 20, endRadius: 220))
                    .scaleEffect(1.6)
                    .blur(radius: 26)
                    .transition(.opacity)
            }

            videoContent
                .mask {
                    RoundedRectangle(cornerRadius: radius)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(.white.opacity(isMorphing ? 0 : 0.55), lineWidth: 3)
                }
                .overlay(alignment: .topLeading) {
                    HStack(spacing: BeesSpacing.xxs) {
                        Circle()
                            .fill(BeesColors.error500)
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(BeesType.captionS)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, BeesSpacing.xs)
                    .padding(.vertical, BeesSpacing.xxs)
                    .background(.black.opacity(0.5), in: Capsule())
                    .padding(BeesSpacing.s)
                    .opacity(isMorphing ? 1 : 0)
                }
                .shadow(color: BeesColors.honey500.opacity(isMorphing ? 0 : 0.45),
                        radius: 22, x: 0, y: 10)
        }
    }

    private var videoContent: some View {
        SharedHiveVideoPlayer()
    }

    // MARK: - Reveal content

    @ViewBuilder
    private var revealContent: some View {
        VStack(spacing: BeesSpacing.l) {
            if phase >= .nameReveal {
                VStack(spacing: BeesSpacing.xxs) {
                    Text("Meet your hive.")
                        .font(BeesType.displayL)
                        .foregroundStyle(BeesColors.charcoal900)
                    Text("Hive #47 at Sunny Acre Farm")
                        .font(BeesType.bodyL)
                        .foregroundStyle(BeesColors.charcoal900)
                    Text("Sonoma County, California")
                        .font(BeesType.bodyM)
                        .foregroundStyle(BeesColors.charcoal600)
                }
                .multilineTextAlignment(.center)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if phase >= .ctaAppear {
                namingSection
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer(minLength: BeesSpacing.s)

            if phase >= .ctaAppear {
                VStack(spacing: BeesSpacing.xs) {
                    Button("Continue") { triggerMorph() }
                        .buttonStyle(.beesPrimary)
                    Text("Free trial starts today · First jar ships in ~6 weeks")
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.charcoal600)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, BeesSpacing.l)
                .padding(.bottom, BeesSpacing.l)
                .transition(.opacity)
            }
        }
    }

    private var namingSection: some View {
        VStack(spacing: BeesSpacing.s) {
            Text("NAME IT")
                .font(BeesType.captionS)
                .tracking(1.2)
                .foregroundStyle(BeesColors.charcoal600)

            ZStack {
                RoundedRectangle(cornerRadius: BeesRadius.lg)
                    .fill(BeesColors.surfaceCard)
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)

                TextField("Buzzy McHive", text: $hiveName)
                    .font(BeesType.headingM)
                    .foregroundStyle(BeesColors.charcoal900)
                    .multilineTextAlignment(.center)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .padding(.horizontal, BeesSpacing.m)
                    .padding(.vertical, BeesSpacing.s + 2)
                    .onChange(of: hiveName) { _, newValue in
                        if newValue.count > nameLimit {
                            hiveName = String(newValue.prefix(nameLimit))
                        }
                    }
                    .onSubmit { nameFocused = false }
            }
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: BeesRadius.lg)
                    .stroke(nameFocused ? BeesColors.honey500 : BeesColors.charcoal300.opacity(0.35),
                            lineWidth: nameFocused ? 2 : 1)
                    .animation(.easeOut(duration: 0.15), value: nameFocused)
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BeesSpacing.xs) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(suggestion) {
                            hiveName = suggestion
                            nameFocused = false
                        }
                        .font(BeesType.captionM.weight(.medium))
                        .foregroundStyle(BeesColors.charcoal900)
                        .padding(.horizontal, BeesSpacing.s + 2)
                        .padding(.vertical, BeesSpacing.xxs + 2)
                        .background(BeesColors.surfaceCard, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(BeesColors.charcoal300.opacity(0.4), lineWidth: 0.5)
                        )
                    }
                }
                .padding(.horizontal, BeesSpacing.s)
            }
            .scrollClipDisabled()
        }
        .padding(.horizontal, BeesSpacing.m)
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
        await advance(to: .ctaAppear, after: 0.5, duration: 0.4)
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
        nameFocused = false
        if hiveName.isEmpty { hiveName = "Hive #47" }

        // Phase 1 — morph: reveal content (text + naming) snaps out
        // in 0.18s via its own animation override. Video circle widens
        // to a rounded rect; halo, stroke, shadow fade. Gradient stays
        // fully opaque the whole time. Total morph: 0.45s.
        withAnimation(.easeInOut(duration: 0.45)) {
            isMorphing = true
        }

        // Phase 2 — soft hand-off: as soon as the morph settles, flip
        // hasCompletedOnboarding inside withAnimation so OnboardingFlow's
        // opacity transition fades the whole overlay (gradient + video +
        // LIVE chip) out as a unit. HiveTabView underneath cross-fades
        // in through it — same SharedHiveVideoPlayer means the video
        // doesn't blink.
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.32)) {
                    onContinue()
                }
            }
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
        Text("🐝")
            .font(.system(size: 26))
    }
}

#Preview {
    NavigationStack {
        HiveRevealView(hiveName: .constant(""), onContinue: { })
    }
    .environment(ServiceContainer.preview())
}
