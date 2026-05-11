import SwiftUI

/// Bees brand mark — a single thin hex outline, no fill, no monogram.
/// Minimal / elegant / sophisticated. Generous negative space. The
/// form is the brand. Matches the home-screen app icon (cream
/// background, charcoal hex outline) so the same mark shows up
/// consistently from the icon to the in-app surfaces.
struct BeesLogo: View {
    enum Variant { case mark, wordmark }

    var variant: Variant = .mark
    var size: CGFloat = 48
    var color: Color = BeesColors.charcoal900

    var body: some View {
        switch variant {
        case .mark:
            mark
        case .wordmark:
            HStack(spacing: size * 0.30) {
                mark
                Text("Bees")
                    .font(.system(size: size * 0.62,
                                  weight: .light,
                                  design: .serif))
                    .italic()
                    .foregroundStyle(color)
                    .tracking(0.5)
            }
        }
    }

    /// SF Symbol `hexagon` (outline) at ultra-light weight. The
    /// hairline stroke is what makes the mark feel refined rather
    /// than chunky. Scales correctly with the `size` parameter.
    private var mark: some View {
        Image(systemName: "hexagon")
            .font(.system(size: size, weight: .ultraLight))
            .foregroundStyle(color)
    }
}

#Preview {
    VStack(spacing: 36) {
        BeesLogo(variant: .mark, size: 96)
        BeesLogo(variant: .mark, size: 56)
        BeesLogo(variant: .mark, size: 32)
        BeesLogo(variant: .wordmark, size: 56)
        BeesLogo(variant: .wordmark, size: 36)
    }
    .padding(48)
    .background(Color(red: 0.98, green: 0.95, blue: 0.87))
}
