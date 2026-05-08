import SwiftUI

/// Watch-Studio-style jar configurator. Pushed in the Honey tab's
/// NavigationStack so the tab bar stays visible. The design carousel
/// is the only swipeable axis in v1; color and font use the design's
/// defaults (deferred — see CLAUDE.md). Text is edited inline by
/// tapping a line on the sticker.
struct JarStudioView: View {
    @Environment(ServiceContainer.self) private var services
    @Environment(\.dismiss) private var dismiss

    @State private var workingDesign: StickerDesign = .empty
    @State private var selectedIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showLockConfirm = false
    @FocusState private var focusedLine: TextLine?

    enum TextLine: Hashable { case line1, line2, line3 }

    private var catalog: [StickerBaseDesign] { StickerBaseDesign.catalog }
    private var currentBase: StickerBaseDesign { catalog[selectedIndex] }

    var body: some View {
        VStack(spacing: BeesSpacing.l) {
            deadlinePill
                .padding(.top, BeesSpacing.s)

            jarCarousel
                .frame(maxHeight: .infinity)

            captionBlock

            lockButton
                .padding(.horizontal, BeesSpacing.m)
                .padding(.bottom, BeesSpacing.s)
        }
        .background(BeesColors.surfacePage.ignoresSafeArea())
        .navigationTitle("Customize sticker")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: syncFromActiveShipment)
        .onChange(of: selectedIndex) { _, _ in
            workingDesign.baseDesignId = catalog[selectedIndex].id
            services.shipmentService.updateActiveDesign(workingDesign)
        }
        .onChange(of: workingDesign) { _, newValue in
            services.shipmentService.updateActiveDesign(newValue)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedLine = nil }
                    .tint(BeesColors.honey500)
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

    // MARK: - Deadline pill (subtle top indicator)

    private var deadlinePill: some View {
        HStack(spacing: BeesSpacing.xxs) {
            Image(systemName: "clock")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(BeesColors.honey500)
            Text(deadlineText)
                .font(BeesType.captionS)
                .foregroundStyle(BeesColors.charcoal600)
        }
        .padding(.horizontal, BeesSpacing.s)
        .padding(.vertical, BeesSpacing.xxs + 2)
        .background(BeesColors.surfaceWarmHighlight, in: Capsule())
    }

    private var deadlineText: String {
        guard let s = services.shipmentService.activeShipment else {
            return "Locks 7 days before ship"
        }
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        let days = max(0, Calendar.current.dateComponents([.day], from: Date(), to: s.lockInDate).day ?? 0)
        return "\(days) days to lock · ships \(f.string(from: s.scheduledShipDate))"
    }

    // MARK: - Carousel

    private var jarCarousel: some View {
        GeometryReader { geo in
            let cardWidth = geo.size.width
            ZStack {
                ForEach(catalog.indices, id: \.self) { idx in
                    let raw = CGFloat(idx - selectedIndex) + dragOffset / cardWidth
                    let absDistance = abs(raw)
                    let isCenter = idx == selectedIndex

                    Group {
                        if isCenter {
                            EditableStudioJar(
                                design: previewDesign(for: catalog[idx]),
                                line1: $workingDesign.line1,
                                line2: $workingDesign.line2,
                                line3: $workingDesign.line3,
                                focusedLine: $focusedLine
                            )
                        } else {
                            StaticStudioJar(design: previewDesign(for: catalog[idx]))
                        }
                    }
                    .offset(x: raw * cardWidth * 0.78)
                    .scaleEffect(max(0.62, 1.0 - absDistance * 0.20))
                    .opacity(max(0.0, 1.0 - absDistance * 0.55))
                    .zIndex(-absDistance)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(carouselDrag(cardWidth: cardWidth))
        }
    }

    private func carouselDrag(cardWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let v = value.predictedEndTranslation.width
                let threshold = cardWidth / 6
                var newIdx = selectedIndex
                if v < -threshold && newIdx < catalog.count - 1 {
                    newIdx += 1
                } else if v > threshold && newIdx > 0 {
                    newIdx -= 1
                }
                withAnimation(.snappy(duration: 0.42, extraBounce: 0.08)) {
                    selectedIndex = newIdx
                    dragOffset = 0
                }
            }
    }

    // MARK: - Caption

    private var captionBlock: some View {
        VStack(spacing: BeesSpacing.xxs) {
            Text(currentBase.name)
                .font(BeesType.displayM)
                .foregroundStyle(BeesColors.charcoal900)
                .id(currentBase.id)
                .transition(.opacity.combined(with: .move(edge: .bottom)))

            Text("\(selectedIndex + 1) of \(catalog.count) · swipe to browse")
                .font(BeesType.captionS)
                .tracking(0.6)
                .foregroundStyle(BeesColors.charcoal600)
        }
        .animation(.snappy(duration: 0.3), value: selectedIndex)
    }

    // MARK: - CTA

    private var lockButton: some View {
        Button("Lock design") {
            showLockConfirm = true
        }
        .buttonStyle(.beesPrimary)
    }

    // MARK: - Helpers

    private func previewDesign(for base: StickerBaseDesign) -> StickerDesign {
        var d = workingDesign
        d.baseDesignId = base.id
        return d
    }

    private func syncFromActiveShipment() {
        guard let active = services.shipmentService.activeShipment else { return }
        workingDesign = active.design
        if let idx = catalog.firstIndex(where: { $0.id == active.design.baseDesignId }) {
            selectedIndex = idx
        }
    }
}

// MARK: - Editable jar (center of carousel)

private struct EditableStudioJar: View {
    let design: StickerDesign
    @Binding var line1: String
    @Binding var line2: String
    @Binding var line3: String
    var focusedLine: FocusState<JarStudioView.TextLine?>.Binding

