import SwiftUI
import LocalAuthentication

/// Custom sheet styled after Apple's in-app subscription confirmation
/// modal. We present this when StoreKit Configuration isn't active
/// (CLI launch instead of Xcode), so the user always sees a credible
/// Apple-style purchase flow. The Face ID prompt at the end is real
/// (LocalAuthentication) — that's the moment that sells it.
///
/// When StoreKit Configuration *is* active (Xcode launch), the real
/// Apple subscription sheet runs instead and this view is bypassed.
struct ApplePaymentSheet: View {
    let appName: String
    let tierName: String
    let priceText: String
    let trialText: String?       // e.g., "1 week free"
    let renewalText: String      // e.g., "Then $24.99/month"
    var onSuccess: () -> Void
    var onCancel: () -> Void

    @State private var isProcessing = false
    @State private var faceIDError: String?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
                .opacity(0.5)
            ScrollView {
                VStack(spacing: 18) {
                    appIcon
                    titleBlock
                    if let trialText { trialCard(trialText: trialText) }
                    detailsCard
                    if let faceIDError {
                        Text(faceIDError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                    termsText
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }
        }
        .background(backgroundColor.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                Divider().opacity(0.5)
                subscribeButton
            }
            .background(backgroundColor)
        }
        .interactiveDismissDisabled(isProcessing)
    }

    // MARK: - Pieces

    private var topBar: some View {
        HStack {
            Button("Cancel", action: onCancel)
                .font(.system(size: 17))
                .foregroundStyle(.blue)
                .disabled(isProcessing)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }

    private var appIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(
                    colors: [
                        Color(red: 1.00, green: 0.82, blue: 0.40),
                        Color(red: 0.96, green: 0.55, blue: 0.10)
                    ],
                    startPoint: .top, endPoint: .bottom))
            Image(systemName: "hexagon.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.white.opacity(0.95))
        }
        .frame(width: 100, height: 100)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .padding(.top, 8)
    }

    private var titleBlock: some View {
        VStack(spacing: 4) {
            Text("Subscribe to \(appName)")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.primary)
            Text(tierName)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
    }

    private func trialCard(trialText: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 22))
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(trialText.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(.green)
                Text(renewalText)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.green.opacity(colorScheme == .dark ? 0.18 : 0.08),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow("Subscription", value: "\(appName) \(tierName)")
            Divider().padding(.leading, 16)
            if let trialText {
                detailRow("Free Trial", value: trialText)
                Divider().padding(.leading, 16)
                detailRow("Then", value: priceText)
            } else {
                detailRow("Price", value: priceText)
            }
        }
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    private var termsText: some View {
        Text("Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage in Settings.")
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 4)
    }

    private var subscribeButton: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            Task { await confirm() }
        } label: {
            HStack(spacing: 8) {
                if isProcessing {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "faceid")
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(isProcessing ? "Processing…" : "Subscribe with Face ID")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundStyle(.white)
            .background(.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isProcessing)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Confirm flow

    @MainActor
    private func confirm() async {
        faceIDError = nil
        isProcessing = true
        defer { isProcessing = false }

        let context = LAContext()
        var policyError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &policyError) else {
            try? await Task.sleep(for: .milliseconds(500))
            onSuccess()
            return
        }

        let success: Bool = await withCheckedContinuation { cont in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Confirm subscription to \(appName) \(tierName)"
            ) { ok, _ in
                cont.resume(returning: ok)
            }
        }

        if success {
            // Successful subscription notification haptic.
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onSuccess()
        } else {
            faceIDError = "Face ID failed. Try again."
        }
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(uiColor: .systemBackground) : Color(uiColor: .systemGroupedBackground)
    }

    private var rowBackground: Color {
        colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : Color.white
    }
}

#Preview {
    Color.gray.ignoresSafeArea().sheet(isPresented: .constant(true)) {
        ApplePaymentSheet(
            appName: "Bees",
            tierName: "Forager",
            priceText: "$24.99/month",
            trialText: "1 week free",
            renewalText: "Then $24.99/month",
            onSuccess: { },
            onCancel: { }
        )
        .presentationDetents([.fraction(0.78)])
        .presentationCornerRadius(28)
    }
}
