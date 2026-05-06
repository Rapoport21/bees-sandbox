import SwiftUI

struct EmailAuthFormView: View {
    @Environment(ServiceContainer.self) private var services
    let isSignup: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BeesSpacing.m) {
                Text(isSignup ? "Create your account" : "Sign in")
                    .font(BeesType.displayL)
                    .padding(.top, BeesSpacing.l)

                if isSignup {
                    field(label: "Name", text: $name)
                }
                field(label: "Email", text: $email, keyboard: .emailAddress, isSecure: false)
                field(label: "Password", text: $password, isSecure: true)

                if let error {
                    Text(error)
                        .font(BeesType.captionM)
                        .foregroundStyle(BeesColors.error500)
                }

                if !isSignup {
                    Button("Forgot password?") { }
                        .buttonStyle(.beesGhost)
                }
            }
            .padding(.horizontal, BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xxl)
        }
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            Button(isSignup ? "Create account" : "Sign in") {
                Task { await submit() }
            }
            .buttonStyle(.beesPrimary)
            .disabled(!isValid || isLoading)
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s)
            .background(.regularMaterial)
        }
        .navigationTitle(isSignup ? "Sign up" : "Sign in")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func field(label: String, text: Binding<String>, keyboard: UIKeyboardType = .default, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: BeesSpacing.xxs) {
            Text(label)
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
            Group {
                if isSecure {
                    SecureField(label, text: text)
                } else {
                    TextField(label, text: text)
                        .keyboardType(keyboard)
                        .textContentType(label == "Email" ? .emailAddress : nil)
                        .autocapitalization(label == "Email" ? .none : .words)
                }
            }
            .textFieldStyle(.roundedBorder)
        }
    }

    private var isValid: Bool {
        let emailOK = email.contains("@") && email.contains(".")
        let passOK  = password.count >= 6
        let nameOK  = !isSignup || !name.isEmpty
        return emailOK && passOK && nameOK
    }

    private func submit() async {
        isLoading = true
        error = nil
        await services.authService.signIn(provider: .email, name: isSignup ? name : nil, email: email)
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        EmailAuthFormView(isSignup: true)
    }
    .environment(ServiceContainer.freshLaunch())
}
