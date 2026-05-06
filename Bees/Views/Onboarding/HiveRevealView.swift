import SwiftUI

struct HiveRevealView: View {
    var onContinue: () -> Void
    @State private var phase: Phase = .hush
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Phase: Int, Comparable {
        case hush, beesEnter, swarmCoalesce, hiveCrystallize, nameReveal, ctaAppear
        static func < (lhs: Phase, rhs: Phase) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [BeesColors.honey100, BeesColors.comb500.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if !reduceMotion && phase >= .beesEnter && phase < .hiveCrystallize {
                BeeSwarmAnimation()
                    .accessibilityHidden(true)
            }

            VStack {
                Spacer()

                if phase >= .hiveCrystallize {
                    HiveImage()
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                        .accessibilityHidden(true)
                }

                Spacer().frame(height: BeesSpacing.xl)

                if phase >= .nameReveal {
                    VStack(spacing: BeesSpacing.s) {
                        Text("Meet your hive.")
                            .font(BeesType.displayXL)
                            .foregroundStyle(BeesColors.charcoal900)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))

                        Text("Hive #47 at Sunny Acre Farm")
                            .font(BeesType.headingM)
                            .foregroundStyle(BeesColors.charcoal900)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))

                        Text("Sonoma County, California")
                            .font(BeesType.bodyM)
                            .foregroundStyle(BeesColors.charcoal600)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    .multilineTextAlignment(.center)
                }

                Spacer()

                if phase >= .ctaAppear {
                    Button("Continue") { onContinue() }
                        .buttonStyle(.beesPrimary)
                        .padding(.horizontal, BeesSpacing.l)
                        .padding(.bottom, BeesSpacing.l)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, BeesSpacing.m)

            VStack {
                HStack {
                    Spacer()
                    if phase >= .beesEnter && phase < .ctaAppear {
                        Button("Skip") { skip() }
                            .buttonStyle(.beesGhost)
                            .transition(.opacity)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, BeesSpacing.m)
        }
        .navigationBarBackButtonHidden(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Welcome to your hive. Hive number 47, at Sunny Acre Farm, Sonoma County, California. Continue button.")
        .task { await runSequence() }
    }

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
        if delay > 0 {
            try? await Task.sleep(for: .seconds(delay))
        }
        await MainActor.run {
            withAnimation(.easeInOut(duration: duration)) {
                phase = next
            }
        }
    }

    private func skip() {
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .ctaAppear
        }
    }
}

private struct HiveImage: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [BeesColors.honey300.opacity(0.7), .clear],
                    center: .center, startRadius: 30, endRadius: 140))
                .frame(width: 280, height: 280)
                .blur(radius: 20)

            RevealHexShape()
                .fill(LinearGradient(
                    colors: [BeesColors.honey500, BeesColors.amber500],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: 160, height: 180)
                .shadow(color: BeesColors.honey500.opacity(0.4), radius: 16, y: 8)

            RevealHexShape()
                .stroke(.white.opacity(0.5), lineWidth: 2)
                .frame(width: 100, height: 110)
        }
    }
}

private struct RevealHexShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let points: [CGPoint] = [
            CGPoint(x: w / 2, y: 0),
            CGPoint(x: w, y: h * 0.25),
            CGPoint(x: w, y: h * 0.75),
            CGPoint(x: w / 2, y: h),
            CGPoint(x: 0, y: h * 0.75),
            CGPoint(x: 0, y: h * 0.25),
        ]
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
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
        .onAppear {
            animate = true
        }
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
