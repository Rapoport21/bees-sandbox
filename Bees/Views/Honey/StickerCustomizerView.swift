import SwiftUI

struct StickerCustomizerView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.dismiss) private var dismiss

    @State private var workingDesign: StickerDesign = StickerDesign.empty
    @State private var saveAsFavorite: Bool = false
    @State private var favoriteName: String = ""
    @State private var showLockConfirm = false
    @State private var didSave = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BeesSpacing.l) {
                    deadlineBanner
                    JarPreview(design: workingDesign, size: 200)
                        .padding(.top, BeesSpacing.s)
                    baseDesignSection
                    if services.currentTier.canCustomizeText {
                        customTextSection
                    } else {
                        upgradeTeaser
                    }
                    if services.currentTier.canPickFont {
                        fontSection
                    }
                    if services.currentTier.canPickColor {
                        colorSection
                    }
                    if services.currentTier.canSaveFavorites {
                        favoriteToggle
                    }
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, BeesSpacing.m)
            }
            .background(BeesColors.honey100.opacity(0.4).ignoresSafeArea())
            .safeAreaInset(edge: .bottom) {
                footerBar
            }
            .navigationTitle("Customize sticker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(BeesColors.charcoal600)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveDraft()
                    } label: {
                        if didSave {
                            Label("Saved", systemImage: "checkmark")
                        } else {
                            Text("Save")
                        }
                    }
                    .tint(BeesColors.honey500)
                }
            }
            .onAppear {
                if let active = services.shipmentService.activeShipment {
                    workingDesign = active.design
                }
            }
            .alert("Lock this design?", isPresented: $showLockConfirm) {
                Button("Lock it in", role: .destructive) {
                    services.shipmentService.updateActiveDesign(workingDesign)
                    services.shipmentService.lockActiveDesign()
                    dismiss()
                }
                Button("Not yet", role: .cancel) { }
            } message: {
                Text("Once locked, your design is final. We can't change it after this.")
            }
        }
    }

    // MARK: - Sections

    private var deadlineBanner: some View {
        HStack(spacing: BeesSpacing.xs) {
            Image(systemName: "clock.fill")
                .foregroundStyle(BeesColors.honey500)
            Text(deadlineText)
                .font(BeesType.captionM)
                .foregroundStyle(BeesColors.charcoal900)
            Spacer()
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.vertical, BeesSpacing.s)
        .background(BeesColors.honey100, in: RoundedRectangle(cornerRadius: BeesRadius.md))
    }

    private var baseDesignSection: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            SectionHeader(
                title: "Base design",
                trailing: "\(currentBaseDesignIndex + 1) of \(StickerBaseDesign.catalog.count)"
            )
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BeesSpacing.s) {
                    ForEach(StickerBaseDesign.catalog) { design in
                        Button {
                            workingDesign.baseDesignId = design.id
                            didSave = false
                        } label: {
                            VStack(spacing: BeesSpacing.xxs) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: BeesRadius.sm)
                                        .fill(design.backgroundColor)
                                    Circle()
                                        .fill(design.accentColor.opacity(0.5))
                                        .frame(width: 24, height: 24)
                                }
                                .frame(width: 80, height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BeesRadius.sm)
                                        .stroke(workingDesign.baseDesignId == design.id ? BeesColors.honey500 : .clear,
                                                lineWidth: 3)
                                )
                                Text(design.name)
                                    .font(BeesType.captionS)
                                    .foregroundStyle(BeesColors.charcoal600)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var customTextSection: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            SectionHeader(title: "Custom text")
            textLine(line: $workingDesign.line1, label: "Line 1")
            textLine(line: $workingDesign.line2, label: "Line 2")
            textLine(line: $workingDesign.line3, label: "Line 3")
        }
    }

    private func textLine(line: Binding<String>, label: String) -> some View {
        VStack(alignment: .leading, spacing: BeesSpacing.xxs) {
            TextField(label, text: line)
                .textFieldStyle(.roundedBorder)
                .onChange(of: line.wrappedValue) { _, newValue in
                    if newValue.count > StickerDesign.lineLimit {
                        line.wrappedValue = String(newValue.prefix(StickerDesign.lineLimit))
                    }
                    didSave = false
                }
            Text("\(label) · \(line.wrappedValue.count)/\(StickerDesign.lineLimit)")
                .font(BeesType.captionS)
                .foregroundStyle(BeesColors.charcoal600)
        }
    }

    private var fontSection: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            SectionHeader(title: "Font")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BeesSpacing.s) {
                    ForEach(StickerFont.catalog) { font in
                        Button {
                            workingDesign.fontId = font.id
                            didSave = false
                        } label: {
                            VStack(spacing: BeesSpacing.xxs) {
                                Text("Aa")
                                    .font(font.font)
                                    .frame(width: 56, height: 56)
                                    .background(BeesColors.comb500.opacity(0.5),
                                                in: RoundedRectangle(cornerRadius: BeesRadius.sm))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: BeesRadius.sm)
                                            .stroke(workingDesign.fontId == font.id ? BeesColors.honey500 : .clear,
                                                    lineWidth: 3)
                                    )
                                Text(font.name)
                                    .font(BeesType.captionS)
                                    .foregroundStyle(BeesColors.charcoal600)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            SectionHeader(title: "Color")
            HStack(spacing: BeesSpacing.m) {
                ForEach(StickerColor.catalog) { color in
                    Button {
                        workingDesign.colorId = color.id
                        didSave = false
                    } label: {
                        Circle()
                            .fill(color.color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(workingDesign.colorId == color.id ? BeesColors.charcoal900 : .clear,
                                            lineWidth: 2)
                                    .padding(-4)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var favoriteToggle: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.s) {
            Toggle(isOn: $saveAsFavorite) {
                Label("Save as favorite", systemImage: "heart.fill")
                    .foregroundStyle(BeesColors.charcoal900)
            }
            .tint(BeesColors.honey500)

            if saveAsFavorite {
                TextField("Nickname", text: $favoriteName)
                    .textFieldStyle(.roundedBorder)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: saveAsFavorite)
    }

    private var upgradeTeaser: some View {
        VStack(alignment: .leading, spacing: BeesSpacing.xs) {
            Text("UPGRADE TO CUSTOMIZE")
                .font(BeesType.captionS)
                .foregroundStyle(BeesColors.charcoal600)
                .tracking(1)
            Text("Custom text, fonts, and colors come with Forager.")
                .font(BeesType.bodyM)
                .foregroundStyle(BeesColors.charcoal900)
            Button("See plans") { }
                .buttonStyle(.beesGhost)
        }
        .padding(BeesSpacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BeesColors.honey100, in: RoundedRectangle(cornerRadius: BeesRadius.md))
    }

    private var footerBar: some View {
        HStack(spacing: BeesSpacing.s) {
            Button("Save draft") {
                saveDraft()
            }
            .buttonStyle(.beesSecondary)

            Button("Lock design") {
                showLockConfirm = true
            }
            .buttonStyle(.beesPrimary)
        }
        .padding(.horizontal, BeesSpacing.m)
        .padding(.vertical, BeesSpacing.s + 4)
        .background(.regularMaterial)
    }

    // MARK: - Helpers

    private var currentBaseDesignIndex: Int {
        StickerBaseDesign.catalog.firstIndex { $0.id == workingDesign.baseDesignId } ?? 0
    }

    private var deadlineText: String {
        guard let shipment = services.shipmentService.activeShipment else {
            return "Locks 7 days before ship"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let days = max(0, Calendar.current.dateComponents([.day], from: Date(), to: shipment.lockInDate).day ?? 0)
        return "Locks in \(days) days · Ships \(formatter.string(from: shipment.scheduledShipDate))"
    }

    private func saveDraft() {
        services.shipmentService.updateActiveDesign(workingDesign)
        if saveAsFavorite, !favoriteName.isEmpty {
            services.stickerService.save(workingDesign, nickname: favoriteName)
            saveAsFavorite = false
            favoriteName = ""
        }
        didSave = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run { didSave = false }
        }
    }
}

#Preview {
    StickerCustomizerView()
        .environment(ServiceContainer.preview())
}
