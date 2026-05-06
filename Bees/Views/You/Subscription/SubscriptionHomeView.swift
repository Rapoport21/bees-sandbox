import SwiftUI

struct SubscriptionHomeView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var showSwitchTier = false
    @State private var showCancelFlow = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    HStack {
                        Text(services.currentTier.displayName)
                            .font(BeesType.displayL)
                        Spacer()
                        Text(services.subscriptionStatus.displayName.uppercased())
                            .font(BeesType.captionS)
                            .tracking(0.6)
                            .padding(.horizontal, BeesSpacing.xs)
                            .padding(.vertical, 2)
                            .background(statusColor, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    Text("$\(format(services.currentTier.monthlyPrice))/month")
                        .font(BeesType.bodyL)
                        .foregroundStyle(BeesColors.charcoal600)

                    if let trialEnd = services.trialEndsAt, services.subscriptionStatus == .trial {
                        Text("Trial ends \(trialEnd, format: .dateTime.day().month(.abbreviated))")
                            .font(BeesType.captionM)
                            .foregroundStyle(BeesColors.amber500)
                    }
                }
                .padding(.vertical, BeesSpacing.xs)
            }

            Section {
                Button {
                    showSwitchTier = true
                } label: {
                    Label("Switch tier", systemImage: "arrow.left.arrow.right")
                        .foregroundStyle(BeesColors.charcoal900)
                }

                NavigationLink {
                    BillingHistoryView()
                } label: {
                    Label("Billing history", systemImage: "doc.text.fill")
                }

                NavigationLink {
                    PromoCodeView()
                } label: {
                    Label("Promo / referral code", systemImage: "tag.fill")
                }
            }

            if services.subscriptionStatus != .canceled {
                Section {
                    Button {
                        showCancelFlow = true
                    } label: {
                        Label("Cancel subscription", systemImage: "xmark.circle")
                            .foregroundStyle(BeesColors.error500)
                    }
                }
            } else {
                Section {
                    Button {
                        services.reactivateSubscription()
                    } label: {
                        Label("Reactivate", systemImage: "arrow.clockwise.circle.fill")
                            .foregroundStyle(BeesColors.honey500)
                    }
                }
            }
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSwitchTier) {
            SwitchTierView()
                .environment(services)
        }
        .fullScreenCover(isPresented: $showCancelFlow) {
            CancelSubscriptionFlow()
                .environment(services)
        }
    }

    private var statusColor: Color {
        switch services.subscriptionStatus {
        case .trial:    return BeesColors.amber500
        case .active:   return BeesColors.leaf500
        case .paused:   return BeesColors.charcoal600
        case .pastDue:  return BeesColors.error500
        case .canceled: return BeesColors.charcoal600
        }
    }

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}

struct PromoCodeView: View {
    @State private var code: String = ""
    @State private var applied = false

    var body: some View {
        Form {
            Section {
                TextField("Enter promo or referral code", text: $code)
                    .autocapitalization(.allCharacters)
                Button("Apply") { applied = true }
                    .disabled(code.isEmpty)
            } footer: {
                if applied {
                    Text("Code applied! It will appear on your next bill.")
                        .foregroundStyle(BeesColors.leaf500)
                } else {
                    Text("Get a free month for every friend who signs up.")
                }
            }

            Section("Your referral link") {
                HStack {
                    Text("bees.app/r/buzzy47")
                        .font(BeesType.monoM)
                        .foregroundStyle(BeesColors.charcoal600)
                    Spacer()
                    Button("Copy") { }
                }
                Button {
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("Promo & referral")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SubscriptionHomeView()
    }
    .environment(ServiceContainer.preview())
}
