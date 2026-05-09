import SwiftUI
import CoreText

@main
struct BeesApp: App {
    @State private var services = ServiceContainer.freshLaunch()

    init() {
        BundledFonts.registerAll()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(services)
                .preferredColorScheme(services.theme.colorScheme)
        }
    }
}

/// Runtime font registration. We bundle Calistoga as a folder
/// reference (Fonts/Calistoga-Regular.ttf) and register it at
/// startup with CoreText, so SwiftUI's Font.custom("Calistoga-Regular")
/// resolves. This avoids needing UIAppFonts in Info.plist —
/// Xcode's INFOPLIST_KEY_* doesn't reliably emit UIAppFonts arrays.
enum BundledFonts {
    static func registerAll() {
        let names = ["Calistoga-Regular"]
        for name in names {
            register(named: name)
        }
    }

    private static func register(named name: String) {
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "ttf",
            subdirectory: "Fonts"
        ) else {
            // Folder reference might flatten on some build configurations;
            // try without subdirectory too.
            if let flatURL = Bundle.main.url(forResource: name, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(flatURL as CFURL, .process, nil)
            }
            return
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
