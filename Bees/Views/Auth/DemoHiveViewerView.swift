import SwiftUI

struct DemoHiveViewerView: View {
    var onSignUp: () -> Void
    @State private var showSoftSignup = false
    @State private var bannerVisible = false
    @State private var simulatedTakeoffs = 1_142
    @State private var simulatedLandings = 1_138
    @State private var simulatedTemp = 88.0

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: BeesSpacing.l) {
                    chrome
                    videoZone
                    hivePill
                    statStrip
                    activityCard
                    jarTeaser
                }
                .padding(.horizontal, BeesSpacing.m)
                .padding(.bottom, BeesSpacing.xxl + BeesSpacing.l)
            }
            .background(BeesColors.surfacePage.ignoresSafeArea())

            if bannerVisible {
                bannerView
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            FloatingFAB(onTap: onSignUp)
                .padding(.bottom, BeesSpacing.l)
                .padding(.trailing, BeesSpacing.m)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Adopt now") { onSignUp() }
                    .tint(BeesColors.honey500)
            }
        }
        .sheet(isPresented: $showSoftSignup) {
            SoftSignupSheet(context: "Sign in to watch your own hive in real time.",
                            onSignIn: onSignUp)
                .presentationDetents([.medium])
        }
        .task {
            try? await Task.sleep(for: .seconds(45))
            await MainActor.run {
                withAnimation(.spring(duration: 0.4)) { bannerVisible = true }
            }
        }
        .onAppear { startSimulating() }
    }

    private var chrome: some View {
        HStack {
            HStack(spacing: BeesSpacing.xxs) {
                Circle().fill(BeesColors.honey500).frame(width: 6, height: 6)
                Text("DEMO")
                    .font(BeesType.captionS)
                    .tracking(1)
                    .foregroundStyle(BeesColors.charcoal900)
            }
            .padding(.horizontal, BeesSpacing.xs)
            .padding(.vertical, BeesSpacing.xxs)
            .background(BeesColors.honey100, in: Capsule())
            Text("Sample hive · not your data")
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal600)
            Spacer()
        }
    }

    private var videoZone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: BeesRadius.lg)
                .fill(BeesColors.charcoal900)
                .frame(height: 200)
            VStack(spacing: BeesSpacing.xs) {
                Image(systemName: "video.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(BeesColors.honey500)
                Text("Demo loop")
                    .font(BeesType.bodyM)
                    .foregroundStyle(.white.opacity(0.8))
            }
            VStack {
                HStack {
                    Spacer()
                    Text("DEMO")
                        .font(.system(size: 9, weight: .heavy))
                        .tracking(2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, BeesSpacing.xs)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.4), in: Capsule())
                }
                Spacer()
            }
            .padding(BeesSpacing.s)
        }
        .onTapGesture { showSoftSignup = true }
    }

    private var hivePill: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Demo Hive")
                    .font(BeesType.displayM)
                Text("Sample Farm · CA")
                    .font(BeesType.captionM)
                    .foregroundStyle(BeesColors.charcoal600)
            }
            Spacer()
            HealthPill(health: .thriving)
        }
        .onTapGesture { showSoftSignup = true }
    }

    private var statStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BeesSpacing.s) {
                Button { showSoftSignup = true } label: {
                    StatTile(icon: "thermometer", value: String(format: "%.0f", simulatedTemp), unit: "°F", trend: .up)
                }
                Button { showSoftSignup = true } label: {
                    StatTile(icon: "humidity", value: "58", unit: "%", trend: .flat)
                }
                Button { showSoftSignup = true } label: {
                    StatTile(icon: "scalemass", value: "43", unit: "lb", trend: .up)
                }
                Button { showSoftSignup = true } label: {
                    StatTile(icon: "ant", value: "54k", unit: "BEES", trend: .up)
                }
                Button { showSoftSignup = true } label: {
                    StatTile(icon: "arrow.up.forward", value: "1,1k", unit: "OUT", trend: .up)
                }
            }
            .buttonStyle(.plain)
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: "lock.fill")
                .font(.system(size: 10))
                .foregroundStyle(BeesColors.charcoal600)
                .padding(BeesSpacing.xxs)
        }
    }

    private var activityCard: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            Text("ACTIVITY RIGHT NOW (simulated)")
                .font(BeesType.captionM)
                .tracking(1)
                .foregroundStyle(BeesColors.charcoal600)

            HStack(spacing: BeesSpacing.xl) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: BeesSpacing.xxs) {
                        Text("↑")
                            .font(BeesType.headingM)
                            .foregroundStyle(BeesColors.honey500)
                        Text("\(simulatedTakeoffs)")
                            .font(BeesType.monoL)
                            .contentTransition(.numericText())
                    }
                    Text("Take-offs").font(BeesType.captionM).foregroundStyle(BeesColors.charcoal600)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: BeesSpacing.xxs) {
                        Text("↓")
                            .font(BeesType.headingM)
                            .foregroundStyle(BeesColors.honey500)
                        Text("\(simulatedLandings)")
                            .font(BeesType.monoL)
                            .contentTransition(.numericText())
                    }
                    Text("Landings").font(BeesType.captionM).foregroundStyle(BeesColors.charcoal600)
                }
            }
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [BeesColors.surfaceWarmHighlight, BeesColors.surfaceMuted],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: BeesRadius.lg))
        .onTapGesture { showSoftSignup = true }
    }

    private var jarTeaser: some View {
        VStack(spacing: BeesSpacing.s) {
            Text("DESIGN A JAR LIKE THIS")
                .font(BeesType.captionM)
                .tracking(1)
                .foregroundStyle(BeesColors.charcoal600)
            HStack(spacing: BeesSpacing.l) {
                JarPreview(design: Fixtures.demoActiveDesign, size: 100)
                VStack(alignment: .leading, spacing: BeesSpacing.xs) {
                    Text("Customize one yourself →")
                        .font(BeesType.bodyM)
                        .foregroundStyle(BeesColors.charcoal900)
                    HStack(spacing: BeesSpacing.xxs) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Sign up to design")
                    }
                    .font(BeesType.captionS)
                    .foregroundStyle(BeesColors.charcoal600)
                }
                Spacer()
            }
        }
        .padding(BeesSpacing.m)
        .background(BeesColors.surfaceCard, in: RoundedRectangle(cornerRadius: BeesRadius.lg))
        .onTapGesture { showSoftSignup = true }
    }

    private var bannerView: some View {
        Button { onSignUp() } label: {
            HStack {
                Image(systemName: "sparkles").foregroundStyle(BeesColors.honey500)
                Text("Loving it? Get your own hive →")
                    .font(BeesType.bodyM.weight(.semibold))
                    .foregroundStyle(BeesColors.charcoal900)
                Spacer()
                Button {
                    withAnimation { bannerVisible = false }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(BeesColors.charcoal600)
                }
            }
            .padding(BeesSpacing.s)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BeesRadius.md))
            .padding(.horizontal, BeesSpacing.m)
        }
        .buttonStyle(.plain)
    }

    private func startSimulating() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run {
                    simulatedTakeoffs += Int.random(in: 0...4)
                    simulatedLandings += Int.random(in: 0...4)
                    simulatedTemp += Double.random(in: -0.4...0.4)
                    simulatedTemp = min(max(simulatedTemp, 84), 94)
                }
            }
        }
    }
}

