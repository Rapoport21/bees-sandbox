import SwiftUI

/// Editorial-farmhouse Hive tab. Reads as a page from a beekeeper's
/// daily log: big serif hive name, a single warm narrative summary
/// of the day, then quiet stat tiles, then honey-jar journey, then
/// a narrative activity reading. No emoji. No fake-data sparklines.
/// Stats are stories, not surveillance (see CLAUDE.md design context).
struct HiveTabView: View {
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BeesSpacing.l) {
                    videoPlaceholder
                    hiveIdentityHeader
                    todaysReading
                    statGrid
                    honeyProductionTile
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

    // MARK: - Video

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

    // MARK: - Identity header (big Calistoga hive name, italic farm caption)

    private var hiveIdentityHeader: some View {
        HStack(alignment: .top, spacing: BeesSpacing.s) {
            VStack(alignment: .leading, spacing: 2) {
                Text(services.hiveService.hive.name)
                    .font(BeesType.displayL)  // Calistoga 34pt
                    .foregroundStyle(BeesColors.charcoal900)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                (Text(services.hiveService.hive.farmName)
                    .italic()
                 + Text("  ·  \(services.hiveService.hive.farmLocation)"))
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
                    .lineLimit(2)
                    .padding(.top, BeesSpacing.xxs)
            }
            Spacer()
            HealthPill(health: services.hiveService.current.health)
                .padding(.top, BeesSpacing.xs)
        }
    }

    // MARK: - Today's reading (narrative summary card)

    private var todaysReading: some View {
        let snap = services.hiveService.current
        return VStack(alignment: .leading, spacing: BeesSpacing.xs) {
            Text("TODAY")
                .font(BeesType.captionS)
                .tracking(1.2)
                .foregroundStyle(BeesColors.honey500)
            Text(narrativeReading(snapshot: snap))
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal900)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BeesColors.surfaceWarmHighlight, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
    }

    private func narrativeReading(snapshot: HiveSnapshot) -> String {
        let temp = Int(snapshot.temperatureF.rounded())
        let pop = snapshot.populationEstimate / 1000
        let healthDescriptor: String = {
            switch snapshot.health {
            case .thriving: return "thriving"
            case .steady:   return "steady"
            case .watch:    return "worth watching"
            case .alert:    return "asking for attention"
            case .dormant:  return "dormant"
            }
        }()
        return "\(timeOfDay.narrativePrefix) your hive is \(healthDescriptor) — about \(pop)k bees, \(temp)°F at the entrance."
    }

    // MARK: - Time-of-day awareness (the hive is alive)

    private var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<8:   return .dawn
        case 8..<12:  return .morning
        case 12..<16: return .midday
        case 16..<19: return .lateAfternoon
        case 19..<22: return .evening
        default:      return .night
        }
    }

    enum TimeOfDay {
        case dawn, morning, midday, lateAfternoon, evening, night

        /// Sentence-leading prefix for the today narrative.
        var narrativePrefix: String {
            switch self {
            case .dawn:           return "This morning,"
            case .morning:        return "This morning,"
            case .midday:         return "This afternoon,"
            case .lateAfternoon:  return "This afternoon,"
            case .evening:        return "Tonight,"
            case .night:          return "Tonight,"
            }
        }
    }

    // MARK: - Stat grid (quieter, no decoration)

    private var statGrid: some View {
        let snapshot = services.hiveService.current
        let columns = [
            GridItem(.flexible(), spacing: BeesSpacing.s),
            GridItem(.flexible(), spacing: BeesSpacing.s),
        ]
        return LazyVGrid(columns: columns, spacing: BeesSpacing.s) {
            NavigationLink(value: StatType.temperature) {
                HiveStatCard(
                    title: "TEMPERATURE",
                    value: String(format: "%.0f", snapshot.temperatureF),
                    unit: "°F"
                )
            }
            NavigationLink(value: StatType.humidity) {
                HiveStatCard(
                    title: "HUMIDITY",
                    value: String(format: "%.0f", snapshot.humidityPct),
                    unit: "%"
                )
            }
            NavigationLink(value: StatType.weight) {
                HiveStatCard(
                    title: "WEIGHT",
                    value: String(format: "%.1f", snapshot.weightLb),
                    unit: "lb"
                )
            }
            NavigationLink(value: StatType.population) {
                HiveStatCard(
                    title: "POPULATION",
                    value: "\(snapshot.populationEstimate / 1000)k",
                    unit: "bees"
                )
            }
        }
        .buttonStyle(.pressable)
    }

    // MARK: - Honey production tile (kept rich — it's the hero stat)

    private var honeyProductionTile: some View {
        NavigationLink(value: StatType.honey) {
            HoneyProductionCard(
                honeyLb: services.hiveService.current.honeyEstimateLb,
                jarTargetLb: 12,
                jarsHarvested: 3,
                weeklyDelta: 1.2
            )
        }
        .buttonStyle(.pressable)
    }

    // MARK: - Activity card (narrative + ribbon, no gauge UI)

    private var activityCard: some View {
        let activity = services.hiveService.activity
        let last60 = activity.takeoffsLast60s + activity.landingsLast60s
        return VStack(alignment: .leading, spacing: BeesSpacing.s) {
            Text("AT THE ENTRANCE")
                .font(BeesType.captionS)
                .tracking(1.2)
                .foregroundStyle(BeesColors.honey500)

            Text(activityNarration(last60: last60))
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal900)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)

            HStack(spacing: BeesSpacing.xl) {
                counter(label: "Out today",
                        value: activity.rollingTakeoffs)
                counter(label: "Back today",
                        value: activity.rollingLandings)
            }
            .padding(.top, BeesSpacing.xs)

            activityRibbon(last60: last60)
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BeesRadius.lg)
                .stroke(BeesColors.charcoal300.opacity(0.18), lineWidth: 0.5)
        )
    }

    /// Beekeeper-voice narration that varies with both activity level
    /// and time of day. A real hive at 2am is quiet; at noon on a
    /// warm day, it's at peak. Static "busy" copy 24/7 reads as fake
    /// — this makes the dashboard feel like a real living thing.
    private func activityNarration(last60: Int) -> String {
        switch timeOfDay {
        case .night:
            return "Quiet hive. Most bees are inside, regulating temperature."

        case .dawn:
            return last60 < 4
                ? "Just waking up. Foragers warming their wings."
                : "Early start — scouts already heading out."

        case .morning:
            switch last60 {
            case 0...3:   return "Slow morning at the entrance. The first foragers haven't left yet."
            case 4...10:  return "Steady morning flow. Foragers heading to the field."
            case 11...20: return "Busy morning — lots of takeoffs."
            default:      return "Peak morning traffic. Foragers in full swing."
            }

        case .midday:
            switch last60 {
            case 0...3:   return "Quiet at the entrance — a midday lull."
            case 4...10:  return "Steady midday flow."
            case 11...20: return "Busy at the entrance — peak foraging hours."
            default:      return "Peak traffic. The hive is having a moment."
            }

        case .lateAfternoon:
            return last60 < 6
                ? "Slowing down. A few late returners coming in."
                : "Foragers returning, packed with pollen."

        case .evening:
            return last60 < 4
                ? "Settling for the night. Last bees coming home."
                : "Last few foragers headed home before dark."
        }
    }

    private func counter(label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(format(value))
                .font(BeesType.displayM)  // Calistoga 26pt
                .foregroundStyle(BeesColors.charcoal900)
                .contentTransition(.numericText())
            Text(label)
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
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
                    .animation(BeesAnimation.easeOut(0.6), value: pct)
            }
        }
        .frame(height: 6)
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
