import SwiftUI

struct AchievementDetailView: View {
    let achievement: Achievement

    var body: some View {
        ScrollView {
            VStack(spacing: BeesSpacing.l) {
                ZStack {
                    Circle()
                        .fill(achievement.isEarned ? BeesColors.honey300 : BeesColors.charcoal300.opacity(0.3))
                        .frame(width: 140, height: 140)
                    Image(systemName: achievement.icon)
                        .font(.system(size: 56))
                        .foregroundStyle(achievement.isEarned ? BeesColors.charcoal900 : BeesColors.charcoal300)
                }
                .padding(.top, BeesSpacing.l)

                Text(achievement.title)
                    .font(BeesType.displayL)

                Text(rarityLabel)
                    .font(BeesType.captionS)
                    .tracking(1.5)
                    .foregroundStyle(rarityColor)
                    .padding(.horizontal, BeesSpacing.s)
                    .padding(.vertical, BeesSpacing.xxs)
                    .background(rarityColor.opacity(0.15), in: Capsule())

                Text(achievement.description)
                    .font(BeesType.bodyL)
                    .foregroundStyle(BeesColors.charcoal600)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BeesSpacing.l)

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    SectionHeader(title: "How to earn")
                    Text(achievement.criteria)
                        .font(BeesType.bodyM)
                        .foregroundStyle(BeesColors.charcoal900)
                }
                .padding(BeesSpacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.lg))

                if let earnedAt = achievement.earnedAt {
                    VStack(alignment: .leading, spacing: BeesSpacing.s) {
                        SectionHeader(title: "Earned")
                        Text(earnedAt, format: .dateTime.day().month(.wide).year())
                            .font(BeesType.bodyM)
                            .foregroundStyle(BeesColors.charcoal900)
                    }
                    .padding(BeesSpacing.m)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.lg))

                    Button {
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.beesSecondary)
                }
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xl)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var rarityLabel: String { achievement.rarity.displayName.uppercased() }
    private var rarityColor: Color {
        switch achievement.rarity {
        case .common:    return BeesColors.charcoal600
        case .rare:      return BeesColors.leaf500
        case .epic:      return BeesColors.amber500
        case .legendary: return BeesColors.honey500
        }
    }
}

#Preview {
    NavigationStack {
        AchievementDetailView(achievement: Fixtures.demoAchievements[0])
    }
}
