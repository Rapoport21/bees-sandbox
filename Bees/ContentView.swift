import SwiftUI

struct ContentView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var selection: Tab = .hive

    enum Tab: Hashable {
        case hive, honey, farm, you
    }

    var body: some View {
        Group {
            if services.authService.isAuthenticated {
                // Main tabs are always rendered underneath. Onboarding is
                // an overlay on top. When onboarding finishes, the overlay
                // fades out as a single unit (.transition(.opacity)) so the
                // tab bar and HiveTabView UI cross-fade in instead of
                // snapping in.
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
        .task {
            // Slight delay so the haptic lands as the first content
            // settles in, not while iOS is still tearing down the
            // launch screen.
            try? await Task.sleep(for: .milliseconds(180))
            HapticManager.shared.playLaunchSequence()
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

#Preview("Main app") {
    ContentView()
        .environment(ServiceContainer.preview())
}

#Preview("Fresh launch") {
    ContentView()
        .environment(ServiceContainer.freshLaunch())
}
