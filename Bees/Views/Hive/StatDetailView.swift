import SwiftUI
import Charts

struct StatDetailView: View {
    let stat: StatType
    @Environment(ServiceContainer.self) private var services
    @State private var selectedRange: TimeRange = .day
    @State private var educationalExpanded = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BeesSpacing.l) {
                heroBlock
                rangeSelector
                chart
                educationalSection
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xl)
        }
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .navigationTitle(stat.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroBlock: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: BeesSpacing.xs) {
                Text(currentValueText)
                    .font(BeesType.displayXL)
                    .foregroundStyle(BeesColors.charcoal900)
                    .contentTransition(.numericText())
                Text(stat.unit)
                    .font(BeesType.displayM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            HStack(spacing: BeesSpacing.xs) {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(BeesColors.leaf500)
                Text(trendText)
                    .font(BeesType.bodyM)
                    .foregroundStyle(BeesColors.charcoal900)
            }
            Text("Last reading: just now")
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
        }
        .padding(.top, BeesSpacing.m)
    }

    private var rangeSelector: some View {
        Picker("Range", selection: $selectedRange) {
            ForEach(TimeRange.allCases) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    private var chart: some View {
        let points = Fixtures.chartSamplePoints(stat: stat, range: selectedRange)
        return Chart(points) { point in
            LineMark(
                x: .value("Time", point.date),
                y: .value(stat.displayName, point.value)
            )
            .foregroundStyle(BeesColors.honey500)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Time", point.date),
                y: .value(stat.displayName, point.value)
            )
            .foregroundStyle(LinearGradient(
                colors: [BeesColors.honey500.opacity(0.25), BeesColors.honey500.opacity(0)],
                startPoint: .top, endPoint: .bottom))
            .interpolationMethod(.catmullRom)
        }
        .frame(height: 240)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding(BeesSpacing.s)
        .background(BeesColors.comb500.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: BeesRadius.lg))
    }

    private var educationalSection: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    educationalExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("What is \(stat.displayName.lowercased())?")
                        .font(BeesType.headingM)
                        .foregroundStyle(BeesColors.charcoal900)
                    Spacer()
                    Image(systemName: educationalExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(BeesColors.charcoal600)
                }
            }
            .buttonStyle(.plain)

            if educationalExpanded {
                Text(stat.explanation)
                    .font(BeesType.bodyL)
                    .foregroundStyle(BeesColors.charcoal600)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(BeesSpacing.m)
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
    }

    private var currentValueText: String {
        let snapshot = services.hiveService.current
        switch stat {
        case .temperature: return String(format: "%.0f", snapshot.temperatureF)
        case .humidity:    return String(format: "%.0f", snapshot.humidityPct)
        case .weight:      return String(format: "%.1f", snapshot.weightLb)
        case .population:  return "\(snapshot.populationEstimate / 1000)k"
        case .takeoffs:    return "\(snapshot.takeoffsLast24h)"
        case .landings:    return "\(snapshot.landingsLast24h)"
        case .sound:       return snapshot.soundLevel.displayName
        }
    }

    private var trendText: String {
        switch stat {
        case .temperature: return "Up 2° vs last hour"
        case .humidity:    return "Steady today"
        case .weight:      return "Up 0.3 lb this week"
        case .population:  return "Growing"
        case .takeoffs:    return "Active week"
        case .landings:    return "Tracks take-offs closely"
        case .sound:       return "Calm"
        }
    }
}

#Preview {
    NavigationStack {
        StatDetailView(stat: .temperature)
    }
    .environment(ServiceContainer.preview())
}
