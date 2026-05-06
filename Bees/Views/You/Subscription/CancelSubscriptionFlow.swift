import SwiftUI

struct CancelSubscriptionFlow: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .reason
    @State private var reason: Reason?

    enum Step: Hashable {
        case reason, discount, pause, downgrade, disclosure, holdToCancel, result
    }

    enum Reason: String, CaseIterable, Identifiable, Hashable {
        case tooExpensive = "Too expensive"
        case notUsing = "Not using it enough"
        case hiveIssues = "Issues with my hive"
        case moving = "Moving / address change"
        case lifeChange = "Life change"
        case other = "Other"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .reason:        reasonStep
                case .discount:      retentionDiscount
                case .pause:         retentionPause
                case .downgrade:     retentionDowngrade
                case .disclosure:    disclosureStep
                case .holdToCancel:  holdToCancelStep
                case .result:        resultStep
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if step != .result {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Close") { dismiss() }
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

    private var reasonStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BeesSpacing.l) {
                VStack(alignment: .leading, spacing: BeesSpacing.s) {
                    Text("Why are you leaving?")
                        .font(BeesType.displayL)
                    Text("This helps us improve.")
                        .font(BeesType.bodyM)
                        .foregroundStyle(BeesColors.charcoal600)
                }

                VStack(spacing: BeesSpacing.xs) {
                    ForEach(Reason.allCases) { r in
                        Button {
                            withAnimation { reason = r }
                        } label: {
                            HStack {
                                Image(systemName: reason == r ? "circle.inset.filled" : "circle")
                                    .foregroundStyle(reason == r ? BeesColors.honey500 : BeesColors.charcoal300)
                                Text(r.rawValue)
                                    .foregroundStyle(BeesColors.charcoal900)
                                Spacer()
                            }
                            .padding(BeesSpacing.m)
                            .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.md))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(BeesSpacing.m)
        }
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: BeesSpacing.s) {
                Button("Continue") { advanceFromReason() }
                    .buttonStyle(.beesPrimary)
                    .disabled(reason == nil)
                Button("Keep my hive") { dismiss() }
                    .buttonStyle(.beesSecondary)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s)
            .background(.regularMaterial)
        }
    }

    private var retentionDiscount: some View {
        retentionStep(
            illustration: "tag.fill",
            title: "How about 50% off?",
            body: "Stay for 2 months at half price. Your next bills: $\(halfPrice)/mo for 2 months, then back to normal.\n\nCancel anytime.",
            acceptText: "Take the deal",
            onAccept: { dismiss() },
            onDecline: { advanceTo(.pause) }
        )
    }

    private var retentionPause: some View {
        retentionStep(
            illustration: "pause.circle.fill",
            title: "Take a break instead?",
            body: "Pause your hive for up to 3 months. No charges. We'll keep your hive number reserved.",
            acceptText: "Pause my hive",
            onAccept: { dismiss() },
            onDecline: { advanceTo(.downgrade) }
        )
    }

    private var retentionDowngrade: some View {
        retentionStep(
            illustration: "arrow.down.circle.fill",
            title: "Try a smaller plan?",
            body: "Pollinator at $14.99/mo gives you live video, basic stats, and 1 jar every 3 months. Effective next billing cycle.",
            acceptText: "Switch to Pollinator",
            onAccept: {
                services.switchTier(.pollinator)
                dismiss()
            },
            onDecline: { advanceTo(.disclosure) }
        )
    }

    private var disclosureStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BeesSpacing.l) {
                Text("Before you cancel")
                    .font(BeesType.displayL)

                VStack(alignment: .leading, spacing: BeesSpacing.m) {
                    disclosureRow(
                        icon: "exclamationmark.triangle.fill",
                        color: BeesColors.amber500,
                        title: "Video access ends at period close",
                        body: "You can keep watching until your current paid period ends."
                    )
                    disclosureRow(
                        icon: "shippingbox.fill",
                        color: BeesColors.amber500,
                        title: "Final shipment won't ship",
                        body: "Any shipment scheduled after today will be canceled."
                    )
                    disclosureRow(
                        icon: "checkmark.seal.fill",
                        color: BeesColors.leaf500,
                        title: "You'll keep your history",
                        body: "Past shipments, achievements, and saved stickers stay with your account."
                    )
                }

                Text("You can re-subscribe anytime. We may not be able to give back the same hive number.")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            .padding(BeesSpacing.m)
        }
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: BeesSpacing.s) {
                Button("Continue to cancel") { advanceTo(.holdToCancel) }
                    .buttonStyle(BeesPrimaryButtonStyle(isDestructive: true))
                Button("Keep my hive") { dismiss() }
                    .buttonStyle(.beesSecondary)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s)
            .background(.regularMaterial)
        }
    }

    private var holdToCancelStep: some View {
        VStack(spacing: BeesSpacing.l) {
            Spacer()
            Text("One last thing")
                .font(BeesType.displayL)
            Text("Press and hold to confirm cancellation.")
                .font(BeesType.bodyM)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeesSpacing.l)

            HoldToConfirmButton {
                services.cancelSubscription()
                advanceTo(.result)
            }
            .padding(.horizontal, BeesSpacing.l)

            Button("Keep my hive") { dismiss() }
                .buttonStyle(.beesGhost)

            Spacer()
        }
        .padding(BeesSpacing.m)
        .background(BeesColors.surfacePage.ignoresSafeArea())
    }

    private var resultStep: some View {
        VStack(spacing: BeesSpacing.l) {
            Spacer()
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 64))
                .foregroundStyle(BeesColors.honey500)
            Text("You're all set")
                .font(BeesType.displayL)
            Text("Your subscription is canceled. We'll keep your shipment history and achievements safe.")
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeesSpacing.l)

            Spacer()

            Button("Done") { dismiss() }
                .buttonStyle(.beesPrimary)
                .padding(.horizontal, BeesSpacing.m)
        }
        .padding(BeesSpacing.m)
        .background(BeesColors.surfacePage.ignoresSafeArea())
    }

    // MARK: - Helpers

    private func retentionStep(
        illustration: String,
        title: String,
        body: String,
        acceptText: String,
        onAccept: @escaping () -> Void,
        onDecline: @escaping () -> Void
    ) -> some View {
        VStack(spacing: BeesSpacing.l) {
            Spacer()
            Image(systemName: illustration)
                .font(.system(size: 64))
                .foregroundStyle(BeesColors.honey500)
            Text(title)
                .font(BeesType.displayL)
                .multilineTextAlignment(.center)
            Text(body)
                .font(BeesType.bodyM)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BeesSpacing.l)
            Spacer()
            Button(acceptText, action: onAccept)
                .buttonStyle(.beesPrimary)
            Button("No thanks, continue", action: onDecline)
                .buttonStyle(.beesGhost)
        }
        .padding(BeesSpacing.m)
        .background(BeesColors.surfacePage.ignoresSafeArea())
    }

    private func disclosureRow(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: BeesSpacing.s) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BeesType.bodyM.weight(.semibold))
                Text(body)
                    .font(BeesType.bodyM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
        }
    }

    private func advanceFromReason() {
        guard let reason else { return }
        switch reason {
        case .hiveIssues:
            advanceTo(.disclosure)
        case .moving, .lifeChange:
            advanceTo(.pause)
        default:
            advanceTo(.discount)
        }
    }

    private func advanceTo(_ next: Step) {
        withAnimation(.easeInOut(duration: 0.2)) { step = next }
    }

    private var stepIndicator: String {
        let total: Int
        let current: Int
        switch step {
        case .reason:        current = 1; total = 5
        case .discount:      current = 2; total = 5
        case .pause:         current = 3; total = 5
        case .downgrade:     current = 4; total = 5
        case .disclosure:    current = 5; total = 5
        case .holdToCancel:  return "Final step"
        case .result:        return ""
        }
        return "Step \(current) of \(total)"
    }

    private var halfPrice: String {
        let half = services.currentTier.monthlyPrice * Decimal(0.5)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: half as NSDecimalNumber) ?? "\(half)"
    }
}

