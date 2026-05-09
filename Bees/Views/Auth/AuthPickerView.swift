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

    var body: some View {
        ScrollView {
            VStack(spacing: BeesSpacing.l) {
                Image(systemName: "hexagon.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(BeesColors.honey500)
                    .padding(.top, BeesSpacing.xl)

                Text(title)
                    .font(BeesType.displayL)

                Text("Pick how you'd like to sign in.")
                    .font(BeesType.bodyM)
                    .foregroundStyle(BeesColors.charcoal600)

                VStack(spacing: BeesSpacing.s) {
                    AppleLookalikeButton(
                        colorScheme: colorScheme,
                        action: { showAppleSheet = true }
                    )
                    .frame(height: 50)

                    Button {
                        Task { await mockSignIn(provider: .google) }
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Continue with Google")
                        }
                    }
                    .buttonStyle(.beesSecondary)

                    Button {
                        onEmail(true)
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Continue with email")
                        }
                    }
                    .buttonStyle(.beesSecondary)
                }
                .padding(.top, BeesSpacing.l)

                Text("By continuing, you agree to our Terms of Service and Privacy Policy.")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
                    .multilineTextAlignment(.center)
                    .padding(.top, BeesSpacing.l)
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xxl)
            .frame(maxWidth: .infinity)
        }
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
            .presentationCornerRadius(28)
        }
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
    let action: () -> Void

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "applelogo")
                    .font(.system(size: 18, weight: .medium))
                Text("Continue with Apple")
                    .font(.system(size: 17, weight: .medium))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.white : Color.black)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}
