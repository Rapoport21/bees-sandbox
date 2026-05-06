import SwiftUI

struct StatTile: View {
    let icon: String
    let value: String
    let unit: String
    let trend: Trend

    enum Trend {
        case up, down, flat

        var glyph: String {
            switch self {
            case .up:   return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .flat: return "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .up:   return BeesColors.leaf500
            case .down: return BeesColors.error500
            case .flat: return BeesColors.charcoal600
            }
        }
    }

    var body: some View {
        VStack(spacing: BeesSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(BeesColors.charcoal600)

            Text(value)
                .font(BeesType.monoM)
                .foregroundStyle(BeesColors.charcoal900)
                .contentTransition(.numericText())

            Text(unit)
                .font(BeesType.captionS)
                .foregroundStyle(BeesColors.charcoal600)

            Image(systemName: trend.glyph)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(trend.color)
        }
        .frame(width: 88, height: 88)
        .background(BeesColors.comb500, in: RoundedRectangle(cornerRadius: BeesRadius.md))
    }
}

#Preview {
    HStack(spacing: 12) {
        StatTile(icon: "thermometer", value: "92", unit: "°F", trend: .up)
        StatTile(icon: "humidity", value: "64", unit: "%", trend: .flat)
        StatTile(icon: "scalemass", value: "47", unit: "lb", trend: .up)
    }
    .padding()
}
