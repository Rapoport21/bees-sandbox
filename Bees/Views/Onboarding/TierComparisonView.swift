import SwiftUI
import StoreKit

struct TierComparisonView: View {
    @Binding var pickedTier: Tier
    var onContinue: () -> Void

    @Environment(ServiceContainer.self) private var services
    @State private var billingCycle: BillingCycle = .monthly
    @State private var isPurchasing = false
    @State private var errorText: String?
    @State private var showMockConfirm = false

    enum BillingCycle: String, CaseIterable, Identifiable {
        case monthly, annual
        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }

    var body: some View {
        VStack(spacing: BeesSpacing.m) {
            titleBlock
                .padding(.top, BeesSpacing.s)

            Picker("Billing", selection: $billingCycle) {
                ForEach(BillingCycle.allCases) { cycle in
                    Text(cycle.displayName).tag(cycle)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, BeesSpacing.m)

            VStack(spacing: BeesSpacing.s) {
                ForEach(Tier.allCases, id: \.self) { tier in
                    tierCard(tier)
                }
            }
            .padding(.horizontal, BeesSpacing.m)

            if let errorText {
                Text(errorText)
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.error500)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BeesSpacing.m)
            }

            Spacer(minLength: 0)
        }
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: BeesSpacing.xxs) {
                Button(primaryCTAText) {
                    let h = UIImpactFeedbackGenerator(style: .medium)
                    h.impactOccurred()
                    Task { await purchaseSelected() }
                }
                .buttonStyle(.beesPrimary)
                .disabled(isPurchasing)

                Text("Cancel anytime · 1-week free trial included")
                    .font(BeesType.captionS)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s)
            .background(.regularMaterial)
        }
        .navigationTitle("Choose your hive plan")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isPurchasing {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView("Connecting to App Store…")
                        .padding(BeesSpacing.l)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
                }
            }
        }
        .task { await services.subscriptionService.loadProducts() }
        .sheet(isPresented: $showMockConfirm) {
            ApplePaymentSheet(
                appName: "Bees",
                tierName: pickedTier.displayName,
                priceText: priceText(for: pickedTier),
                trialText: "1 week free",
                renewalText: "Then \(priceText(for: pickedTier))",
                onSuccess: {
                    showMockConfirm = false
                    onContinue()
                },
                onCancel: { showMockConfirm = false }
            )
            .presentationDetents([.fraction(0.78)])
            .presentationDragIndicator(.hidden)
        }
    }

    private var primaryCTAText: String {
        if let intro = introOfferText(for: pickedTier) {
            return "Start \(intro) of \(pickedTier.displayName)"
        }
        return "Subscribe to \(pickedTier.displayName)"
    }

    private var titleBlock: some View {
        VStack(spacing: BeesSpacing.xxs) {
            Text("Choose your plan")
                .font(BeesType.displayM)
                .foregroundStyle(BeesColors.charcoal900)
            Text("Live video, real-time stats, custom-stickered honey jars.")
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeesSpacing.m)
        }
    }

    private func tierCard(_ tier: Tier) -> some View {
        let isSelected = pickedTier == tier
        let isPopular = tier == .forager
        return Button {
            let h = UIImpactFeedbackGenerator(style: .light)
            h.impactOccurred()
            withAnimation(.easeOut(duration: 0.2)) { pickedTier = tier }
        } label: {
            VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(tier.displayName)
                        .font(BeesType.headingM)
                        .foregroundStyle(BeesColors.charcoal900)
                    if isPopular {
                        Text("MOST POPULAR")
                            .font(BeesType.captionS)
                            .tracking(0.6)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BeesSpacing.xs)
                            .padding(.vertical, 2)
                            .background(BeesColors.honey500, in: Capsule())
                    }
                    Spacer()
                    Text(priceText(for: tier))
                        .font(BeesType.headingM.weight(.semibold))
                        .foregroundStyle(BeesColors.charcoal900)
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? BeesColors.honey500 : BeesColors.charcoal300)
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    ForEach(features(for: tier), id: \.self) { feature in
                        HStack(spacing: BeesSpacing.xxs) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(BeesColors.leaf500)
                            Text(feature)
                                .font(BeesType.captionM)
                                .foregroundStyle(BeesColors.charcoal600)
                        }
                    }
                }
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s + 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BeesRadius.lg)
                    .stroke(isSelected ? BeesColors.honey500 : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    /// Pulls localized prices from loaded StoreKit products. Falls back
    /// to the hardcoded `Tier.monthlyPrice` when products haven't loaded.
    private func priceText(for tier: Tier) -> String {
        let product = services.subscriptionService.product(for: tier)
        switch billingCycle {
        case .monthly:
            if let p = product { return "\(p.displayPrice)/mo" }
            return "$\(format(tier.monthlyPrice))/mo"
        case .annual:
            // Annual = 2-month discount: monthly * 10. No annual SKU
            // yet; derived for now.
            let annual = tier.monthlyPrice * 10
            return "$\(format(annual))/yr"
        }
    }

    private func introOfferText(for tier: Tier) -> String? {
        guard let product = services.subscriptionService.product(for: tier),
              let intro = product.subscription?.introductoryOffer else { return nil }
        switch intro.paymentMode {
        case .freeTrial:
            return periodText(intro.period) + " free"
        case .payAsYouGo, .payUpFront:
            return "intro offer"
        default:
            return nil
        }
    }

    private func periodText(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:   return "\(period.value)-day"
        case .week:  return "\(period.value)-week"
        case .month: return "\(period.value)-month"
        case .year:  return "\(period.value)-year"
        @unknown default: return "trial"
        }
    }

    private func format(_ value: Decimal) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    /// Three top differentiators per tier — keeps cards short enough
    /// that all three fit above the fold on iPhone 14+ class devices.
    private func features(for tier: Tier) -> [String] {
        switch tier {
        case .pollinator:
            return [
                "1 jar every 3 months",
                "Entrance camera",
                "All hive stats"
            ]
        case .forager:
            return [
                "1 jar every month",
                "All 3 cameras + clip recording",
                "Custom sticker text · 5 saved designs"
            ]
        case .queenKeeper:
            return [
                "2 jars/month + annual bonus jar",
                "Painted hive name · sister hive option",
                "All cameras + early access"
            ]
        }
    }

    @MainActor
    private func purchaseSelected() async {
        errorText = nil
        isPurchasing = true

        if services.subscriptionService.products.isEmpty {
            await services.subscriptionService.loadProducts()
        }

        guard !services.subscriptionService.products.isEmpty else {
            isPurchasing = false
            showMockConfirm = true
            return
        }

        do {
            let transaction = try await services.subscriptionService.purchase(pickedTier)
            isPurchasing = false
            if transaction != nil {
                onContinue()
            }
        } catch {
            isPurchasing = false
            errorText = "Couldn't complete purchase: \(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        TierComparisonView(pickedTier: .constant(.forager), onContinue: {})
            .environment(ServiceContainer.preview())
    }
}
