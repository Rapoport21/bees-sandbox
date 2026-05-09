import SwiftUI

/// Lightweight bottom toast for prototype dead-end buttons. Lives in
/// the global ContentView via `.environment` and surfaces over any
/// view. Used to signal "we'll wire this in real" without leaving
/// the user staring at a button that does nothing.
@Observable
final class ToastCenter {
    var message: String?

    func show(_ text: String = "Coming soon") {
        message = text
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.6))
            withAnimation(.easeOut(duration: 0.25)) {
                if message == text { message = nil }
            }
        }
    }
}

struct ComingSoonToast: View {
    let message: String

    var body: some View {
        HStack(spacing: BeesSpacing.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BeesColors.honey500)
            Text(message)
                .font(BeesType.captionM.weight(.medium))
                .foregroundStyle(BeesColors.charcoal900)
        }
        .padding(.horizontal, BeesSpacing.s + 4)
        .padding(.vertical, BeesSpacing.xs + 2)
        .background(.regularMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(BeesColors.charcoal300.opacity(0.25), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.10), radius: 16, y: 6)
    }
}
