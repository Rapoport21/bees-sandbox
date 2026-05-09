import SwiftUI

/// Editorial-style stat card. Quieter than the previous version —
/// no icon chip, no sparkline (was decorative fake data), no delta
/// capsule. Title in small caps + big serif value in Calistoga + small
/// unit caption. The serif value is the hero of the card, breathing
/// room around it.
struct HiveStatCard: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            Text(title)
                .font(BeesType.captionS)
                .tracking(1.0)
                .foregroundStyle(BeesColors.charcoal600)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(BeesType.displayM)  // Calistoga 26pt serif
                    .foregroundStyle(BeesColors.charcoal900)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(unit)
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.vertical, BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BeesRadius.lg)
                .stroke(BeesColors.charcoal300.opacity(0.18), lineWidth: 0.5)
        )
    }
}

struct Sparkline: View {
    let values: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let minV = values.min() ?? 0
            let maxV = values.max() ?? 1
            let range = max(maxV - minV, 0.0001)
            let inset: CGFloat = 1
            let usableHeight = max(geo.size.height - inset * 2, 1)
            let stepX = values.count > 1
                ? geo.size.width / CGFloat(values.count - 1)
                : geo.size.width
            let pts: [CGPoint] = values.enumerated().map { idx, v in
                CGPoint(
                    x: CGFloat(idx) * stepX,
                    y: inset + usableHeight - CGFloat((v - minV) / range) * usableHeight
                )
            }

            ZStack {
                Path { p in
                    guard let first = pts.first else { return }
                    p.move(to: CGPoint(x: first.x, y: geo.size.height))
                    p.addLine(to: first)
                    Self.addSmoothCurve(to: &p, points: pts)
                    p.addLine(to: CGPoint(x: pts.last?.x ?? 0, y: geo.size.height))
                    p.closeSubpath()
                }
                .fill(LinearGradient(
                    colors: [color.opacity(0.32), color.opacity(0.0)],
                    startPoint: .top, endPoint: .bottom))

                Path { p in
                    guard let first = pts.first else { return }
                    p.move(to: first)
                    Self.addSmoothCurve(to: &p, points: pts)
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            }
        }
    }

    /// Cubic bezier through every pair of consecutive points with
    /// horizontal-tangent control points at the midpoint X. Produces
    /// a softly curved monotone spline — no overshoot, no kinks.
    private static func addSmoothCurve(to path: inout Path, points: [CGPoint]) {
        guard points.count > 1 else { return }
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let midX = (prev.x + curr.x) / 2
            path.addCurve(
                to: curr,
                control1: CGPoint(x: midX, y: prev.y),
                control2: CGPoint(x: midX, y: curr.y)
            )
        }
    }
}

struct HoneyProductionCard: View {
    let honeyLb: Double
    let jarTargetLb: Double
    let jarsHarvested: Int
    let weeklyDelta: Double

    private var pct: Double { min(max(honeyLb / jarTargetLb, 0), 1) }
    private var daysToNextJar: Int {
        let remaining = max(jarTargetLb - honeyLb, 0)
        let perDay = max(weeklyDelta / 7, 0.01)
        return Int(ceil(remaining / perDay))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            HStack(spacing: BeesSpacing.xxs) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(BeesColors.honey500)
                    .frame(width: 18, height: 18)
                    .background(BeesColors.honey500.opacity(0.16), in: Circle())
                Text("HONEY PRODUCTION")
                    .font(BeesType.captionS)
                    .tracking(0.8)
                    .foregroundStyle(BeesColors.charcoal600)
                Spacer()
                Text("Season")
                    .font(BeesType.captionS)
                    .foregroundStyle(BeesColors.charcoal600)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", honeyLb))
                    .font(BeesType.displayL)
                    .foregroundStyle(BeesColors.charcoal900)
                    .contentTransition(.numericText())
                Text("lb")
                    .font(BeesType.headingM)
                    .foregroundStyle(BeesColors.charcoal600)

                Spacer()

                Text(String(format: "+%.1f lb / week", weeklyDelta))
                    .font(BeesType.captionS)
                    .foregroundStyle(BeesColors.leaf500)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(BeesColors.leaf500.opacity(0.12), in: Capsule())
            }

            jarFillBar

            HStack {
                Text(milestoneCopy)
                    .font(BeesType.captionM)
                    .foregroundStyle(milestoneColor)
                Spacer()
                Text(percentChip)
                    .font(BeesType.captionS.weight(.semibold))
                    .foregroundStyle(pct >= 1.0 ? BeesColors.amber500 : BeesColors.honey500)
                    .monospacedDigit()
            }
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BeesRadius.lg)
                .stroke(BeesColors.charcoal300.opacity(0.18), lineWidth: 0.5)
        )
    }

    /// Beekeeper-voice copy that changes as the jar fills. Quiet
    /// celebration without being loud — the brand is "warm + earnest
    /// + grounded," not "🎉 jar party."
    private var milestoneCopy: String {
        let jarNumber = jarsHarvested + 1
        let remaining = max(jarTargetLb - honeyLb, 0)
        switch pct {
        case 1.0...:
            return "Jar #\(jarNumber) is ready to harvest"
        case 0.9..<1.0:
            return "Almost there — \(String(format: "%.1f", remaining)) lb to jar #\(jarNumber)"
        case 0.5..<0.9:
            return "Halfway to jar #\(jarNumber) · ≈ \(daysToNextJar) days to harvest"
        default:
            return "Jar #\(jarNumber) · ≈ \(daysToNextJar) day\(daysToNextJar == 1 ? "" : "s") to harvest"
        }
    }

    /// Subtly colors the milestone line at high progress to draw the
    /// eye without being a pop-up.
    private var milestoneColor: Color {
        pct >= 0.9 ? BeesColors.charcoal900 : BeesColors.charcoal600
    }

    /// At 100%, the percent chip swaps to a word — "Ready" — instead
    /// of "100%". Reads as completion, not measurement.
    private var percentChip: String {
        pct >= 1.0 ? "Ready" : "\(Int(pct * 100))%"
    }

    private var jarFillBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(BeesColors.surfaceMuted)

                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(
                        colors: [BeesColors.honey300, BeesColors.honey500, BeesColors.amber500],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * pct)
            }
        }
        .frame(height: 12)
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            HiveStatCard(title: "TEMPERATURE", value: "92", unit: "°F")
            HiveStatCard(title: "HUMIDITY", value: "64", unit: "%")
        }
        HoneyProductionCard(
            honeyLb: 8.4,
            jarTargetLb: 12,
            jarsHarvested: 3,
            weeklyDelta: 1.2
        )
    }
    .padding()
    .background(BeesColors.surfacePage)
}
