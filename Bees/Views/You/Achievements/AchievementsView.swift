import SwiftUI

struct AchievementsView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var filter: Filter = .all

    enum Filter: String, CaseIterable, Identifiable {
        case all, earned, locked
        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: BeesSpacing.s)]

    var body: some View {
        ScrollView {
            VStack(spacing: BeesSpacing.l) {
                Picker("Filter", selection: $filter) {
                    ForEach(Filter.allCases) { filter in
                        Text(filter.displayName).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                LazyVGrid(columns: columns, spacing: BeesSpacing.s) {
                    ForEach(filtered) { achievement in
                        NavigationLink(value: achievement) {
                            AchievementBadge(achievement: achievement)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xl)
        }
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Achievement.self) { achievement in
            AchievementDetailView(achievement: achievement)
        }
    }

    private var filtered: [Achievement] {
        switch filter {
        case .all:    return services.achievementService.all
        case .earned: return services.achievementService.earned
        case .locked: return services.achievementService.locked
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: BeesSpacing.xs) {
            ZStack {
                Circle()
                    .fill(achievement.isEarned ? BeesColors.honey300 : BeesColors.charcoal300.opacity(0.3))
                    .frame(width: 80, height: 80)
                Image(systemName: achievement.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(achievement.isEarned ? BeesColors.charcoal900 : BeesColors.charcoal300)
            }
            Text(achievement.title)
                .font(BeesType.captionM.weight(.semibold))
                .foregroundStyle(achievement.isEarned ? BeesColors.charcoal900 : BeesColors.charcoal600)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 30)
        }
        .padding(BeesSpacing.s)
        .frame(maxWidth: .infinity)
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.md))
        .opacity(achievement.isEarned ? 1.0 : 0.7)
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
    .environment(ServiceContainer.preview())
}
