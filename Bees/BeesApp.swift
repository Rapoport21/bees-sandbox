import SwiftUI

@main
struct BeesApp: App {
    @State private var services = ServiceContainer.preview()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(services)
                .preferredColorScheme(.light)
        }
    }
}
