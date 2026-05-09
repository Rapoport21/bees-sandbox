import SwiftUI

/// NOTE: Free Apple Developer accounts (Personal Team) cannot enable
/// the Sign in with Apple capability. We render a button styled to
/// match Apple's official one and present a custom sheet that mimics
/// Apple's sign-in modal — name row, share/hide email choice, big
/// Continue button. The Face ID prompt invoked from that sheet IS
/// real (LocalAuthentication works without entitlement), so the
/// moment of authentication feels authentic.
///
/// Day this project moves to a paid Developer team, swap
/// `AppleLookalikeButton` + sheet for SwiftUI's `SignInWithAppleButton`
/// and the `MockAuthService.signInWithApple` call already takes a
/// matching credential signature — downstream code doesn't change.
struct AuthPickerView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    var onEmail: (_ isSignup: Bool) -> Void
    @State private var isLoading = false
    @State private var showAppleSheet = false

    private let buttonHeight: CGFloat = 50
    private let buttonCornerRadius: CGFloat = 10

    var body: some View {
        VStack(spacing: 0) {
            // Asymmetric brand block — left-aligned, smaller hex,
            // serif title gets to be the focus. Anti-centered-hero
            // pattern for the editorial farmhouse direction.
            VStack(alignment: .leading, spacing: BeesSpacing.s) {
                Image(systemName: "hexagon.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(BeesColors.honey500)
                    .padding(.top, BeesSpacing.l)

                Text(title)
                    .font(BeesType.displayL)
                    .foregroundStyle(BeesColors.charcoal900)
                    .padding(.top, BeesSpacing.xxs)

                Text("Pick how you'd like to sign in.")
                    .font(BeesType.bodyM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Bottom: actions block — all three buttons share the
            // exact same dimensions, corner radius, and press feedback.
            // Only the fill colors differ.
            VStack(spacing: BeesSpacing.s) {
                AppleLookalikeButton(
                    colorScheme: colorScheme,
                    cornerRadius: buttonCornerRadius,
                    action: {
                        let h = UIImpactFeedbackGenerator(style: .light)
                        h.impactOccurred()
                        showAppleSheet = true
                    }
                )
                .frame(height: buttonHeight)

                outlinedSignInButton(
                    iconName: "g.circle.fill",
                    text: "Continue with Google",
                    action: { Task { await mockSignIn(provider: .google) } }
                )

                outlinedSignInButton(
                    iconName: "envelope.fill",
                    text: "Continue with email",
                    action: { onEmail(true) }
                )

                Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
                    .multilineTextAlignment(.center)
                    .padding(.top, BeesSpacing.xs)
                    .padding(.horizontal, BeesSpacing.s)
            }
            .padding(.bottom, BeesSpacing.l)
        }
        .padding(.horizontal, BeesSpacing.m)
        .frame(maxHeight: .infinity)
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView("Signing in…")
                        .padding(BeesSpacing.l)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
                }
            }
        }
        .sheet(isPresented: $showAppleSheet) {
            AppleSignInSheet(
                appName: "Bees",
                appleID: "rapoportn21@gmail.com",
                userName: "Nikita Rapoport",
                onSuccess: { shareEmail in
                    services.authService.signInWithApple(
                        userID: "MOCK-APPLE-USER-\(UUID().uuidString.prefix(8))",
                        name: "Nikita Rapoport",
                        email: shareEmail ? "rapoportn21@gmail.com" : "private-relay-\(UUID().uuidString.prefix(6))@privaterelay.appleid.com"
                    )
                    showAppleSheet = false
                },
                onCancel: { showAppleSheet = false }
            )
            .presentationDetents([.fraction(0.78)])
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Buttons

    private func outlinedSignInButton(
        iconName: String,
        text: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            let h = UIImpactFeedbackGenerator(style: .light)
            h.impactOccurred()
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .medium))
                Text(text)
                    .font(.system(size: 17, weight: .medium))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(BeesColors.charcoal900)
            .background(
                RoundedRectangle(cornerRadius: buttonCornerRadius, style: .continuous)
                    .stroke(BeesColors.charcoal300, lineWidth: 1.5)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .frame(height: buttonHeight)
    }

    // MARK: - Mock providers

    private func mockSignIn(provider: AuthProvider) async {
        isLoading = true
        await services.authService.signIn(provider: provider, name: "Nick", email: "nick@example.com")
        isLoading = false
    }
}

// MARK: - Apple-styled lookalike button

private struct AppleLookalikeButton: View {
    let colorScheme: ColorScheme
    var cornerRadius: CGFloat = 8
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "applelogo")
                    .font(.system(size: 18, weight: .medium))
                Text("Continue with Apple")
                    .font(.system(size: 17, weight: .medium))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white : Color.black)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}
