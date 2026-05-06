import SwiftUI

@main
struct BeesApp: App {
    @State private var services = ServiceContainer.freshLaunch()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(services)
                .preferredColorScheme(services.theme.colorScheme)
        }
    }
}
