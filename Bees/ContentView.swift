import SwiftUI

struct ContentView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var selection: Tab = .hive

    enum Tab: Hashable {
        case hive, honey, farm, you
    }

    private enum Screen: String { case auth, onboarding, main }

    private var currentScreen: Screen {
        if !services.authService.isAuthenticated { return .auth }
        if !services.hasCompletedOnboarding      { return .onboarding }
        return .main
    }

    var body: some View {
        ZStack {
            Group {
                switch currentScreen {
                case .auth:       AuthFlowView()
                case .onboarding: OnboardingFlow()
                case .main:       mainTabs
                }
            }
            .id(currentScreen.rawValue)
        }
        // No animation between screens — the morph in HiveRevealView
        // ends with a layout that exactly matches HiveTabView, so a
        // hard cut is invisible (and avoids the cross-fade overlap
        // where two copies of the hive content used to ghost together).
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
