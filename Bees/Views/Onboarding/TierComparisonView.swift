import SwiftUI

struct TierComparisonView: View {
    @Binding var pickedTier: Tier
    var onContinue: () -> Void
    @State private var billingCycle: BillingCycle = .monthly

    enum BillingCycle: String, CaseIterable, Identifiable {
        case monthly, annual
        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: BeesSpacing.l) {
                header

                Picker("Billing", selection: $billingCycle) {
                    ForEach(BillingCycle.allCases) { cycle in
                        Text(cycle.displayName).tag(cycle)
                    }
                }
                .pickerStyle(.segmented)

                VStack(spacing: BeesSpacing.s) {
                    ForEach(Tier.allCases, id: \.self) { tier in
                        tierCard(tier)
                    }
                }
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xxl + BeesSpacing.l)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: BeesSpacing.xs) {
                Button("Start 7-day free trial of \(pickedTier.displayName)") { onContinue() }
                    .buttonStyle(.beesPrimary)
                Text("Cancel anytime")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s)
            .background(.regularMaterial)
        }
        .navigationTitle("Choose your hive plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            ForEach(["Live video of your hive",
                     "Real-time hive stats",
                     "Honey jars shipped to you",
                     "7-day free trial",
                     "Cancel anytime"], id: \.self) { text in
                HStack(spacing: BeesSpacing.s) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(BeesColors.honey500)
                    Text(text)
                        .font(BeesType.bodyM)
                        .foregroundStyle(BeesColors.charcoal900)
                }
            }
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
    }

    private func tierCard(_ tier: Tier) -> some View {
        let isSelected = pickedTier == tier
        return Button {
            withAnimation(.easeOut(duration: 0.2)) { pickedTier = tier }
        } label: {
            VStack(alignment: .leading, spacing: BeesSpacing.s) {
                HStack {
                    Text(tier.displayName)
                        .font(BeesType.headingM)
                        .foregroundStyle(BeesColors.charcoal900)
                    if tier == .forager {
                        Text("MOST POPULAR")
                            .font(BeesType.captionS)
                            .tracking(0.8)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BeesSpacing.xs)
                            .padding(.vertical, 2)
                            .background(BeesColors.honey500, in: Capsule())
                    }
                    Spacer()
                    Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                        .foregroundStyle(isSelected ? BeesColors.honey500 : BeesColors.charcoal300)
                        .font(.system(size: 22))
                }

                Text(priceText(for: tier))
                    .font(BeesType.displayL)
                    .foregroundStyle(BeesColors.charcoal900)

                VStack(alignment: .leading, spacing: BeesSpacing.xxs) {
                    ForEach(features(for: tier), id: \.self) { feature in
                        HStack(spacing: BeesSpacing.xs) {
                            Text("✓")
                                .foregroundStyle(BeesColors.leaf500)
                            Text(feature)
                                .font(BeesType.bodyM)
                                .foregroundStyle(BeesColors.charcoal900)
                        }
                    }
                }
            }
            .padding(BeesSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BeesRadius.lg)
                    .stroke(isSelected ? BeesColors.honey500 : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func priceText(for tier: Tier) -> String {
        switch billingCycle {
        case .monthly:
            return "$\(format(tier.monthlyPrice))/mo"
        case .annual:
            let annual = tier.monthlyPrice * 10
            return "$\(format(annual))/yr"
        }
    }

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private func features(for tier: Tier) -> [String] {
        switch tier {
        case .pollinator:
            return ["1 jar every 3 months", "Entrance camera", "8 sticker designs", "All hive stats"]
        case .forager:
            return ["1 jar every month", "All 3 cameras", "Custom sticker text", "Save 5 designs", "Clip recording"]
        case .queenKeeper:
            return ["2 jars every month", "All cameras + early access", "Exclusive seasonal stickers", "Painted hive name", "Sister hive option", "Annual bonus jar"]
        }
    }
}

#Preview {
    NavigationStack {
        TierComparisonView(pickedTier: .constant(.forager), onContinue: {})
    }
}
