import SwiftUI

struct HiveStatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let delta: String?
    let deltaPositive: Bool
    let sparkline: [Double]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            HStack(spacing: BeesSpacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 18, height: 18)
                    .background(accent.opacity(0.14), in: Circle())
                Text(title)
                    .font(BeesType.captionS)
                    .tracking(0.6)
                    .foregroundStyle(BeesColors.charcoal600)
                Spacer(minLength: 0)
            }

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(BeesType.displayM)
                    .foregroundStyle(BeesColors.charcoal900)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(unit)
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
                Spacer(minLength: 0)
            }

            HStack(alignment: .center, spacing: BeesSpacing.xs) {
                Sparkline(values: sparkline, color: accent)
                    .frame(height: 22)
                    .frame(maxWidth: .infinity)

                if let delta {
                    Text(delta)
                        .font(BeesType.captionS)
                        .foregroundStyle(deltaPositive ? BeesColors.leaf500 : BeesColors.charcoal600)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            (deltaPositive ? BeesColors.leaf500 : BeesColors.charcoal600).opacity(0.12),
                            in: Capsule()
                        )
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .padding(BeesSpacing.s + 2)
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
            let stepX = values.count > 1
                ? geo.size.width / CGFloat(values.count - 1)
                : geo.size.width
            let pts: [CGPoint] = values.enumerated().map { idx, v in
                CGPoint(
                    x: CGFloat(idx) * stepX,
                    y: geo.size.height - CGFloat((v - minV) / range) * geo.size.height
                )
            }

            ZStack {
                Path { p in
                    guard let first = pts.first else { return }
                    p.move(to: CGPoint(x: first.x, y: geo.size.height))
                    p.addLine(to: first)
                    for pt in pts.dropFirst() { p.addLine(to: pt) }
                    p.addLine(to: CGPoint(x: pts.last?.x ?? 0, y: geo.size.height))
                    p.closeSubpath()
                }
                .fill(LinearGradient(
                    colors: [color.opacity(0.32), color.opacity(0.0)],
                    startPoint: .top, endPoint: .bottom))

                Path { p in
                    guard let first = pts.first else { return }
                    p.move(to: first)
                    for pt in pts.dropFirst() { p.addLine(to: pt) }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            }
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
                Text("Jar #\(jarsHarvested + 1) · ≈ \(daysToNextJar) day\(daysToNextJar == 1 ? "" : "s") to harvest")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
                Spacer()
                Text("\(Int(pct * 100))%")
                    .font(BeesType.captionS.weight(.semibold))
                    .foregroundStyle(BeesColors.honey500)
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
            HiveStatCard(
                icon: "thermometer",
                title: "TEMPERATURE",
                value: "92",
                unit: "°F",
                delta: "+0.4",
                deltaPositive: true,
                sparkline: [89, 90, 91, 90, 91, 92, 92, 91, 92, 93, 92, 92],
                accent: BeesColors.amber500
            )
            HiveStatCard(
                icon: "humidity",
                title: "HUMIDITY",
                value: "64",
                unit: "%",
                delta: "stable",
                deltaPositive: false,
                sparkline: [62, 63, 62, 64, 63, 64, 64, 63, 64, 65, 64, 64],
                accent: BeesColors.honey500
            )
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
