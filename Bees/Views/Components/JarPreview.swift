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
            colors: [BeesColors.surfaceWarmHighlight, BeesColors.surfaceMuted],
            center: .center,
            startRadius: 10,
            endRadius: size
        )
        .clipShape(RoundedRectangle(cornerRadius: BeesRadius.lg))
    }

    private var jar: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(
                    colors: [BeesColors.charcoal600, BeesColors.charcoal900],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.65, height: size * 0.08)

            Rectangle()
                .fill(LinearGradient(
                    colors: [Color(white: 0.95).opacity(0.6), Color(white: 0.85).opacity(0.4)],
                    startPoint: .leading, endPoint: .trailing))
                .frame(width: size * 0.55, height: size * 0.05)

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
        let stickerWidth = size * 0.66
        let stickerHeight = size * 0.86
        return ZStack {
            stickerShape
                .fill(design.baseDesign.backgroundColor)
                .shadow(color: BeesColors.shadowWarm.opacity(0.18), radius: 4, x: 0, y: 2)

            stickerShape
                .stroke(design.baseDesign.accentColor.opacity(0.25), lineWidth: 1.5)
                .padding(6)

            VStack(spacing: BeesSpacing.xxs) {
                Image(systemName: design.baseDesign.accentIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.7))

                Text(design.baseDesign.name.uppercased())
                    .font(.system(size: 8, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.7))

                Rectangle()
                    .fill(design.baseDesign.accentColor.opacity(0.3))
                    .frame(width: 24, height: 1)

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
                    .frame(width: 24, height: 1)

                Image(systemName: design.baseDesign.accentIcon)
                    .font(.system(size: 10))
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.5))
            }
            .padding(.vertical, BeesSpacing.s)
            .padding(.horizontal, BeesSpacing.m)
        }
        .frame(width: stickerWidth, height: stickerHeight)
    }

    private var stickerShape: AnyShape {
        switch design.baseDesign.shape {
        case .rounded: return AnyShape(RoundedRectangle(cornerRadius: 8))
        case .square:  return AnyShape(Rectangle())
        case .oval:    return AnyShape(Ellipse())
        case .hexagon: return AnyShape(HexagonShape())
        case .badge:   return AnyShape(BadgeShape())
        case .scallop: return AnyShape(ScallopShape())
        }
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let pts: [CGPoint] = [
            .init(x: w / 2, y: 0),
            .init(x: w, y: h * 0.25),
            .init(x: w, y: h * 0.75),
            .init(x: w / 2, y: h),
            .init(x: 0, y: h * 0.75),
            .init(x: 0, y: h * 0.25),
        ]
        path.move(to: pts[0])
        pts.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}

struct BadgeShape: Shape {
    var notches: Int = 24
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.94
        let total = notches * 2
        for i in 0..<total {
            let angle = (Double(i) / Double(total)) * 2 * .pi - .pi / 2
            let r = i.isMultiple(of: 2) ? outer : inner
            let p = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        return path
    }
}

struct ScallopShape: Shape {
    var bumps: Int = 12
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset: CGFloat = rect.width * 0.04
        let inner = rect.insetBy(dx: inset, dy: inset)
        let bumpRadius: CGFloat = inset

        path.move(to: CGPoint(x: inner.minX, y: inner.minY))
        let topBumps = max(2, bumps / 3)
        for i in 0...topBumps {
            let x = inner.minX + (inner.width / CGFloat(topBumps)) * CGFloat(i)
            path.addArc(center: CGPoint(x: x, y: inner.minY),
                        radius: bumpRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
        }
        let sideBumps = max(2, bumps / 3)
        for i in 0...sideBumps {
            let y = inner.minY + (inner.height / CGFloat(sideBumps)) * CGFloat(i)
            path.addArc(center: CGPoint(x: inner.maxX, y: y),
                        radius: bumpRadius, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
        }
        for i in 0...topBumps {
            let x = inner.maxX - (inner.width / CGFloat(topBumps)) * CGFloat(i)
            path.addArc(center: CGPoint(x: x, y: inner.maxY),
                        radius: bumpRadius, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
        }
        for i in 0...sideBumps {
            let y = inner.maxY - (inner.height / CGFloat(sideBumps)) * CGFloat(i)
            path.addArc(center: CGPoint(x: inner.minX, y: y),
                        radius: bumpRadius, startAngle: .degrees(90), endAngle: .degrees(-90), clockwise: true)
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            ForEach(StickerBaseDesign.catalog) { base in
                JarPreview(
                    design: StickerDesign(id: UUID(), baseDesignId: base.id,
                                          line1: "Buzzy", line2: "Spring 2026", line3: "",
                                          fontId: "modern-sans", colorId: "charcoal"),
                    size: 200
                )
            }
        }
        .padding()
    }
}
