import SwiftUI

/// Recurring hexagonal motif components — the brand's visual signature
/// across selection states, pagination, dividers, and moments where a
/// generic circle would otherwise appear. Bees → honeycomb → hex.
///
/// Used in: TierComparisonView (selection radio), JarStudioView
/// (pagination), HiveTabView (section divider).

// MARK: - Pointy-top hex (selection/radio glyph)

/// Six-sided shape with a flat top and pointy left/right edges. Used
/// as the unifying selection indicator instead of a generic circle.
struct PointyTopHex: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let pts: [CGPoint] = [
            CGPoint(x: w * 0.5,  y: 0),
            CGPoint(x: w,        y: h * 0.27),
            CGPoint(x: w,        y: h * 0.73),
            CGPoint(x: w * 0.5,  y: h),
            CGPoint(x: 0,        y: h * 0.73),
            CGPoint(x: 0,        y: h * 0.27),
        ]
        path.move(to: pts[0])
        for p in pts.dropFirst() { path.addLine(to: p) }
        path.closeSubpath()
        return path
    }
}

/// Selection indicator that replaces a generic circle radio. Filled
/// hex when selected (with a small inner hex for that "honeycomb-cell"
/// feel), outlined hex when not. ~22pt — matches Apple's 22pt circle.
struct HexagonRadio: View {
    let isSelected: Bool
    var size: CGFloat = 24
    var fillColor: Color = BeesColors.honey500
    var strokeColor: Color = BeesColors.charcoal300

    var body: some View {
        ZStack {
            PointyTopHex()
                .stroke(isSelected ? fillColor : strokeColor, lineWidth: 1.5)
                .frame(width: size, height: size * 1.08)

            if isSelected {
                PointyTopHex()
                    .fill(fillColor)
                    .frame(width: size * 0.55, height: size * 0.55 * 1.08)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.32, bounce: 0.35), value: isSelected)
    }
}

// MARK: - Hex pagination dot

/// Small filled hex for pagination strips. Replaces the generic dot
/// row with a honeycomb-cell row. Active state stretches into a
/// horizontal capsule of hexes for a "filled cell" feel.
struct HexPaginationDot: View {
    let isActive: Bool
    var size: CGFloat = 6
    var color: Color = BeesColors.honey500

    var body: some View {
        PointyTopHex()
            .fill(isActive ? color : color.opacity(0.25))
            .frame(width: isActive ? size * 3 : size,
                   height: size * 1.08)
            .animation(.easeOut(duration: 0.25), value: isActive)
    }
}

// MARK: - Section header (editorial)

/// Editorial-style section header. Numbered prefix + thin hairline +
/// uppercase label. Replaces the generic "ALL CAPS LABEL" pattern.
///
///     SectionLabel(number: "01", title: "ACTIVITY")
struct SectionLabel: View {
    let number: String
    let title: String
    var accentColor: Color = BeesColors.honey500

    var body: some View {
        HStack(spacing: BeesSpacing.xs) {
            Text(number)
                .font(.system(size: 11, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(accentColor)
            Rectangle()
                .fill(BeesColors.charcoal300.opacity(0.5))
                .frame(width: 16, height: 1)
            Text(title)
                .font(BeesType.captionS)
                .tracking(1.4)
                .foregroundStyle(BeesColors.charcoal600)
        }
    }
}

// MARK: - Hand-stuck tape badge

/// "MOST POPULAR" / "RECOMMENDED" / similar emphasis label, rotated
/// slightly so it reads as a hand-stuck paper tape rather than a
/// digital pill. Used on the recommended tier card.
struct TapeBadge: View {
    let text: String
    var rotation: Double = -2.5

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .heavy))
            .tracking(1.0)
            .foregroundStyle(.white)
            .padding(.horizontal, BeesSpacing.xs + 2)
            .padding(.vertical, 3)
            .background(BeesColors.honey500, in: Capsule())
            .shadow(color: BeesColors.shadowWarm.opacity(0.18), radius: 3, y: 1)
            .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    VStack(spacing: 32) {
        HStack(spacing: 12) {
            HexagonRadio(isSelected: false)
            HexagonRadio(isSelected: true)
        }

        HStack(spacing: 6) {
            HexPaginationDot(isActive: false)
            HexPaginationDot(isActive: true)
            HexPaginationDot(isActive: false)
        }

        SectionLabel(number: "01", title: "ACTIVITY")
        SectionLabel(number: "02", title: "PRODUCTION")

        TapeBadge(text: "MOST POPULAR")
    }
    .padding()
    .background(BeesColors.surfacePage)
}
