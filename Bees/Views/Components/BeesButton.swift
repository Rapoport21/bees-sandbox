import SwiftUI

struct BeesPrimaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BeesType.bodyL.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BeesSpacing.s + 2)
            .background(
                isDestructive ? BeesColors.error500 : BeesColors.honey500,
                in: RoundedRectangle(cornerRadius: BeesRadius.md)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(BeesAnimation.pressFeedback, value: configuration.isPressed)
    }
}

struct BeesSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BeesType.bodyL.weight(.semibold))
            .foregroundStyle(BeesColors.charcoal900)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BeesSpacing.s + 2)
            .background(
                RoundedRectangle(cornerRadius: BeesRadius.md)
                    .stroke(BeesColors.charcoal300, lineWidth: 1.5)
            )
            .background(BeesColors.honey100.opacity(configuration.isPressed ? 0.6 : 0),
                        in: RoundedRectangle(cornerRadius: BeesRadius.md))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(BeesAnimation.pressFeedback, value: configuration.isPressed)
    }
}

struct BeesGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BeesType.bodyM.weight(.medium))
            .foregroundStyle(BeesColors.charcoal600)
            .padding(.vertical, BeesSpacing.xs)
            .padding(.horizontal, BeesSpacing.s)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

extension ButtonStyle where Self == BeesPrimaryButtonStyle {
    static var beesPrimary: BeesPrimaryButtonStyle { .init() }
    static var beesPrimaryDestructive: BeesPrimaryButtonStyle { .init(isDestructive: true) }
}

extension ButtonStyle where Self == BeesSecondaryButtonStyle {
    static var beesSecondary: BeesSecondaryButtonStyle { .init() }
}

extension ButtonStyle where Self == BeesGhostButtonStyle {
    static var beesGhost: BeesGhostButtonStyle { .init() }
}