private struct FloatingFAB: View {
    var onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            HStack(spacing: BeesSpacing.xs) {
                Image(systemName: "sparkles")
                Text("Adopt your own hive")
            }
            .font(BeesType.bodyM.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, BeesSpacing.m)
            .padding(.vertical, BeesSpacing.s + 2)
            .background(BeesColors.honey500, in: Capsule())
            .shadow(color: BeesColors.honey500.opacity(0.4), radius: 12, y: 4)
        }
    }
}

struct SoftSignupSheet: View {
    let context: String
    var onSignIn: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: BeesSpacing.l) {
            Capsule()
                .fill(BeesColors.charcoal300)
                .frame(width: 36, height: 4)
                .padding(.top, BeesSpacing.xs)

            Image(systemName: "lock.fill")
                .font(.system(size: 36))
                .foregroundStyle(BeesColors.honey500)

            Text("Sign in to unlock")
                .font(BeesType.displayM)

            Text(context)
                .font(BeesType.bodyM)
                .foregroundStyle(BeesColors.charcoal600)
                .multilineTextAlignment(.center)

            Button("Sign in") {
                dismiss()
                onSignIn()
            }
            .buttonStyle(.beesPrimary)

            Button("Keep watching the demo") { dismiss() }
                .buttonStyle(.beesGhost)
        }
        .padding(BeesSpacing.l)
    }
}

#Preview {
    NavigationStack {
        DemoHiveViewerView(onSignUp: {})
    }
    .environment(ServiceContainer.freshLaunch())
}
