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
                                Text("N")
                                    .font(BeesType.headingM)
                                    .foregroundStyle(.white)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nick")
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
                    label("Achievements", icon: "trophy.fill")
                    label("Hive history", icon: "calendar")
                    label("Subscription", icon: "creditcard.fill")
                    label("Gifts sent", icon: "gift.fill")
                    label("Referral program", icon: "person.2.fill")
                }

                Section {
                    label("Settings", icon: "gearshape.fill")
                    label("Help & Support", icon: "questionmark.circle.fill")
                }
            }
            .navigationTitle("You")
        }
    }

    private func label(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .foregroundStyle(BeesColors.charcoal900)
    }
}

#Preview {
    YouTabView()
        .environment(ServiceContainer.preview())
}
