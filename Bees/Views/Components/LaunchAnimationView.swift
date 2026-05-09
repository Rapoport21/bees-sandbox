import SwiftUI

/// Cold-launch animation. ~2.4 seconds, paired with HapticManager's
/// staccato launch sequence so the visual snap moments line up with
/// the haptic BIG HITs at ~1.0s and ~1.34s.
///
/// Timeline:
/// - 0.00–0.55s: hexagon scales in with rotation, soft drop-in
/// - 0.55–1.00s: honey-colored glow expands and brightens behind it
/// - 1.00s:      first SNAP (hex briefly grows then settles, synced
///               with haptic BIG HIT)
/// - 1.05–1.45s: "Bees" wordmark slides up + fades in below
/// - 1.34s:      subtle second SNAP (hex pulse, second haptic BIG HIT)
/// - 1.45–2.05s: hold — wordmark gets a moment to breathe
/// - 2.05–2.40s: whole view fades to clear, calls onFinished()
struct LaunchAnimationView: View {
    var onFinished: () -> Void

    @State private var hexScale: CGFloat = 0.32
    @State private var hexRotation: Double = -160
    @State private var hexOpacity: Double = 0
    @State private var hexBoost: CGFloat = 1.0  // for SNAP punctuation
    @State private var glowOpacity: Double = 0
    @State private var glowScale: CGFloat = 1.2
    @State private var wordmarkOpacity: Double = 0
    @State private var wordmarkOffset: CGFloat = 22
    @State private var exitOpacity: Double = 1

    var body: some View {
        ZStack {
            // Warm-dark background — feels premium without being pure black
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.05, blue: 0.04),
                    Color(red: 0.14, green: 0.10, blue: 0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    // Glow halo behind hexagon
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 160, weight: .bold))
                        .foregroundStyle(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.00, green: 0.82, blue: 0.40),
                                    Color(red: 1.00, green: 0.65, blue: 0.13).opacity(0.5),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 8,
                                endRadius: 110
                            )
                        )
                        .blur(radius: 32)
                        .scaleEffect(glowScale)
                        .opacity(glowOpacity)

                    // Hex itself
                    Image(systemName: "hexagon.fill")
                        .font(.system(size: 140, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.00, green: 0.82, blue: 0.40),
                                    Color(red: 0.96, green: 0.55, blue: 0.10)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Image(systemName: "hexagon")
                                .font(.system(size: 140, weight: .bold))
                                .foregroundStyle(.white.opacity(0.18))
                        )
                        .scaleEffect(hexScale * hexBoost)
                        .rotationEffect(.degrees(hexRotation))
                        .opacity(hexOpacity)
                        .shadow(
                            color: Color(red: 1.00, green: 0.65, blue: 0.13).opacity(0.5),
                            radius: 28, y: 10
                        )
                }
                .frame(width: 200, height: 200)

                Text("Bees")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .tracking(1.5)
                    .opacity(wordmarkOpacity)
                    .offset(y: wordmarkOffset)
            }
        }
        .opacity(exitOpacity)
        .task { await runSequence() }
    }

    private func runSequence() async {
        // Fire the haptic at the same instant the visual starts so
        // the SNAPs at 1.00s and 1.34s align with the haptic BIG HITs
        // at the same timeline positions.
        HapticManager.shared.playLaunchSequence()

        // 0.00–0.55s — hex emerges with bounce
        withAnimation(.spring(duration: 0.55, bounce: 0.38)) {
            hexScale = 1.0
            hexRotation = 0
            hexOpacity = 1
        }
        try? await Task.sleep(for: .milliseconds(550))

        // 0.55–1.00s — glow expands
        withAnimation(.easeOut(duration: 0.45)) {
            glowOpacity = 0.85
            glowScale = 2.0
        }
        try? await Task.sleep(for: .milliseconds(450))

        // 1.00s — SNAP synced with first haptic BIG HIT
        withAnimation(.spring(duration: 0.18, bounce: 0.55)) {
            hexBoost = 1.14
        }
        withAnimation(.easeOut(duration: 0.35)) {
            glowOpacity = 0.4
            glowScale = 2.4
        }
        try? await Task.sleep(for: .milliseconds(140))
        withAnimation(.spring(duration: 0.35, bounce: 0.25)) {
            hexBoost = 1.0
        }

        // 1.05–1.45s — wordmark slides up + fades in (overlaps with snap)
        withAnimation(.spring(duration: 0.55, bounce: 0.2).delay(0.05)) {
            wordmarkOpacity = 1
            wordmarkOffset = 0
        }
        try? await Task.sleep(for: .milliseconds(160))

        // 1.34s — subtle SECOND SNAP synced with second haptic BIG HIT
        withAnimation(.spring(duration: 0.16, bounce: 0.5)) {
            hexBoost = 1.08
        }
        try? await Task.sleep(for: .milliseconds(120))
        withAnimation(.spring(duration: 0.30, bounce: 0.2)) {
            hexBoost = 1.0
        }

        // 1.45–2.05s — extended hold so the wordmark gets a beat to
        // breathe before exit
        try? await Task.sleep(for: .milliseconds(600))

        // 2.05–2.40s — fade everything to clear
        withAnimation(.easeIn(duration: 0.35)) {
            exitOpacity = 0
        }
        try? await Task.sleep(for: .milliseconds(360))

        onFinished()
    }
}

#Preview {
    LaunchAnimationView(onFinished: { })
}
