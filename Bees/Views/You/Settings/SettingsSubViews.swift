import SwiftUI

// MARK: - Notifications

struct NotificationSettingsView: View {
    @State private var stickerReminders = true
    @State private var shipmentEvents = true
    @State private var trialEvents = true
    @State private var failedPayment = true
    @State private var hiveAnomaly = false
    @State private var weeklyDigest = true
    @State private var newDesigns = false
    @State private var achievements = false
    @State private var harvestDay = true
    @State private var marketing = false

    var body: some View {
        Form {
            Section("Shipments") {
                Toggle("Sticker reminders", isOn: $stickerReminders)
                Toggle("Shipment events", isOn: $shipmentEvents)
                Toggle("New designs available", isOn: $newDesigns)
            }
            Section("Hive") {
                Toggle("Hive anomaly alerts", isOn: $hiveAnomaly)
                Toggle("Weekly digest email", isOn: $weeklyDigest)
                Toggle("Harvest day at your farm", isOn: $harvestDay)
                Toggle("Achievements", isOn: $achievements)
            }
            Section {
                Toggle("Trial events", isOn: $trialEvents)
                Toggle("Failed payment", isOn: $failedPayment)
                Toggle("Marketing & promos", isOn: $marketing)
            } header: {
                Text("Account")
            } footer: {
                Text("System-level push permission is managed in iOS Settings.")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Display

struct DisplaySettingsView: View {
    @State private var theme: Theme = .system
    @State private var temperature: TemperatureUnit = .auto
    @State private var weight: WeightUnit = .auto

    enum Theme: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }
    enum TemperatureUnit: String, CaseIterable, Identifiable {
        case auto, fahrenheit, celsius
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .auto: return "Auto"
            case .fahrenheit: return "°F"
            case .celsius: return "°C"
            }
        }
    }
    enum WeightUnit: String, CaseIterable, Identifiable {
        case auto, lb, kg
        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }

    var body: some View {
        Form {
            Section("Theme") {
                Picker("Theme", selection: $theme) {
                    ForEach(Theme.allCases) { Text($0.displayName).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Section("Temperature") {
                Picker("Temperature", selection: $temperature) {
                    ForEach(TemperatureUnit.allCases) { Text($0.displayName).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Section("Weight") {
                Picker("Weight", selection: $weight) {
                    ForEach(WeightUnit.allCases) { Text($0.displayName).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("Display")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Hive

struct HiveSettingsView: View {
    @State private var comparison = false
    @State private var showHiveMap = false
    @State private var multiHive = false
    @State private var defaultAudio = false
    @State private var defaultQuality: VideoQuality = .auto
    @State private var liveActivity = false

    enum VideoQuality: String, CaseIterable, Identifiable {
        case auto, sd, hd
        var id: String { rawValue }
        var displayName: String { rawValue == "auto" ? "Auto" : rawValue.uppercased() }
    }

    var body: some View {
        Form {
            Section("Privacy") {
                Toggle("Hive comparison (anonymized)", isOn: $comparison)
            }
            Section {
                Toggle("Show map of available hives", isOn: $showHiveMap)
                Toggle("Allow multiple hives", isOn: $multiHive)
            } header: {
                Text("Hive map (preview)")
            } footer: {
                Text("These are dev-preview toggles. Both will be enabled later.")
            }
            Section("Video") {
                Toggle("Audio on by default", isOn: $defaultAudio)
                Picker("Default quality", selection: $defaultQuality) {
                    ForEach(VideoQuality.allCases) { Text($0.displayName).tag($0) }
                }
            }
            Section("Live Activity") {
                Toggle("Hive activity Live Activity", isOn: $liveActivity)
            }
        }
        .navigationTitle("Hive settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tutorial

struct TutorialSettingsView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var showOnLaunch = true

    var body: some View {
        Form {
            Section {
                Button {
                    services.resetOnboarding()
                } label: {
                    Label("Replay onboarding", systemImage: "arrow.clockwise")
                        .foregroundStyle(BeesColors.honey500)
                }
            }
            Section {
                Toggle("Show tutorial on launch", isOn: $showOnLaunch)
            } header: {
                Text("Developer")
            } footer: {
                Text("This dev toggle will be removed before public release.")
            }
        }
        .navigationTitle("Tutorial")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Addresses

struct AddressesView: View {
    @State private var addresses: [SavedAddress] = [
        .init(label: "Home", line: "123 Maple Lane, Apt 4, Sonoma CA 95476"),
    ]

    struct SavedAddress: Identifiable, Hashable {
        let id = UUID()
        var label: String
        var line: String
    }

    var body: some View {
        List {
            Section("Primary shipping") {
                ForEach(addresses) { addr in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(addr.label).font(BeesType.bodyM.weight(.semibold))
                        Text(addr.line).font(BeesType.captionM).foregroundStyle(BeesColors.charcoal600)
                    }
                }
            }
            Section {
                Button {
                } label: {
                    Label("Add address", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Addresses")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Account

struct AccountSettingsView: View {
    @Environment(ServiceContainer.self) private var services
    @State private var showDeleteConfirm = false

    var body: some View {
        Form {
            Section("Profile") {
                row("Name", value: services.authService.displayName)
                row("Email", value: services.authService.email ?? "—")
                row("Sign-in method", value: services.authService.provider?.displayName ?? "—")
            }
            Section {
                Button {
                } label: {
                    Label("Change password", systemImage: "key.fill")
                }
                Button {
                } label: {
                    Label("Privacy & data", systemImage: "lock.shield.fill")
                }
                Button {
                } label: {
                    Label("Connected logins", systemImage: "link")
                }
            }
            Section {
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Label("Delete account", systemImage: "trash.fill")
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete account?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Continue to delete", role: .destructive) {
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your account will enter a 30-day grace period before being permanently deleted. You can restore it any time before then by signing in again.")
        }
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(BeesColors.charcoal600)
            Spacer()
            Text(value).foregroundStyle(BeesColors.charcoal900)
        }
    }
}

// MARK: - Help

struct HelpSupportView: View {
    var body: some View {
        List {
            Section("Common questions") {
                NavigationLink("How does Bees work?") {
                    FAQArticleView(title: "How does Bees work?",
                                   text: "You adopt a real beehive on a partner farm. We give you live video, real-time stats, and ship custom-stickered honey to your door on a cadence based on your tier.")
                }
                NavigationLink("When does my jar ship?") {
                    FAQArticleView(title: "When does my jar ship?",
                                   text: "Your shipment cadence depends on your tier. Pollinator: every 3 months. Forager: every month. Queen Keeper: 2 jars every month.")
                }
                NavigationLink("How do I customize my sticker?") {
                    FAQArticleView(title: "How do I customize my sticker?",
                                   text: "Open the Honey tab, tap Customize sticker on your active shipment. Pick a base design, add custom text, font, and color. Your design locks in 7 days before ship.")
                }
                NavigationLink("Can I gift Bees to someone?") {
                    FAQArticleView(title: "Gifting",
                                   text: "Yes! Forager and Queen Keeper members can send a jar of honey as a one-time gift. Queen Keeper members can also gift a 3, 6, or 12 month subscription.")
                }
                NavigationLink("How do I cancel?") {
                    FAQArticleView(title: "Canceling",
                                   text: "You → Subscription → Cancel subscription. We'll walk you through your options. You'll keep video access until the end of your paid period; the next jar won't ship.")
                }
            }
            Section {
                Button {
                } label: {
                    Label("Email support", systemImage: "envelope.fill")
                        .foregroundStyle(BeesColors.honey500)
                }
                Button {
                } label: {
                    Label("Report a problem", systemImage: "exclamationmark.bubble.fill")
                        .foregroundStyle(BeesColors.honey500)
                }
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQArticleView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BeesSpacing.l) {
                Text(title)
                    .font(BeesType.displayL)
                Text(text)
                    .font(BeesType.bodyL)
                    .foregroundStyle(BeesColors.charcoal900)
            }
            .padding(BeesSpacing.m)
            .padding(.bottom, BeesSpacing.xl)
        }
        .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Legal

struct LegalView: View {
    var body: some View {
        List {
            NavigationLink("Terms of Service") {
                LegalTextView(title: "Terms of Service", text: legalPlaceholder)
            }
            NavigationLink("Privacy Policy") {
                LegalTextView(title: "Privacy Policy", text: legalPlaceholder)
            }
        }
        .navigationTitle("Legal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var legalPlaceholder: String {
        "This is placeholder legal copy. Final terms and privacy policy will be authored by counsel before public launch.\n\nThis app uses subscription billing through Apple's In-App Purchase. Cancellation, refunds, and dispute handling follow Apple's policies. We collect minimal personal information necessary to ship physical products and maintain your account."
    }
}

struct LegalTextView: View {
    let title: String
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .font(BeesType.bodyL)
                .foregroundStyle(BeesColors.charcoal900)
                .padding(BeesSpacing.m)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - About

struct AboutView: View {
    var body: some View {
        List {
            Section {
                row("Version", value: "2.0")
                row("Build", value: "1")
                row("Platform", value: "iOS")
            }
            Section("Credits") {
                Text("Made with bees in mind.")
                    .font(BeesType.bodyM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(BeesColors.charcoal600)
            Spacer()
            Text(value).foregroundStyle(BeesColors.charcoal900)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsHomeView()
    }
    .environment(ServiceContainer.preview())
}
