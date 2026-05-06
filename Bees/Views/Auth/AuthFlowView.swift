import SwiftUI

enum AuthStep: Hashable {
    case carousel
    case demo
    case picker(returningSignIn: Bool)
    case emailForm(isSignup: Bool)
}

struct AuthFlowView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var path: [AuthStep] = []

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                switch services.onboardingVariant {
                case .carouselFirst:
                    IntroFlow(
                        onAdopt: { path.append(.picker(returningSignIn: false)) },
                        onDemo:  { path.append(.demo) },
                        onSignIn: { path.append(.picker(returningSignIn: true)) }
                    )
                case .videosFirst:
                    VideoIntroView(
                        onAdopt: { path.append(.picker(returningSignIn: false)) },
                        onDemo:  { path.append(.demo) },
                        onSignIn: { path.append(.picker(returningSignIn: true)) }
                    )
                }
            }
            .navigationDestination(for: AuthStep.self) { step in
                switch step {
                case .carousel:
                    EmptyView()
                case .demo:
                    DemoHiveViewerView(
                        onSignUp: { path.append(.picker(returningSignIn: false)) }
                    )
                case .picker(let returning):
                    AuthPickerView(
                        title: returning ? "Welcome back" : "Get started",
                        onEmail: { isSignup in path.append(.emailForm(isSignup: isSignup)) }
                    )
                case .emailForm(let isSignup):
                    EmailAuthFormView(isSignup: isSignup)
                }
            }
        }
    }
}

#Preview {
    AuthFlowView()
        .environment(ServiceContainer.freshLaunch())
}
