import SwiftUI

struct JarPreview: View {
    let design: StickerDesign
    var size: CGFloat = 220

    var body: some View {
        ZStack {
            backdrop
            jar
        }
        .frame(width: size, height: size * 1.4)
    }

    private var backdrop: some View {
        RadialGradient(
            colors: [BeesColors.honey100, BeesColors.comb500],
            center: .center,
            startRadius: 10,
            endRadius: size
        )
        .clipShape(RoundedRectangle(cornerRadius: BeesRadius.lg))
    }

    private var jar: some View {
        VStack(spacing: 0) {
            // Lid
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(
                    colors: [BeesColors.charcoal600, BeesColors.charcoal900],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.65, height: size * 0.08)

            // Neck
            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(white: 0.95).opacity(0.6), Color(white: 0.85).opacity(0.4)],
                    startPoint: .leading, endPoint: .trailing))
                .frame(width: size * 0.55, height: size * 0.05)

            // Body with honey + sticker
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.08)
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.78, blue: 0.30),
                            Color(red: 0.85, green: 0.55, blue: 0.10),
                        ],
                        startPoint: .top, endPoint: .bottom))
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.08)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                            .blendMode(.overlay)
                    )

                // Glass highlight
                RoundedRectangle(cornerRadius: size * 0.08)
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.35), .clear],
                        startPoint: .topLeading, endPoint: .center))
                    .blendMode(.softLight)

                stickerOverlay
            }
            .frame(width: size * 0.78, height: size * 1.05)
        }
    }

    private var stickerOverlay: some View {
        VStack(spacing: BeesSpacing.xxs) {
            Text(design.baseDesign.name.uppercased())
                .font(.system(size: 9, weight: .heavy))
                .tracking(2)
                .foregroundStyle(design.baseDesign.accentColor.opacity(0.7))

            Rectangle()
                .fill(design.baseDesign.accentColor.opacity(0.3))
                .frame(width: 30, height: 1)

            ForEach(Array(design.allLines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(design.font.font)
                    .foregroundStyle(design.color.color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }

            if design.allLines.isEmpty {
                Text("Your text here")
                    .font(design.font.font)
                    .foregroundStyle(design.color.color.opacity(0.4))
                    .italic()
            }

            Rectangle()
                .fill(design.baseDesign.accentColor.opacity(0.3))
                .frame(width: 30, height: 1)

            Image(systemName: "leaf.fill")
                .font(.system(size: 12))
                .foregroundStyle(design.baseDesign.accentColor.opacity(0.6))
        }
        .padding(.vertical, BeesSpacing.s)
        .padding(.horizontal, BeesSpacing.m)
        .frame(width: size * 0.62, height: size * 0.82)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(design.baseDesign.backgroundColor)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 24) {
        JarPreview(design: Fixtures.demoActiveDesign, size: 200)
        JarPreview(design: StickerDesign(id: UUID(), baseDesignId: "minimalist", line1: "Hello", line2: "World", line3: "", fontId: "handwritten", colorId: "amber"), size: 160)
    }
    .padding()
}
