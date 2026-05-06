import SwiftUI

struct YouTabView: View {
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: BeesSpacing.m) {
                        Circle()
                            .fill(BeesColors.honey300)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Text(services.authService.displayName.prefix(1).uppercased())
                                    .font(BeesType.headingM)
                                    .foregroundStyle(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(services.authService.displayName)
                                .font(BeesType.headingM)
                            Text(services.hiveService.hive.name)
                                .font(BeesType.captionM)
                                .foregroundStyle(BeesColors.charcoal600)
                        }
                        Spacer()
                        Text(services.currentTier.displayName)
                            .font(BeesType.captionS)
                            .padding(.horizontal, BeesSpacing.xs)
                            .padding(.vertical, BeesSpacing.xxs)
                            .background(BeesColors.honey300, in: Capsule())
                    }
                    .padding(.vertical, BeesSpacing.xs)
                }

                Section {
                    NavigationLink { AchievementsView() } label: {
                        Label("Achievements", systemImage: "trophy.fill")
                    }
                    NavigationLink { HiveHistoryView() } label: {
                        Label("Hive history", systemImage: "calendar")
                    }
                    NavigationLink { SubscriptionHomeView() } label: {
                        Label("Subscription", systemImage: "creditcard.fill")
                    }
                    NavigationLink { GiftsSentView() } label: {
                        Label("Gifts sent", systemImage: "gift.fill")
                    }
                    NavigationLink { PromoCodeView() } label: {
                        Label("Referral program", systemImage: "person.2.fill")
                    }
                }

                Section {
                    NavigationLink { SettingsHomeView() } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    NavigationLink { HelpSupportView() } label: {
                        Label("Help & Support", systemImage: "questionmark.circle.fill")
                    }
                }

                Section {
                    Picker(selection: Binding(
                        get: { services.onboardingVariant },
                        set: { services.onboardingVariant = $0 }
                    )) {
                        ForEach(OnboardingVariant.allCases) { variant in
                            Text(variant.displayName).tag(variant)
                        }
                    } label: {
                        Label("Onboarding intro", systemImage: "rectangle.stack.fill")
                            .foregroundStyle(BeesColors.charcoal900)
                    }

                    Button {
                        services.resetOnboarding()
                    } label: {
                        Label("Replay onboarding", systemImage: "arrow.clockwise")
                            .foregroundStyle(BeesColors.charcoal900)
                    }
                    Button {
                        services.authService.signOut()
                    } label: {
                        Label("Sign out (re-enter intro)", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(BeesColors.charcoal900)
                    }
                } header: {
                    Text("Developer · A/B")
                } footer: {
                    Text("Switch the intro variant, then sign out to walk through the chosen flow from the top.")
                }
            }
            .navigationTitle("You")
        }
    }
}

struct HiveHistoryView: View {
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        ScrollView {
            VStack(spacing: BeesSpacing.l) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BeesSpacing.s) {
                    statCard(value: "92", label: "Days as adopter")
                    statCard(value: "47.2 lb", label: "Total weight")
                    statCard(value: "12k+", label: "Bees observed")
                    statCard(value: "3", label: "Jars received")
                }
            }
            .padding(BeesSpacing.m)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .navigationTitle("Hive history")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: BeesSpacing.xs) {
            Text(value)
                .font(BeesType.displayL)
                .foregroundStyle(BeesColors.honey500)
            Text(label)
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
    }
}

struct GiftsSentView: View {
    var body: some View {
        ContentUnavailableView {
            Label("No gifts yet", systemImage: "gift")
        } description: {
            Text("Gifts you send appear here.")
        }
        .navigationTitle("Gifts sent")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    YouTabView()
        .environment(ServiceContainer.preview())
}
