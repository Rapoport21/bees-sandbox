import SwiftUI

struct GiftFlow: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .launchpad
    @State private var giftType: GiftType = .jar
    @State private var recipient = Recipient()
    @State private var giftTier: Tier = .forager
    @State private var giftDuration: GiftDuration = .sixMonths
    @State private var design: StickerDesign = StickerDesign.empty
    @State private var message: String = ""
    @State private var senderName: String = "Nick"
    @State private var cardStyle: CardStyle = .hexagon
    @State private var packaging: Packaging = .standard

    enum Step: Hashable {
        case launchpad, recipient, tierPicker, sticker, message, packaging, review, confirmation
    }

    enum GiftType: String, Hashable { case jar, subscription }

    enum GiftDuration: String, CaseIterable, Identifiable, Hashable {
        case threeMonths, sixMonths, twelveMonths
        var id: String { rawValue }
        var months: Int {
            switch self {
            case .threeMonths: return 3
            case .sixMonths: return 6
            case .twelveMonths: return 12
            }
        }
        var displayName: String { "\(months) mos" }
        var multiplier: Decimal {
            switch self {
            case .threeMonths: return 1.0
            case .sixMonths: return 0.95
            case .twelveMonths: return 0.83
            }
        }
    }

    struct Recipient {
        var name: String = ""
        var email: String = ""
        var address: String = ""
    }

    enum CardStyle: String, CaseIterable, Identifiable, Hashable {
        case hexagon, watercolor, minimal
        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }

    enum Packaging: String, CaseIterable, Identifiable, Hashable {
        case standard, giftWrap, premium
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .standard: return "Standard"
            case .giftWrap: return "Gift Wrap"
            case .premium:  return "Premium Box"
            }
        }
        var price: Decimal {
            switch self {
            case .standard: return 0
            case .giftWrap: return 6
            case .premium:  return 18
            }
        }
        var description: String {
            switch self {
            case .standard: return "Kraft box, paper wrap, sticker on jar"
            case .giftWrap: return "Standard + ribbon + handwritten label"
            case .premium:  return "Wooden box, gold seal, ribbon, mini honey wand"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .launchpad:    launchpadStep
                case .recipient:    recipientStep
                case .tierPicker:   tierPickerStep
                case .sticker:      stickerStep
                case .message:      messageStep
                case .packaging:    packagingStep
                case .review:       reviewStep
                case .confirmation: confirmationStep
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if step != .confirmation {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(step == .launchpad ? "Close" : "Back") {
                            if step == .launchpad { dismiss() } else { back() }
                        }
                        .tint(BeesColors.charcoal600)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(stepIndicator)
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.charcoal600)
                }
            }
        }
    }

    // MARK: - Steps

    private var launchpadStep: some View {
        VStack(spacing: BeesSpacing.l) {
            Spacer()
            Text("Send a gift")
                .font(BeesType.displayXL)
            Text("Pick what you'd like to send.")
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal600)

            VStack(spacing: BeesSpacing.s) {
                giftOption(
                    type: .jar,
                    title: "Send a jar of honey",
                    body: "A one-time custom jar shipped to your recipient.",
                    icon: "drop.fill",
                    available: services.currentTier.canSendGifts
                )
                giftOption(
                    type: .subscription,
                    title: "Gift a subscription",
                    body: "3, 6, or 12 months of Bees with their own hive.",
                    icon: "gift.fill",
                    available: services.currentTier.canSendSubscriptionGifts
                )
            }
            .padding(.horizontal, BeesSpacing.m)
            Spacer()
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
    }

    private func giftOption(type: GiftType, title: String, body: String, icon: String, available: Bool) -> some View {
        Button {
            guard available else { return }
            giftType = type
            advance(to: .recipient)
        } label: {
            HStack(spacing: BeesSpacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(available ? BeesColors.honey500 : BeesColors.charcoal300)
                    .frame(width: 40)
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(title)
                            .font(BeesType.headingM)
                            .foregroundStyle(BeesColors.charcoal900)
                        if !available {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(BeesColors.charcoal300)
                        }
                    }
                    Text(body)
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.charcoal600)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(BeesColors.charcoal300)
            }
            .padding(BeesSpacing.m)
            .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.md))
            .opacity(available ? 1.0 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!available)
    }

    private var recipientStep: some View {
        Form {
            Section("Recipient") {
                TextField("Name", text: $recipient.name)
                TextField("Email", text: $recipient.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            Section("Shipping address") {
                TextField("Street, city, state, zip", text: $recipient.address, axis: .vertical)
                    .lineLimit(3...5)
            }
        }
        .navigationTitle("Who's it for?")
        .safeAreaInset(edge: .bottom) {
            Button("Continue") {
                advance(to: giftType == .subscription ? .tierPicker : .sticker)
            }
            .buttonStyle(.beesPrimary)
            .disabled(recipient.name.isEmpty || recipient.email.isEmpty)
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s)
            .background(.regularMaterial)
        }
    }

    private var tierPickerStep: some View {
        ScrollView {
            VStack(spacing: BeesSpacing.l) {
                Text("Pick a plan for them")
                    .font(BeesType.displayL)
                    .padding(.top, BeesSpacing.l)

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    Text("How long?")
                        .font(BeesType.captionM)
                        .tracking(1)
                        .foregroundStyle(BeesColors.charcoal600)
                    HStack(spacing: BeesSpacing.s) {
                        ForEach(GiftDuration.allCases) { duration in
                            durationButton(duration)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    Text("Which plan?")
                        .font(BeesType.captionM)
                        .tracking(1)
                        .foregroundStyle(BeesColors.charcoal600)
                    HStack(spacing: BeesSpacing.s) {
                        ForEach(Tier.allCases, id: \.self) { tier in
                            tierButton(tier)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                    Text("Total today")
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.charcoal600)
                    Text("$\(format(subTotal))")
                        .font(BeesType.displayL)
                    Text("Prepaid one-time. After it ends, they can re-subscribe at their own cost.")
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.charcoal600)
                }
                .padding(BeesSpacing.m)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xl)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .navigationTitle("Pick a plan")
        .safeAreaInset(edge: .bottom) {
            Button("Continue") { advance(to: .sticker) }
                .buttonStyle(.beesPrimary)
                .padding(.horizontal, BeesSpacing.m)
                .padding(.vertical, BeesSpacing.s)
                .background(.regularMaterial)
        }
    }

    private func durationButton(_ duration: GiftDuration) -> some View {
        let selected = giftDuration == duration
        return Button {
            giftDuration = duration
        } label: {
            VStack(spacing: BeesSpacing.xxs) {
                Text(duration.displayName)
                    .font(BeesType.bodyM.weight(.semibold))
                Text("$\(format(price(for: giftTier, duration: duration)))")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BeesSpacing.m)
            .background(selected ? BeesColors.honey300 : .white,
                        in: RoundedRectangle(cornerRadius: BeesRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: BeesRadius.md)
                    .stroke(selected ? BeesColors.honey500 : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(BeesColors.charcoal900)
    }

    private func tierButton(_ tier: Tier) -> some View {
        let selected = giftTier == tier
        return Button {
            giftTier = tier
        } label: {
            VStack(spacing: BeesSpacing.xxs) {
                Text(tier.displayName)
                    .font(BeesType.captionM.weight(.semibold))
                Text("$\(format(tier.monthlyPrice))")
                    .font(BeesType.captionS)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BeesSpacing.m)
            .background(selected ? BeesColors.honey300 : .white,
                        in: RoundedRectangle(cornerRadius: BeesRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: BeesRadius.md)
                    .stroke(selected ? BeesColors.honey500 : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(BeesColors.charcoal900)
    }

    private var stickerStep: some View {
        ScrollView {
            VStack(spacing: BeesSpacing.l) {
                Text("Customize their sticker")
                    .font(BeesType.displayL)
                    .padding(.top, BeesSpacing.l)
                JarPreview(design: design, size: 180)
                Text("Their name, an inside joke, a date...")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    SectionHeader(title: "Base design")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: BeesSpacing.s) {
                            ForEach(StickerBaseDesign.catalog) { d in
                                Button {
                                    design.baseDesignId = d.id
                                } label: {
                                    Circle()
                                        .fill(d.backgroundColor)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(design.baseDesignId == d.id ? BeesColors.honey500 : .clear, lineWidth: 3)
                                        )
                                        .overlay(
                                            Circle()
                                                .fill(d.accentColor.opacity(0.5))
                                                .frame(width: 16, height: 16)
                                        )
                                }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    SectionHeader(title: "Custom text")
                    TextField("Line 1", text: $design.line1)
                        .textFieldStyle(.roundedBorder)
                    TextField("Line 2", text: $design.line2)
                        .textFieldStyle(.roundedBorder)
                    TextField("Line 3", text: $design.line3)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xl)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .navigationTitle("Customize sticker")
        .safeAreaInset(edge: .bottom) {
            Button("Continue") { advance(to: .message) }
                .buttonStyle(.beesPrimary)
                .padding(.horizontal, BeesSpacing.m)
                .padding(.vertical, BeesSpacing.s)
                .background(.regularMaterial)
        }
    }

    private var messageStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BeesSpacing.l) {
                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    SectionHeader(title: "Card style")
                    HStack(spacing: BeesSpacing.s) {
                        ForEach(CardStyle.allCases) { style in
                            Button {
                                cardStyle = style
                            } label: {
                                VStack(spacing: BeesSpacing.xxs) {
                                    RoundedRectangle(cornerRadius: BeesRadius.md)
                                        .fill(cardColor(style))
                                        .aspectRatio(0.7, contentMode: .fit)
                                        .overlay(
                                            Image(systemName: cardIcon(style))
                                                .font(.system(size: 24))
                                                .foregroundStyle(.white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: BeesRadius.md)
                                                .stroke(cardStyle == style ? BeesColors.honey500 : .clear, lineWidth: 2)
                                        )
                                    Text(style.displayName)
                                        .font(BeesType.captionS)
                                        .foregroundStyle(BeesColors.charcoal600)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    SectionHeader(title: "Your message")
                    TextEditor(text: $message)
                        .scrollContentBackground(.hidden)
                        .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.md))
                        .frame(minHeight: 120)
                        .padding(BeesSpacing.xs)
                        .overlay(
                            RoundedRectangle(cornerRadius: BeesRadius.md)
                                .stroke(BeesColors.charcoal300, lineWidth: 1)
                        )
                    Text("\(message.count) / 200 characters")
                        .font(BeesType.captionS)
                        .foregroundStyle(BeesColors.charcoal600)
                }

                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    SectionHeader(title: "Sender name")
                    TextField("From", text: $senderName)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(BeesSpacing.m)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .navigationTitle("Add a card")
        .safeAreaInset(edge: .bottom) {
            Button("Continue") { advance(to: .packaging) }
                .buttonStyle(.beesPrimary)
                .padding(.horizontal, BeesSpacing.m)
                .padding(.vertical, BeesSpacing.s)
                .background(.regularMaterial)
        }
    }

    private var packagingStep: some View {
        ScrollView {
            VStack(spacing: BeesSpacing.s) {
                ForEach(Packaging.allCases) { option in
                    packagingRow(option)
                }
            }
            .padding(BeesSpacing.m)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .navigationTitle("Make it special?")
        .safeAreaInset(edge: .bottom) {
            Button("Continue") { advance(to: .review) }
                .buttonStyle(.beesPrimary)
                .padding(.horizontal, BeesSpacing.m)
                .padding(.vertical, BeesSpacing.s)
                .background(.regularMaterial)
        }
    }

    private func packagingRow(_ option: Packaging) -> some View {
        let selected = packaging == option
        return Button {
            withAnimation(.easeOut(duration: 0.2)) { packaging = option }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(option.displayName.uppercased())
                            .font(BeesType.captionS)
                            .tracking(1)
                            .foregroundStyle(BeesColors.charcoal600)
                        Spacer()
                        Text(option.price == 0 ? "$0" : "+$\(format(option.price))")
                            .font(BeesType.captionM.weight(.semibold))
                            .foregroundStyle(BeesColors.charcoal900)
                    }
                    Text(option.description)
                        .font(BeesType.bodyM)
                        .foregroundStyle(BeesColors.charcoal900)
                }
            }
            .padding(BeesSpacing.m)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: BeesRadius.md)
                    .stroke(selected ? BeesColors.honey500 : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var reviewStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BeesSpacing.l) {
                summarySection(title: "TO", lines: [recipient.name, recipient.email, recipient.address])
                summarySection(title: "GIFT", lines: [
                    giftType == .jar ? "Jar of honey" : "\(giftDuration.displayName) of \(giftTier.displayName)",
                    [design.line1, design.line2, design.line3].filter { !$0.isEmpty }.joined(separator: " · ")
                ])
                summarySection(title: "CARD", lines: [cardStyle.displayName, message.isEmpty ? "(no message)" : message])
                summarySection(title: "PACKAGING", lines: [packaging.displayName, packaging.description])

                Divider()

                VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text("$\(format(subTotal))")
                    }
                    HStack {
                        Text("Packaging")
                        Spacer()
                        Text(packaging.price == 0 ? "Free" : "$\(format(packaging.price))")
                    }
                    HStack {
                        Text("Tax (est.)")
                        Spacer()
                        Text("$\(format(tax))")
                    }
                    HStack {
                        Text("Total").font(BeesType.headingM)
                        Spacer()
                        Text("$\(format(total))").font(BeesType.headingM)
                    }
                }
            }
            .padding(BeesSpacing.m)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .navigationTitle("Review")
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: BeesSpacing.s) {
                Button {
                    advance(to: .confirmation)
                } label: {
                    HStack { Image(systemName: "applelogo"); Text("Pay with Apple Pay") }
                }
                .buttonStyle(.beesPrimary)

                Button("Use a card") {
                    advance(to: .confirmation)
                }
                .buttonStyle(.beesSecondary)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s)
            .background(.regularMaterial)
        }
    }

    private var confirmationStep: some View {
        VStack(spacing: BeesSpacing.l) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(BeesColors.honey500)
                .symbolEffect(.bounce)
            Text("Sweet — gift sent.")
                .font(BeesType.displayL)
                .multilineTextAlignment(.center)
            Text("\(recipient.name) will get an email when their honey ships.")
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeesSpacing.l)
            Text("Order #BEE-2026-04812")
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
            Spacer()
            Button("Done") { dismiss() }
                .buttonStyle(.beesPrimary)
                .padding(.horizontal, BeesSpacing.m)
        }
        .padding(BeesSpacing.m)
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
    }

    // MARK: - Helpers

    private func summarySection(title: String, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: BeesSpacing.xs) {
            Text(title)
                .font(BeesType.captionS)
                .tracking(1)
                .foregroundStyle(BeesColors.charcoal600)
            ForEach(lines.filter { !$0.isEmpty }, id: \.self) { line in
                Text(line)
                    .font(BeesType.bodyM)
                    .foregroundStyle(BeesColors.charcoal900)
            }
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: BeesRadius.md))
    }

    private func cardColor(_ style: CardStyle) -> Color {
        switch style {
        case .hexagon:    return BeesColors.honey500
        case .watercolor: return BeesColors.amber500
        case .minimal:    return BeesColors.charcoal900
        }
    }

    private func cardIcon(_ style: CardStyle) -> String {
        switch style {
        case .hexagon:    return "hexagon.fill"
        case .watercolor: return "paintbrush.fill"
        case .minimal:    return "minus"
        }
    }

    private func price(for tier: Tier, duration: GiftDuration) -> Decimal {
        tier.monthlyPrice * Decimal(duration.months) * duration.multiplier
    }

    private var subTotal: Decimal {
        switch giftType {
        case .jar:          return 25
        case .subscription: return price(for: giftTier, duration: giftDuration)
        }
    }

    private var tax: Decimal { (subTotal + packaging.price) * Decimal(0.085) }
    private var total: Decimal { subTotal + packaging.price + tax }

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    private func advance(to next: Step) {
        withAnimation(.easeInOut(duration: 0.25)) { step = next }
    }

    private func back() {
        let previousStep: Step
        switch step {
        case .launchpad:    previousStep = .launchpad
        case .recipient:    previousStep = .launchpad
        case .tierPicker:   previousStep = .recipient
        case .sticker:      previousStep = giftType == .subscription ? .tierPicker : .recipient
        case .message:      previousStep = .sticker
        case .packaging:    previousStep = .message
        case .review:       previousStep = .packaging
        case .confirmation: previousStep = .review
        }
        advance(to: previousStep)
    }

    private var stepIndicator: String {
        let steps: [Step] = giftType == .subscription
            ? [.recipient, .tierPicker, .sticker, .message, .packaging, .review]
            : [.recipient, .sticker, .message, .packaging, .review]
        guard let index = steps.firstIndex(of: step) else { return "" }
        return "Step \(index + 1) of \(steps.count)"
    }
}

#Preview {
    GiftFlow()
        .environment(ServiceContainer.preview())
}
