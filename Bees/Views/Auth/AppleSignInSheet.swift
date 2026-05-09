import SwiftUI
import LocalAuthentication

/// Custom sheet that mimics Apple's Sign in with Apple modal. Free
/// Apple Developer accounts cannot enable real SiwA capability, so we
/// recreate the visual experience: app icon, Apple ID identity row,
/// share/hide email toggle, big Continue button. The Face ID prompt
/// IS real (LocalAuthentication framework — no entitlement needed),
/// so the moment of truth feels authentic.
///
/// Swap to the real `SignInWithAppleButton` + `ASAuthorizationController`
/// flow when this project moves to a paid Developer team.
struct AppleSignInSheet: View {
    let appName: String
    let appleID: String
    let userName: String
    var onSuccess: (_ shareEmail: Bool) -> Void
    var onCancel: () -> Void

    @State private var shareEmail = true
    @State private var isAuthenticating = false
    @State private var faceIDError: String?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(spacing: 18) {
                    appIcon
                    titleBlock
                    identityCard
                    emailCard
                    if let faceIDError {
                        Text(faceIDError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            continueButton
        }
        .background(backgroundColor.ignoresSafeArea())
        .interactiveDismissDisabled(isAuthenticating)
    }

    // MARK: - Pieces

    private var topBar: some View {
        HStack {
            Button("Cancel", action: onCancel)
                .font(.system(size: 17))
                .foregroundStyle(.blue)
                .disabled(isAuthenticating)
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
            Text("Sign in to \(appName)")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.primary)
            Text("with your Apple ID \(appleID)")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var identityCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("NAME")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 80, alignment: .leading)
                Text(userName)
                    .font(.system(size: 17))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var emailCard: some View {
        VStack(spacing: 0) {
            // Share My Email row
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.spring(duration: 0.32, bounce: 0.18)) {
                    shareEmail = true
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Share My Email")
                            .font(.system(size: 17))
                            .foregroundStyle(.primary)
                        Text(appleID)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if shareEmail {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(RowPressStyle())

            Divider().padding(.leading, 16)

            // Hide My Email row
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                withAnimation(.spring(duration: 0.32, bounce: 0.18)) {
                    shareEmail = false
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Hide My Email")
                            .font(.system(size: 17))
                            .foregroundStyle(.primary)
                        Text("Apple will create a private email")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !shareEmail {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(RowPressStyle())
        }
        .background(rowBackground, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var continueButton: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            Task { await authenticate() }
        } label: {
            HStack(spacing: 8) {
                if isAuthenticating {
                    ProgressView().tint(.white)
                }
                Text(isAuthenticating ? "Signing in…" : "Continue")
                    .font(.system(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .foregroundStyle(.white)
            .background(.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isAuthenticating)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
    }

    // MARK: - Auth

    @MainActor
    private func authenticate() async {
        faceIDError = nil
        isAuthenticating = true
        defer { isAuthenticating = false }

        let context = LAContext()
        var policyError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                        error: &policyError) else {
            // Simulator or device without biometrics — proceed anyway.
            // Brief delay so the spinner reads as a real round-trip.
            try? await Task.sleep(for: .milliseconds(400))
            onSuccess(shareEmail)
            return
        }

        let success: Bool = await withCheckedContinuation { cont in
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Sign in to \(appName) with Face ID"
            ) { ok, _ in
                cont.resume(returning: ok)
            }
        }

        if success {
            onSuccess(shareEmail)
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

// MARK: - Button styles for press feedback

/// Continue / primary button — slight scale + opacity dip on press,
/// matching Apple's tappable bottom-sheet button feel.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Email / list-row button — gray fill flash on press, no scale, like
/// the cells inside Apple's sign-in sheet.
struct RowPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Color(uiColor: .systemGray4)
                    .opacity(configuration.isPressed ? 0.5 : 0)
            )
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    Color.gray.ignoresSafeArea().sheet(isPresented: .constant(true)) {
        AppleSignInSheet(
            appName: "Bees",
            appleID: "rapoportn21@gmail.com",
            userName: "Nikita Rapoport",
            onSuccess: { _ in },
            onCancel: { }
        )
        .presentationDetents([.fraction(0.78)])
    }
}
