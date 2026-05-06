import SwiftUI

struct ContentView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var selection: Tab = .hive

    enum Tab: Hashable {
        case hive, honey, farm, you
    }

    var body: some View {
        ZStack {
            if services.authService.isAuthenticated {
                // Both onboarding and main app stay mounted once
                // authenticated. They cross-fade by opacity. This keeps
                // HiveTabView's LoopingVideoPlayer alive across the
                // hand-off, so the video doesn't reload on transition.
                ZStack {
                    mainTabs
                        .opacity(services.hasCompletedOnboarding ? 1 : 0)
                        .allowsHitTesting(services.hasCompletedOnboarding)

                    OnboardingFlow()
                        .opacity(services.hasCompletedOnboarding ? 0 : 1)
                        .allowsHitTesting(!services.hasCompletedOnboarding)
                }
                .animation(.easeInOut(duration: 0.55), value: services.hasCompletedOnboarding)
                .transition(.opacity)
            } else {
                AuthFlowView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: services.authService.isAuthenticated)
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
