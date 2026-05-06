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

                VStack(spacing: BeesSpacing.l) {
                    Spacer().frame(height: BeesSpacing.s)

                    if phase >= .hiveCrystallize {
                        hiveVideo
                            .frame(
                                width: videoWidth(in: geo),
                                height: videoHeight
                            )
                            .transition(.scale(scale: 0.4).combined(with: .opacity))
                    }

                    if !isMorphing {
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
                            Button("Continue") { triggerMorph() }
                                .buttonStyle(.beesPrimary)
                                .padding(.horizontal, BeesSpacing.l)
                                .padding(.bottom, BeesSpacing.l)
                                .transition(.opacity)
                        }
                    } else {
                        Spacer()
                    }
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

    // MARK: - Sub-views

    @ViewBuilder
    private var hiveVideo: some View {
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
                .mask(
                    ZStack {
                        Circle()
                            .opacity(isMorphing ? 0 : 1)
                        RoundedRectangle(cornerRadius: BeesRadius.lg)
                            .opacity(isMorphing ? 1 : 0)
                    }
                )
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.55), lineWidth: 3)
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

    private var namingSection: some View {
        VStack(spacing: BeesSpacing.xs) {
            Text("NAME IT")
                .font(BeesType.captionS)
                .tracking(1.2)
                .foregroundStyle(BeesColors.charcoal600)

            TextField("Buzzy McHive", text: $hiveName)
                .focused($nameFocused)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .submitLabel(.done)
                .onChange(of: hiveName) { _, newValue in
                    if newValue.count > nameLimit {
                        hiveName = String(newValue.prefix(nameLimit))
                    }
                }
                .onSubmit { nameFocused = false }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BeesSpacing.xs) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(suggestion) {
                            hiveName = suggestion
                            nameFocused = false
                        }
                        .font(BeesType.captionM)
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

    // MARK: - Layout

    private var videoHeight: CGFloat { 220 }

    private func videoWidth(in geo: GeometryProxy) -> CGFloat {
        isMorphing ? max(0, geo.size.width - BeesSpacing.m * 2) : 220
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
        HiveRevealView(hiveName: .constant(""), onContinue: { })
    }
}