    var body: some View {
        StudioJarChrome(design: design) {
            VStack(spacing: BeesSpacing.xxs) {
                Image(systemName: design.baseDesign.accentIcon)
                    .font(.system(size: 16))
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.7))

                Text(design.baseDesign.name.uppercased())
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(2.5)
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.7))

                rule

                editableLine($line1, focus: .line1, placeholder: "Add line 1")
                editableLine($line2, focus: .line2, placeholder: "Add line 2")
                editableLine($line3, focus: .line3, placeholder: "Add line 3")

                rule

                Image(systemName: design.baseDesign.accentIcon)
                    .font(.system(size: 12))
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.5))
            }
            .padding(.vertical, BeesSpacing.s)
            .padding(.horizontal, BeesSpacing.m)
        }
    }

    private var rule: some View {
        Rectangle()
            .fill(design.baseDesign.accentColor.opacity(0.3))
            .frame(width: 28, height: 1)
    }

    @ViewBuilder
    private func editableLine(
        _ text: Binding<String>,
        focus: JarStudioView.TextLine,
        placeholder: String
    ) -> some View {
        TextField("", text: text, prompt:
            Text(placeholder)
                .foregroundStyle(design.color.color.opacity(0.35))
        )
        .focused(focusedLine, equals: focus)
        .submitLabel(.done)
        .onSubmit { focusedLine.wrappedValue = nil }
        .onChange(of: text.wrappedValue) { _, newValue in
            if newValue.count > StickerDesign.lineLimit {
                text.wrappedValue = String(newValue.prefix(StickerDesign.lineLimit))
            }
        }
        .multilineTextAlignment(.center)
        .font(design.font.font)
        .foregroundStyle(design.color.color)
        .lineLimit(1)
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(focusedLine.wrappedValue == focus
                        ? design.baseDesign.accentColor.opacity(0.4)
                        : .clear,
                        lineWidth: 1)
                .animation(.easeOut(duration: 0.15), value: focusedLine.wrappedValue)
        )
    }
}

// MARK: - Static jar (peek positions of carousel)

private struct StaticStudioJar: View {
    let design: StickerDesign

    var body: some View {
        StudioJarChrome(design: design) {
            VStack(spacing: BeesSpacing.xxs) {
                Image(systemName: design.baseDesign.accentIcon)
                    .font(.system(size: 16))
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.7))

                Text(design.baseDesign.name.uppercased())
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(2.5)
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.7))

                Rectangle()
                    .fill(design.baseDesign.accentColor.opacity(0.3))
                    .frame(width: 28, height: 1)

                ForEach(Array(design.allLines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(design.font.font)
                        .foregroundStyle(design.color.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                if design.allLines.isEmpty {
                    Text("Your text")
                        .font(design.font.font)
                        .foregroundStyle(design.color.color.opacity(0.35))
                }

                Rectangle()
                    .fill(design.baseDesign.accentColor.opacity(0.3))
                    .frame(width: 28, height: 1)

                Image(systemName: design.baseDesign.accentIcon)
                    .font(.system(size: 12))
                    .foregroundStyle(design.baseDesign.accentColor.opacity(0.5))
            }
            .padding(.vertical, BeesSpacing.s)
            .padding(.horizontal, BeesSpacing.m)
        }
    }
}

// MARK: - Shared jar chrome (lid, glass, body, sticker shape)

private struct StudioJarChrome<StickerContent: View>: View {
    let design: StickerDesign
    @ViewBuilder var sticker: () -> StickerContent

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height / 1.4)
            VStack(spacing: 0) {
                // Lid
                RoundedRectangle(cornerRadius: 4)
                    .fill(LinearGradient(
                        colors: [BeesColors.charcoal600, BeesColors.charcoal900],
                        startPoint: .top, endPoint: .bottom))
                    .frame(width: s * 0.65, height: s * 0.08)

                // Glass band
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Color(white: 0.95).opacity(0.6), Color(white: 0.85).opacity(0.4)],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: s * 0.55, height: s * 0.05)

                // Body with sticker
                ZStack {
                    RoundedRectangle(cornerRadius: s * 0.08)
                        .fill(LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.78, blue: 0.30),
                                Color(red: 0.85, green: 0.55, blue: 0.10),
                            ],
                            startPoint: .top, endPoint: .bottom))
                        .overlay(
                            RoundedRectangle(cornerRadius: s * 0.08)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                .blendMode(.overlay)
                        )

                    RoundedRectangle(cornerRadius: s * 0.08)
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.35), .clear],
                            startPoint: .topLeading, endPoint: .center))
                        .blendMode(.softLight)

                    stickerOverlay(size: s)
                }
                .frame(width: s * 0.78, height: s * 1.05)
                .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 12)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
    }

    private func stickerOverlay(size: CGFloat) -> some View {
        let stickerWidth = size * 0.66
        let stickerHeight = size * 0.86
        return ZStack {
            stickerShape
                .fill(design.baseDesign.backgroundColor)
                .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)

            stickerShape
                .stroke(design.baseDesign.accentColor.opacity(0.25), lineWidth: 1.5)
                .padding(6)

            sticker()
        }
        .frame(width: stickerWidth, height: stickerHeight)
    }

    private var stickerShape: AnyShape {
        switch design.baseDesign.shape {
        case .rounded: return AnyShape(RoundedRectangle(cornerRadius: 8))
        case .square:  return AnyShape(Rectangle())
        case .oval:    return AnyShape(Ellipse())
        case .hexagon: return AnyShape(HexagonShape())
        case .badge:   return AnyShape(BadgeShape())
        case .scallop: return AnyShape(ScallopShape())
        }
    }
}

#Preview {
    NavigationStack {
        JarStudioView()
            .environment(ServiceContainer.preview())
    }
}
