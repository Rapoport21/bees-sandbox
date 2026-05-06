import SwiftUI

struct SwitchTierView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: Tier

    init() {
        _selectedTier = State(initialValue: .forager)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BeesSpacing.s) {
                    ForEach(Tier.allCases, id: \.self) { tier in
                        tierRow(tier)
                    }

                    if isUpgrade {
                        Text("Effective immediately. You'll be charged the prorated difference.")
                            .font(BeesType.captionM)
                            .foregroundStyle(BeesColors.charcoal600)
                            .padding(.top, BeesSpacing.s)
                    } else if isDowngrade {
                        Text("Effective next billing cycle. You'll keep current features until then.")
                            .font(BeesType.captionM)
                            .foregroundStyle(BeesColors.charcoal600)
                            .padding(.top, BeesSpacing.s)
                    }
                }
                .padding(BeesSpacing.m)
            }
            .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
            .navigationTitle("Switch tier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .tint(BeesColors.charcoal600)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(ctaText) {
                    services.switchTier(selectedTier)
                    dismiss()
                }
                .buttonStyle(.beesPrimary)
                .disabled(selectedTier == services.currentTier)
                .padding(.horizontal, BeesSpacing.m)
                .padding(.vertical, BeesSpacing.s)
                .background(.regularMaterial)
            }
            .onAppear { selectedTier = services.currentTier }
        }
    }

    private var isUpgrade: Bool {
        tierIndex(selectedTier) > tierIndex(services.currentTier)
    }

    private var isDowngrade: Bool {
        tierIndex(selectedTier) < tierIndex(services.currentTier)
    }

    private var ctaText: String {
        if selectedTier == services.currentTier { return "Confirm" }
        return isUpgrade ? "Upgrade to \(selectedTier.displayName)" : "Downgrade to \(selectedTier.displayName)"
    }

    private func tierRow(_ tier: Tier) -> some View {
        let isSelected = selectedTier == tier
        let isCurrent = services.currentTier == tier
        return Button {
            withAnimation(.easeOut(duration: 0.2)) { selectedTier = tier }
        } label: {
            VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                HStack {
                    Text(tier.displayName)
                        .font(BeesType.headingM)
                    if isCurrent {
                        Text("CURRENT")
                            .font(BeesType.captionS)
                            .tracking(0.8)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BeesSpacing.xs)
                            .padding(.vertical, 2)
                            .background(BeesColors.charcoal600, in: Capsule())
                    }
                    Spacer()
                    Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                        .foregroundStyle(isSelected ? BeesColors.honey500 : BeesColors.charcoal300)
                }
                Text("$\(format(tier.monthlyPrice))/month")
                    .font(BeesType.bodyL)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            .padding(BeesSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BeesRadius.lg)
                    .stroke(isSelected ? BeesColors.honey500 : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func tierIndex(_ tier: Tier) -> Int {
        switch tier {
        case .pollinator:  return 0
        case .forager:     return 1
        case .queenKeeper: return 2
        }
    }

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}

#Preview {
    SwitchTierView()
        .environment(ServiceContainer.preview())
}
