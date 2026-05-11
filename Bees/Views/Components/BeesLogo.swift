import SwiftUI

/// Bees brand mark — a nested hex. Thin charcoal outer outline
/// (geometric, sophisticated) with a smaller filled honey hex
/// centered inside (brand warmth, hints at "honey at the center
/// of the comb"). Matches the home-screen app icon so the same
/// composition shows up consistently from icon to in-app surfaces.
struct BeesLogo: View {
    enum Variant { case mark, wordmark }

    var variant: Variant = .mark
    var size: CGFloat = 48
    /// Outline color for the outer hex.
    var outlineColor: Color = BeesColors.charcoal900
    /// Fill color for the inner hex.
    var fillColor: Color = BeesColors.honey500

    var body: some View {
        switch variant {
        case .mark:
            mark
        case .wordmark:
            HStack(spacing: size * 0.28) {
                mark
                Text("Bees")
                    .font(.system(size: size * 0.60,
                                  weight: .regular,
                                  design: .serif))
                    .italic()
                    .foregroundStyle(outlineColor)
                    .tracking(0.3)
            }
        }
    }

    /// Outer hex outline + inner filled hex, centered. Uses two SF
    /// Symbol "hexagon"/"hexagon.fill" glyphs stacked — outer at
    /// ultra-light weight for a hairline stroke, inner at ~43% of
    /// the outer size for an inset honey accent.
    private var mark: some View {
        ZStack {
            Image(systemName: "hexagon")
                .font(.system(size: size, weight: .ultraLight))
                .foregroundStyle(outlineColor)
            Image(systemName: "hexagon.fill")
                .font(.system(size: size * 0.43))
                .foregroundStyle(fillColor)
        }
    }
}

#Preview {
    VStack(spacing: 36) {
        BeesLogo(variant: .mark, size: 120)
        BeesLogo(variant: .mark, size: 64)
        BeesLogo(variant: .mark, size: 36)
        BeesLogo(variant: .wordmark, size: 56)
        BeesLogo(variant: .wordmark, size: 36)
    }
    .padding(48)
    .background(Color(red: 0.98, green: 0.95, blue: 0.87))
}
