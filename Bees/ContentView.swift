import SwiftUI

struct ContentView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var selection: Tab = .hive
    @State private var showLaunchAnimation: Bool = !LaunchState.shared.didShowLaunchAnimation

    enum Tab: Hashable {
        case hive, honey, farm, you
    }

    var body: some View {
        ZStack {
            Group {
                if services.authService.isAuthenticated {
                    // Main tabs are always rendered underneath.
                    // Onboarding is an overlay on top. When onboarding
                    // finishes, the overlay fades out as a single unit
                    // (.transition(.opacity)) so the tab bar and
                    // HiveTabView UI cross-fade in instead of snapping
                    // in.
                    ZStack {
                        mainTabs

                        if !services.hasCompletedOnboarding {
                            OnboardingFlow()
                                .transition(.opacity)
                        }
                    }
                } else {
                    AuthFlowView()
                }
            }

            if showLaunchAnimation {
                LaunchAnimationView {
                    LaunchState.shared.didShowLaunchAnimation = true
                    withAnimation(.easeOut(duration: 0.35)) {
                        showLaunchAnimation = false
                    }
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
    }

    private var mainTabs: some View {
        TabView(selection: $selection) {
            HiveTabView()
                .tabItem { Label("Hive", systemImage: "hexagon.fill") }
                .tag(Tab.hive)

            HoneyTabView()
                .tabItem { Label("Honey", systemImage: "drop.fill") }
                .tag(Tab.honey)

            FarmTabView()
                .tabItem { Label("Farm", systemImage: "leaf.fill") }
                .tag(Tab.farm)

            YouTabView()
                .tabItem { Label("You", systemImage: "person.fill") }
                .tag(Tab.you)
        }
        .tint(BeesColors.honey500)
    }
}

/// Tracks one-shot per-cold-launch state. The launch animation should
/// only play on the first ContentView render after a cold start; if
/// SwiftUI ever re-creates ContentView mid-session (rare but possible),
/// the flag here keeps it from replaying.
final class LaunchState {
    static let shared = LaunchState()
    var didShowLaunchAnimation = false
    private init() {}
}

#Preview("Main app") {
    ContentView()
        .environment(ServiceContainer.preview())
}

#Preview("Fresh launch") {
    ContentView()
        .environment(ServiceContainer.freshLaunch())
}