private struct HoldToConfirmButton: View {
    var onConfirm: () -> Void
    @State private var isPressed = false
    @State private var progress: CGFloat = 0
    @State private var task: Task<Void, Never>?

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: BeesRadius.md)
                .fill(BeesColors.charcoal300.opacity(0.3))
                .frame(height: 56)

            GeometryReader { geo in
                RoundedRectangle(cornerRadius: BeesRadius.md)
                    .fill(BeesColors.error500)
                    .frame(width: geo.size.width * progress, height: 56)
            }
            .frame(height: 56)

            HStack {
                Spacer()
                Text(progress >= 1.0 ? "Cancelled" : "Hold to cancel")
                    .font(BeesType.bodyL.weight(.semibold))
                    .foregroundStyle(progress > 0.5 ? .white : BeesColors.charcoal900)
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            .frame(height: 56)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in startHold() }
                .onEnded { _ in cancelHold() }
        )
    }

    private func startHold() {
        guard task == nil else { return }
        task = Task {
            let total = 2.0
            let stepSize = 0.05
            for i in 0...Int(total / stepSize) {
                if Task.isCancelled { return }
                try? await Task.sleep(for: .seconds(stepSize))
                let p = Double(i) * stepSize / total
                await MainActor.run {
                    withAnimation(.linear(duration: stepSize)) {
                        progress = CGFloat(min(p, 1.0))
                    }
                }
                if p >= 1.0 {
                    await MainActor.run { onConfirm() }
                    return
                }
            }
        }
    }

    private func cancelHold() {
        task?.cancel()
        task = nil
        if progress < 1.0 {
            withAnimation { progress = 0 }
        }
    }
}

#Preview {
    CancelSubscriptionFlow()
        .environment(ServiceContainer.preview())
}
