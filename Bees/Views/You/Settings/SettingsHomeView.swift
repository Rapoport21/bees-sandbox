import SwiftUI

struct SettingsHomeView: View {
    @Environment(ServiceContainer.self) private var services

    var body: some View {
        List {
            Section {
                NavigationLink { NotificationSettingsView() } label: {
                    Label("Notifications", systemImage: "bell.fill")
                }
                NavigationLink { DisplaySettingsView() } label: {
                    Label("Display", systemImage: "circle.lefthalf.filled")
                }
                NavigationLink { HiveSettingsView() } label: {
                    Label("Hive settings", systemImage: "hexagon.fill")
                }
                NavigationLink { TutorialSettingsView() } label: {
                    Label("Tutorial", systemImage: "questionmark.bubble.fill")
                }
                NavigationLink { AddressesView() } label: {
                    Label("Addresses", systemImage: "shippingbox.fill")
                }
            }
            Section {
                NavigationLink { AccountSettingsView() } label: {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
                NavigationLink { HelpSupportView() } label: {
                    Label("Help & Support", systemImage: "questionmark.circle.fill")
                }
            }
            Section {
                NavigationLink { LegalView() } label: {
                    Label("Legal", systemImage: "doc.text.fill")
                }
                NavigationLink { AboutView() } label: {
                    Label("About", systemImage: "info.circle.fill")
                }
            }
            Section {
                Button {
                    services.authService.signOut()
                } label: {
                    Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(BeesColors.error500)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsHomeView()
    }
    .environment(ServiceContainer.preview())
}
