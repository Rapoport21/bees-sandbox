import SwiftUI

struct HealthPill: View {
    let health: HiveSnapshot.Health

    var body: some View {
        Text(health.displayName)
            .font(BeesType.captionS)
            .tracking(0.8)
            .foregroundStyle(textColor)
            .padding(.horizontal, BeesSpacing.s)
            .padding(.vertical, BeesSpacing.xxs + 2)
            .background(backgroundColor, in: Capsule())
    }

    private var backgroundColor: Color {
        switch health {
        case .thriving: return BeesColors.leaf500
        case .steady:   return BeesColors.honey500
        case .watch:    return BeesColors.amber500
        case .alert:    return BeesColors.error500
        case .dormant:  return BeesColors.charcoal300
        }
    }

    private var textColor: Color {
        switch health {
        case .thriving, .watch, .alert: return .white
        case .steady, .dormant:         return BeesColors.charcoal900
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        HealthPill(health: .thriving)
        HealthPill(health: .steady)
        HealthPill(health: .watch)
        HealthPill(health: .alert)
        HealthPill(health: .dormant)
    }
    .padding()
}
