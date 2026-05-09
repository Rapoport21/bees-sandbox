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

                if let errorText {
                    Text(errorText)
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.error500)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xxl + BeesSpacing.l)
        }
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: BeesSpacing.xs) {
                Button(primaryCTAText) {
                    Task { await purchaseSelected() }
                }
                .buttonStyle(.beesPrimary)
                .disabled(isPurchasing)

                Text("Cancel anytime · 1-week free trial included")
                    .font(BeesType.captionM)
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
            .presentationCornerRadius(28)
        }
    }

    private var primaryCTAText: String {
        if let intro = introOfferText(for: pickedTier) {
            return "Start \(intro) of \(pickedTier.displayName)"
        }
        return "Subscribe to \(pickedTier.displayName)"
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            ForEach(["Live video of your hive",
                     "Real-time hive stats",
                     "Honey jars shipped to you",
                     "1-week free trial",
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
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
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
            .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BeesRadius.lg)
                    .stroke(isSelected ? BeesColors.honey500 : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    /// Pulls localized prices from the loaded StoreKit products. Falls
    /// back to the hardcoded `Tier.monthlyPrice` if products haven't
    /// loaded yet (first frame, no network, etc.) so the UI never
    /// shows blanks.
    private func priceText(for tier: Tier) -> String {
        let product = services.subscriptionService.product(for: tier)
        switch billingCycle {
        case .monthly:
            if let p = product { return "\(p.displayPrice)/mo" }
            return "$\(format(tier.monthlyPrice))/mo"
        case .annual:
            // Annual is a 2-month discount: monthly * 10. We don't yet
            // have annual products in the StoreKit config, so derive
            // from the displayed monthly price for visual consistency.
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

    @MainActor
    private func purchaseSelected() async {
        errorText = nil
        isPurchasing = true

        // Make sure products are loaded before attempting purchase.
        if services.subscriptionService.products.isEmpty {
            await services.subscriptionService.loadProducts()
        }

        // If StoreKit Configuration isn't active (CLI launch instead of
        // Xcode ⌘R, or running without registered App Store Connect
        // products), the products array stays empty. Apple's
        // `product.purchase()` would hang forever waiting on a server
        // response. Fall back to a mock confirm so the prototype always
        // completes — when launched via Xcode, the real path runs.
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
            // If transaction is nil the user cancelled Apple's sheet —
            // stay on this screen, no error.
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
