import SwiftUI

/// The Bees brand mark — a letterpress-style hexagonal stamp with a
/// bold serif italic "B" centered inside. Replaces the bare
/// `Image(systemName: "hexagon.fill")` everywhere the brand needs to
/// be present (auth picker, launch animation, app-icon mockup inside
/// the Apple-style sheets).
///
/// Two sizing forms:
/// - `.mark(size:)` — the stamp alone, square-ish, scales with size
/// - `.wordmark(height:)` — stamp followed by the "Bees" wordmark in
///   heavy italic serif, sized to match the mark's height
///
/// The internal hex frame line is at 25% opacity white over the
/// honey gradient — gives the surface a small inset edge so it reads
/// as a stamped object, not a flat shape.
struct BeesLogo: View {
    enum Variant { case mark, wordmark }

    var variant: Variant = .mark
    var size: CGFloat = 48
    var primary: Color = BeesColors.honey500
    var monogramColor: Color = .white

    var body: some View {
        switch variant {
        case .mark:
            stamp
        case .wordmark:
            HStack(spacing: size * 0.18) {
                stamp
                Text("Bees")
                    .font(.system(size: size * 0.62,
                                  weight: .heavy,
                                  design: .serif))
                    .italic()
                    .foregroundStyle(primary)
                    .tracking(-0.5)
            }
        }
    }

    /// The hex stamp itself. Honey gradient fill, faint inner hex
    /// outline for depth, heavy serif italic "B" centered.
    private var stamp: some View {
        ZStack {
            Image(systemName: "hexagon.fill")
                .font(.system(size: size))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.78, blue: 0.32),
                            Color(red: 0.94, green: 0.55, blue: 0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Subtle inner outline — gives a "stamped" inset feel.
            Image(systemName: "hexagon")
                .font(.system(size: size * 0.78, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.30))

            // The monogram. Bold serif italic; slight optical-center
            // nudge upward because serifs have heavier descenders.
            Text("B")
                .font(.system(size: size * 0.50, weight: .heavy, design: .serif))
                .italic()
                .foregroundStyle(monogramColor)
                .offset(y: -1)
        }
        .frame(width: size, height: size * 1.08)
    }
}

#Preview {
    VStack(spacing: 32) {
        BeesLogo(variant: .mark, size: 72)
        BeesLogo(variant: .mark, size: 48)
        BeesLogo(variant: .mark, size: 32)
        BeesLogo(variant: .wordmark, size: 56)
        BeesLogo(variant: .wordmark, size: 36)
    }
    .padding(40)
    .background(BeesColors.surfacePage)
}
