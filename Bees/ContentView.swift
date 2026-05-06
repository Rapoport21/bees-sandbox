import SwiftUI

struct ContentView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var selection: Tab = .hive

    enum Tab: Hashable {
        case hive, honey, farm, you
    }

    var body: some View {
        if !services.hasCompletedOnboarding {
            OnboardingFlow()
        } else {
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
}

#Preview("Main app") {
    ContentView()
        .environment(ServiceContainer.preview())
}

#Preview("Fresh launch") {
    ContentView()
        .environment(ServiceContainer.freshLaunch())
}
