import SwiftUI

struct HiveRevealView: View {
    @Binding var hiveName: String
    var onContinue: () -> Void

    @State private var phase: Phase = .hush
    @State private var isMorphing = false
    @State private var hiveContentVisible = false
    @FocusState private var nameFocused: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(ServiceContainer.self) private var services

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

                // Video — fixed top position, only width + shape morph
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

                // Below-video region holds BOTH reveal and hive-tab content
                // overlaid in a ZStack so layout never reflows.
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: BeesSpacing.s + videoHeight + BeesSpacing.l)

                    ZStack(alignment: .top) {
                        revealContent
                            .opacity(isMorphing ? 0 : 1)
                            .allowsHitTesting(!isMorphing)

                        hiveTabContent
                            .padding(.horizontal, BeesSpacing.m)
                            .opacity(hiveContentVisible ? 1 : 0)
                            .allowsHitTesting(false)
                    }

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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Welcome to your hive. Hive number 47, at Sunny Acre Farm, Sonoma County, California. Continue button.")
        .task { await runSequence() }
    }

    // MARK: - Layout

    private var videoHeight: CGFloat { 220 }

    private func videoWidth(in geo: GeometryProxy) -> CGFloat {
        isMorphing ? max(0, geo.size.width - BeesSpacing.m * 2) : 220
    }

    // MARK: - Background

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

    // MARK: - Hive tab content (below video) — fades in during morph

    private var hiveTabContent: some View {
        VStack(spacing: BeesSpacing.l) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(hiveName.isEmpty ? "Hive #47" : hiveName)
                        .font(BeesType.displayM)
                        .foregroundStyle(BeesColors.charcoal900)
                    Text("\(services.hiveService.hive.farmName) · \(services.hiveService.hive.farmLocation)")
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.charcoal600)
                        .lineLimit(1)
                }
                Spacer()
                HealthPill(health: services.hiveService.current.health)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BeesSpacing.s) {
                    StatTile(icon: "thermometer",
                             value: String(format: "%.0f", services.hiveService.current.temperatureF),
                             unit: "°F", trend: .up)
                    StatTile(icon: "humidity",
                             value: String(format: "%.0f", services.hiveService.current.humidityPct),
                             unit: "%", trend: .flat)
                    StatTile(icon: "scalemass",
                             value: String(format: "%.1f", services.hiveService.current.weightLb),
                             unit: "lb", trend: .up)
                    StatTile(icon: "ant",
                             value: "\(services.hiveService.current.populationEstimate / 1000)k",
                             unit: "BEES", trend: .up)
                    StatTile(icon: "arrow.up.forward",
                             value: format(services.hiveService.current.takeoffsLast24h),
                             unit: "OUT", trend: .up)
                    StatTile(icon: "arrow.down.left",
                             value: format(services.hiveService.current.landingsLast24h),
                             unit: "IN", trend: .up)
                }
            }
            .scrollDisabled(true)

            VStack(alignment: .leading, spacing: BeesSpacing.s) {
                HStack(spacing: BeesSpacing.xs) {
                    Text("🐝")
                    Text("ACTIVITY RIGHT NOW")
                        .font(BeesType.captionM)
                        .tracking(1)
                        .foregroundStyle(BeesColors.charcoal600)
                }

                HStack(spacing: BeesSpacing.xl) {
                    counter(label: "Take-offs", value: services.hiveService.activity.rollingTakeoffs, glyph: "↑")
                    counter(label: "Landings", value: services.hiveService.activity.rollingLandings, glyph: "↓")
                }
            }
            .padding(BeesSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [BeesColors.surfaceWarmHighlight, BeesColors.surfaceMuted],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: BeesRadius.lg)
            )
        }
    }

    private func counter(label: String, value: Int, glyph: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: BeesSpacing.xxs) {
                Text(glyph)
                    .font(BeesType.headingM)
                    .foregroundStyle(BeesColors.honey500)
                Text(format(value))
                    .font(BeesType.monoL)
                    .foregroundStyle(BeesColors.charcoal900)
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
        }
    }

    private func format(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
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

        // One smooth motion — circle expands to rounded rect, hive UI
        // appears below in the same animation tick. No spring (no shake).
        withAnimation(.easeInOut(duration: 0.55)) {
            isMorphing = true
            hiveContentVisible = true
        }

        // Hand off to the real Hive tab AFTER the morph + UI fade-in
        // have completely settled. ContentView cross-fades the tree
        // swap so the LoopingVideoPlayer instance change is masked.
        Task {
            try? await Task.sleep(for: .milliseconds(950))
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
    .environment(ServiceContainer.preview())
}
