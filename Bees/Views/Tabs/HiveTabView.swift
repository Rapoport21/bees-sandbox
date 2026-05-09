import SwiftUI

struct HiveTabView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = HiveTabAppearance.shared.didAnimate

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BeesSpacing.l) {
                    videoPlaceholder
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 14)
                        .animation(entrance(at: 0), value: hasAppeared)
                    hiveIdentityPill
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 14)
                        .animation(entrance(at: 1), value: hasAppeared)
                    statGrid
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 14)
                        .animation(entrance(at: 2), value: hasAppeared)
                    honeyProductionTile
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 14)
                        .animation(entrance(at: 3), value: hasAppeared)
                    activityCard
                        .opacity(hasAppeared ? 1 : 0)
                        .offset(y: hasAppeared ? 0 : 14)
                        .animation(entrance(at: 4), value: hasAppeared)
                }
                .padding(.horizontal, BeesSpacing.m)
                .padding(.top, BeesSpacing.s)
                .padding(.bottom, BeesSpacing.xl)
            }
            .background(BeesColors.surfacePage.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: StatType.self) { stat in
                StatDetailView(stat: stat)
            }
            .task {
                guard !hasAppeared else { return }
                // Tiny delay so the view is on-screen before we
                // trigger the staggered reveal — otherwise the
                // animation runs while the surface is still
                // sliding/cross-fading from the onboarding overlay.
                try? await Task.sleep(for: .milliseconds(80))
                HiveTabAppearance.shared.didAnimate = true
                hasAppeared = true
            }
        }
    }

    /// Per-row entrance animation, staggered ~70ms apart. Disabled if
    /// the user has reduce-motion on.
    private func entrance(at index: Int) -> Animation? {
        guard !reduceMotion else { return nil }
        return .easeOut(duration: 0.5).delay(Double(index) * 0.07)
    }

    private var videoPlaceholder: some View {
        ZStack {
            SharedHiveVideoPlayer()
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: BeesRadius.lg))

            VStack {
                HStack {
                    HStack(spacing: BeesSpacing.xxs) {
                        Circle()
                            .fill(BeesColors.error500)
                            .frame(width: 6, height: 6)
                        Text("LIVE")
                            .font(BeesType.captionS)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, BeesSpacing.xs)
                    .padding(.vertical, BeesSpacing.xxs)
                    .background(.black.opacity(0.5), in: Capsule())
                    Spacer()
                }
                .padding(BeesSpacing.s)
                Spacer()
            }
        }
        .frame(height: 220)
    }

    private var hiveIdentityPill: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(services.hiveService.hive.name)
                    .font(BeesType.displayM)
                    .foregroundStyle(BeesColors.charcoal900)
                Text("\(services.hiveService.hive.farmName) · \(services.hiveService.hive.farmLocation)")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
                    .lineLimit(1)
            }
            Spacer()
            HealthPill(health: services.hiveService.current.health)
        }
    }

    private var statGrid: some View {
        let snapshot = services.hiveService.current
        let columns = [
            GridItem(.flexible(), spacing: BeesSpacing.s),
            GridItem(.flexible(), spacing: BeesSpacing.s),
        ]
        return LazyVGrid(columns: columns, spacing: BeesSpacing.s) {
            NavigationLink(value: StatType.temperature) {
                HiveStatCard(
                    icon: StatType.temperature.iconName,
                    title: "TEMPERATURE",
                    value: String(format: "%.0f", snapshot.temperatureF),
                    unit: "°F",
                    delta: "+0.4",
                    deltaPositive: true,
                    sparkline: sparkline(for: .temperature, base: snapshot.temperatureF, jitter: 1.4),
                    accent: BeesColors.amber500
                )
            }
            NavigationLink(value: StatType.humidity) {
                HiveStatCard(
                    icon: StatType.humidity.iconName,
                    title: "HUMIDITY",
                    value: String(format: "%.0f", snapshot.humidityPct),
                    unit: "%",
                    delta: "stable",
                    deltaPositive: false,
                    sparkline: sparkline(for: .humidity, base: snapshot.humidityPct, jitter: 1.8),
                    accent: BeesColors.honey500
                )
            }
            NavigationLink(value: StatType.weight) {
                HiveStatCard(
                    icon: StatType.weight.iconName,
                    title: "WEIGHT",
                    value: String(format: "%.1f", snapshot.weightLb),
                    unit: "lb",
                    delta: "+0.3",
                    deltaPositive: true,
                    sparkline: sparkline(for: .weight, base: snapshot.weightLb, jitter: 0.6, trend: 0.8),
                    accent: BeesColors.leaf500
                )
            }
            NavigationLink(value: StatType.population) {
                HiveStatCard(
                    icon: StatType.population.iconName,
                    title: "POPULATION",
                    value: "\(snapshot.populationEstimate / 1000)k",
                    unit: "bees",
                    delta: "+1.2k",
                    deltaPositive: true,
                    sparkline: sparkline(for: .population, base: Double(snapshot.populationEstimate), jitter: 1200, trend: 1500),
                    accent: BeesColors.honey500
                )
            }
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var honeyProductionTile: some View {
        NavigationLink(value: StatType.honey) {
            HoneyProductionCard(
                honeyLb: services.hiveService.current.honeyEstimateLb,
                jarTargetLb: 12,
                jarsHarvested: 3,
                weeklyDelta: 1.2
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func sparkline(for stat: StatType, base: Double, jitter: Double, trend: Double = 0) -> [Double] {
        var seed = stat.hashValue
        return (0..<14).map { i in
            seed = seed &* 1_103_515_245 &+ 12_345
            let r = Double((seed >> 16) & 0x7FFF) / Double(0x7FFF) - 0.5
            let trendOffset = trend * (Double(i) / 13)
            return base - trend + trendOffset + r * jitter
        }
    }

    private var activityCard: some View {
        let activity = services.hiveService.activity
        let last60 = activity.takeoffsLast60s + activity.landingsLast60s
        return VStack(alignment: .leading, spacing: BeesSpacing.s) {
            // "Stats are stories" — frame this as the hive *being busy
            // right now* rather than a stopwatch readout.
            Text(activityNarration(last60: last60))
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal900)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: BeesSpacing.xl) {
                counter(label: "Out today",
                        value: activity.rollingTakeoffs, glyph: "↑")
                counter(label: "Back today",
                        value: activity.rollingLandings, glyph: "↓")
            }

            // Quieter than ProgressView — a ribbon that fills as
            // activity rises rather than a bar gauge.
            activityRibbon(last60: last60)
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [BeesColors.surfaceWarmHighlight, BeesColors.surfaceMuted],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: BeesRadius.lg)
        )
    }

    private func activityNarration(last60: Int) -> String {
        switch last60 {
        case 0...3:    return "Quiet at the entrance — most of the colony is inside."
        case 4...10:   return "Steady flow in and out of the hive."
        case 11...20:  return "Busy — foragers heading out, workers coming back."
        default:       return "Peak traffic. The hive is having a moment."
        }
    }

    private func activityRibbon(last60: Int) -> some View {
        let pct = min(Double(last60) / 60.0, 1.0)
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(BeesColors.charcoal300.opacity(0.25))
                Capsule()
                    .fill(LinearGradient(
                        colors: [BeesColors.honey300, BeesColors.honey500, BeesColors.amber500],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(8, geo.size.width * pct))
                    .animation(.easeOut(duration: 0.6), value: pct)
            }
        }
        .frame(height: 6)
    }

    private func counter(label: String, value: Int, glyph: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: BeesSpacing.xxs) {
                Text(glyph)
                    .font(BeesType.headingM)
                    .foregroundStyle(BeesColors.honey500)
                Text(format(value))
                    .font(BeesType.monoL)
                    .foregroundStyle(BeesColors.charcoal900)
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
        }
    }

    private func format(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

/// Tracks whether the staggered Hive-tab entrance has played in this
/// app session. Without this, switching tabs and coming back replays
/// the animation every time, which would feel laggy.
final class HiveTabAppearance {
    static let shared = HiveTabAppearance()
    var didAnimate = false
    private init() {}
}

#Preview {
    HiveTabView()
        .environment(ServiceContainer.preview())
}
