import SwiftUI

struct HiveTabView: View {
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BeesSpacing.l) {
                    videoPlaceholder
                    hiveIdentityPill
                    statStrip
                    activityCard
                    quickActions
                }
                .padding(.horizontal, BeesSpacing.m)
                .padding(.bottom, BeesSpacing.xl)
            }
            .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
            .navigationTitle("Hive")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: StatType.self) { stat in
                StatDetailView(stat: stat)
            }
        }
    }

    private var videoPlaceholder: some View {
        ZStack {
            if let url = BundledVideo.firstAvailable() {
                LoopingVideoPlayer(url: url)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: BeesRadius.lg))
            } else {
                RoundedRectangle(cornerRadius: BeesRadius.lg)
                    .fill(BeesColors.charcoal900)
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: BeesSpacing.s) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(BeesColors.honey500)
                            Text("Live video — entrance cam")
                                .font(BeesType.bodyM)
                                .foregroundStyle(.white.opacity(0.8))
                            Text("Drop a video into Bees/Videos/ to test")
                                .font(BeesType.captionM)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    )
            }

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

    private var statStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BeesSpacing.s) {
                NavigationLink(value: StatType.temperature) {
                    StatTile(icon: StatType.temperature.iconName,
                             value: String(format: "%.0f", services.hiveService.current.temperatureF),
                             unit: "°F", trend: .up)
                }
                NavigationLink(value: StatType.humidity) {
                    StatTile(icon: StatType.humidity.iconName,
                             value: String(format: "%.0f", services.hiveService.current.humidityPct),
                             unit: "%", trend: .flat)
                }
                NavigationLink(value: StatType.weight) {
                    StatTile(icon: StatType.weight.iconName,
                             value: String(format: "%.1f", services.hiveService.current.weightLb),
                             unit: "lb", trend: .up)
                }
                NavigationLink(value: StatType.population) {
                    StatTile(icon: StatType.population.iconName,
                             value: "\(services.hiveService.current.populationEstimate / 1000)k",
                             unit: "BEES", trend: .up)
                }
                NavigationLink(value: StatType.takeoffs) {
                    StatTile(icon: StatType.takeoffs.iconName,
                             value: format(services.hiveService.current.takeoffsLast24h),
                             unit: "OUT", trend: .up)
                }
                NavigationLink(value: StatType.landings) {
                    StatTile(icon: StatType.landings.iconName,
                             value: format(services.hiveService.current.landingsLast24h),
                             unit: "IN", trend: .up)
                }
                NavigationLink(value: StatType.sound) {
                    StatTile(icon: StatType.sound.iconName,
                             value: services.hiveService.current.soundLevel.displayName.prefix(4).uppercased(),
                             unit: "SND", trend: .flat)
                }
            }
            .buttonStyle(.plain)
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
            LinearGradient(colors: [BeesColors.honey100, BeesColors.comb500],
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

    private var quickActions: some View {
        HStack(spacing: BeesSpacing.s) {
            Button { } label: {
                Label("Full stats", systemImage: "chart.line.uptrend.xyaxis")
            }
            .buttonStyle(.beesSecondary)

            Button { } label: {
                Label("Compare", systemImage: "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.beesSecondary)
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
