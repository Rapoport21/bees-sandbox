import SwiftUI

struct AuthPickerView: View {
    @Environment(ServiceContainer.self) private var services
    let title: String
    var onEmail: (_ isSignup: Bool) -> Void
    @State private var isLoading = false

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
                    Button {
                        Task { await mockSignIn(provider: .apple) }
                    } label: {
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Continue with Apple")
                        }
                    }
                    .buttonStyle(BeesPrimaryButtonStyle())

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
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
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
    }

    private func mockSignIn(provider: AuthProvider) async {
        isLoading = true
        await services.authService.signIn(provider: provider, name: "Nick", email: "nick@example.com")
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        AuthPickerView(title: "Get started", onEmail: { _ in })
    }
    .environment(ServiceContainer.freshLaunch())
}
