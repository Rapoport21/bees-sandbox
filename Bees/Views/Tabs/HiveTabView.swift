import SwiftUI

struct HiveTabView: View {
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BeesSpacing.l) {
                    videoPlaceholder
                    hiveIdentityPill
                    statGrid
                    activityCard
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
        }
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

            NavigationLink(value: StatType.honey) {
                HoneyProductionCard(
                    honeyLb: snapshot.honeyEstimateLb,
                    jarTargetLb: 12,
                    jarsHarvested: 3,
                    weeklyDelta: 1.2
                )
            }
            .gridCellColumns(2)
        }
        .buttonStyle(.plain)
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
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            HStack(spacing: BeesSpacing.xs) {
                Text("🐝")
                Text("ACTIVITY RIGHT NOW")
                    .font(BeesType.captionM)
                    .tracking(1)
                    .foregroundStyle(BeesColors.charcoal600)
            }

            HStack(spacing: BeesSpacing.xl) {
                counter(label: "Take-offs", value: services.hiveService.activity.rollingTakeoffs, glyph: "↑")
                counter(label: "Landings", value: services.hiveService.activity.rollingLandings, glyph: "↓")
            }

            ProgressView(value: Double(services.hiveService.activity.takeoffsLast60s + services.hiveService.activity.landingsLast60s),
                         total: 60)
                .tint(BeesColors.honey500)

            Text("Last 60 seconds")
                .font(BeesType.captionS)
                .foregroundStyle(BeesColors.charcoal600)
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [BeesColors.surfaceWarmHighlight, BeesColors.surfaceMuted],
                           startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: BeesRadius.lg)
        )
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

#Preview {
    HiveTabView()
        .environment(ServiceContainer.preview())
}
