import SwiftUI

struct HoneyHomeView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var path: [HoneyDestination] = []
    @State private var giftFlowOpen = false

    enum HoneyDestination: Hashable { case customizer }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: BeesSpacing.l) {
                    if let active = services.shipmentService.activeShipment {
                        heroCard(for: active)
                        timeline(for: active)
                    } else {
                        emptyHero
                    }

                    if services.currentTier.canSaveFavorites {
                        savedStickersShortcut
                    }

                    extrasCard
                    if services.currentTier.canSendGifts {
                        giftCard
                    }
                    historyRow
                    manageRow
                }
                .padding(.horizontal, BeesSpacing.m)
                .padding(.bottom, BeesSpacing.xl)
            }
            .background(BeesColors.surfacePage.ignoresSafeArea())
            .navigationTitle("Honey")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .tint(BeesColors.honey500)
                }
            }
            .navigationDestination(for: HoneyDestination.self) { dest in
                switch dest {
                case .customizer:
                    JarStudioView()
                        .environment(services)
                }
            }
            .fullScreenCover(isPresented: $giftFlowOpen) {
                GiftFlow()
                    .environment(services)
            }
        }
    }

    private func heroCard(for shipment: Shipment) -> some View {
        VStack(alignment: .leading, spacing: BeesSpacing.m) {
            HStack(alignment: .top, spacing: BeesSpacing.m) {
                JarPreview(design: shipment.design, size: 130)
                    .frame(width: 130, height: 130 * 1.4)

                VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                    statusBadge(shipment.status)
                    Text(headline(for: shipment))
                        .font(BeesType.displayM)
                        .foregroundStyle(BeesColors.charcoal900)
                    Text(subheadline(for: shipment))
                        .font(BeesType.bodyM)
                        .foregroundStyle(BeesColors.charcoal600)
                }
            }

            Button(primaryCTA(for: shipment)) {
                if shipment.status == .customizing || shipment.status == .approachingLock {
                    path.append(.customizer)
                } else if shipment.status == .shipped || shipment.status == .outForDelivery {
                    // would open tracker
                } else {
                    services.shipmentService.advanceStateForDemo()
                }
            }
            .buttonStyle(.beesPrimary)
        }
        .padding(BeesSpacing.m)
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
        .shadow(color: BeesColors.shadowWarm.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private func timeline(for shipment: Shipment) -> some View {
        let steps: [(label: String, status: Shipment.Status)] = [
            ("Customize", .customizing),
            ("Lock",      .locked),
            ("Pack",      .preparing),
            ("Ship",      .shipped),
            ("Land",      .delivered),
        ]

        return HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                let activeIndex = stepIndex(for: shipment.status)
                let isActive = index <= activeIndex
                Circle()
                    .fill(isActive ? BeesColors.honey500 : BeesColors.charcoal300)
                    .frame(width: 10, height: 10)

                if index < steps.count - 1 {
                    Rectangle()
                        .fill(index < activeIndex ? BeesColors.honey500 : BeesColors.charcoal300)
                        .frame(height: 2)
                }
            }
        }
        .overlay(alignment: .bottom) {
            HStack(spacing: 0) {
                ForEach(steps, id: \.label) { step in
                    Text(step.label)
                        .font(BeesType.captionS)
                        .foregroundStyle(BeesColors.charcoal600)
                        .frame(maxWidth: .infinity)
                }
            }
            .offset(y: 20)
        }
        .padding(.bottom, BeesSpacing.l)
    }

    private var savedStickersShortcut: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            SectionHeader(title: "Saved stickers",
                          trailing: "\(services.stickerService.savedStickers.count) of \(services.stickerService.maxSaved)")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BeesSpacing.s) {
                    ForEach(services.stickerService.savedStickers) { saved in
                        VStack(spacing: BeesSpacing.xxs) {
                            JarPreview(design: saved.design, size: 80)
                                .frame(width: 80, height: 110)
                            Text(saved.nickname)
                                .font(BeesType.captionS)
                                .foregroundStyle(BeesColors.charcoal600)
                                .lineLimit(1)
                        }
                    }
                    if services.stickerService.savedStickers.isEmpty {
                        Text("Tap ❤️ in the customizer to save designs.")
                            .font(BeesType.captionM)
                            .foregroundStyle(BeesColors.charcoal600)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var extrasCard: some View {
        sideCard(
            icon: "plus.circle.fill",
            title: "Buy extra jars",
            subtitle: "Add a jar to this shipment or send anytime"
        )
    }

    private var giftCard: some View {
        Button {
            giftFlowOpen = true
        } label: {
            HStack(spacing: BeesSpacing.m) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(BeesColors.honey500)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Send a gift")
                        .font(BeesType.headingM)
                        .foregroundStyle(BeesColors.charcoal900)
                    Text("Send honey to someone you love")
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.charcoal600)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(BeesColors.charcoal300)
            }
            .padding(BeesSpacing.m)
            .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.md))
        }
        .buttonStyle(.plain)
    }

    private var historyRow: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            SectionHeader(title: "Recent shipments", trailing: "View all →")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BeesSpacing.s) {
                    ForEach(services.shipmentService.history) { ship in
                        VStack(spacing: BeesSpacing.xxs) {
                            JarPreview(design: ship.design, size: 80)
                                .frame(width: 80, height: 110)
                            Text(monthYear(ship.scheduledShipDate))
                                .font(BeesType.captionS)
                                .foregroundStyle(BeesColors.charcoal600)
                        }
                    }
                }
            }
        }
    }

    private var manageRow: some View {
        Button {
        } label: {
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundStyle(BeesColors.charcoal600)
                Text("Manage shipments (skip / pause)")
                    .font(BeesType.bodyM)
                    .foregroundStyle(BeesColors.charcoal600)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(BeesColors.charcoal300)
            }
            .padding(BeesSpacing.m)
            .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.md))
        }
        .buttonStyle(.plain)
    }

    private var emptyHero: some View {
        VStack(spacing: BeesSpacing.m) {
            Image(systemName: "drop.fill")
                .font(.system(size: 48))
                .foregroundStyle(BeesColors.honey500)
            Text("Your first jar is on the way")
                .font(BeesType.displayM)
            Text("We'll let you know when it's time to customize.")
                .font(BeesType.bodyM)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
        }
        .padding(BeesSpacing.l)
        .frame(maxWidth: .infinity)
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
    }

    private func sideCard(icon: String, title: String, subtitle: String) -> some View {
        Button { } label: {
            HStack(spacing: BeesSpacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(BeesColors.honey500)
                    .frame(width: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(BeesType.headingM)
                        .foregroundStyle(BeesColors.charcoal900)
                    Text(subtitle)
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.charcoal600)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(BeesColors.charcoal300)
            }
            .padding(BeesSpacing.m)
            .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.md))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func statusBadge(_ status: Shipment.Status) -> some View {
        let (bg, fg): (Color, Color) = {
            switch status {
            case .customizing, .approachingLock: return (BeesColors.honey300, BeesColors.charcoal900)
            case .locked, .preparing:            return (BeesColors.charcoal300, BeesColors.charcoal900)
            case .shipped, .outForDelivery:      return (BeesColors.leaf500, .white)
            case .delivered:                     return (BeesColors.honey500, .white)
            case .delayed, .lost:                return (BeesColors.error500, .white)
            }
        }()
        return Text(status.displayName.uppercased())
            .font(BeesType.captionS)
            .tracking(0.6)
            .foregroundStyle(fg)
            .padding(.horizontal, BeesSpacing.xs)
            .padding(.vertical, BeesSpacing.xxs)
            .background(bg, in: Capsule())
    }

    private func headline(for shipment: Shipment) -> String {
        switch shipment.status {
        case .customizing, .approachingLock: return "Customize your sticker"
        case .locked:                        return "Locked & ready"
        case .preparing:                     return "Packing your jar"
        case .shipped:                       return "On its way"
        case .outForDelivery:                return "Arriving today"
        case .delivered:                     return "Delivered"
        case .delayed:                       return "Slight delay"
        case .lost:                          return "We're investigating"
        }
    }

    private func subheadline(for shipment: Shipment) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        switch shipment.status {
        case .customizing:
            return "Locks \(formatter.string(from: shipment.lockInDate)) · Ships \(formatter.string(from: shipment.scheduledShipDate))"
        case .approachingLock:
            return "Locks soon · Don't forget"
        case .locked, .preparing:
            return "Ships \(formatter.string(from: shipment.scheduledShipDate))"
        case .shipped, .outForDelivery:
            return "Tracking: \(shipment.trackingNumber ?? "—")"
        case .delivered:
            return "Hope you love it"
        case .delayed:
            return "We'll let you know"
        case .lost:
            return "Email support"
        }
    }

    private func primaryCTA(for shipment: Shipment) -> String {
        switch shipment.status {
        case .customizing, .approachingLock: return "Customize sticker"
        case .locked:                        return "View design"
        case .preparing:                     return "Track shipment"
        case .shipped, .outForDelivery:      return "Track package"
        case .delivered:                     return "How is it?"
        case .delayed, .lost:                return "What's happening"
        }
    }

    private func stepIndex(for status: Shipment.Status) -> Int {
        switch status {
        case .customizing, .approachingLock: return 0
        case .locked:                        return 1
        case .preparing:                     return 2
        case .shipped, .outForDelivery:      return 3
        case .delivered:                     return 4
        case .delayed, .lost:                return 2
        }
    }

    private func monthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}

#Preview {
    HoneyHomeView()
        .environment(ServiceContainer.preview())
}
