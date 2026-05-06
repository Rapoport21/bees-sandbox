import SwiftUI
import UIKit

enum BeesColors {
    // MARK: - Brand (invariant across light/dark)

    static let honey500 = Color(red: 0.96, green: 0.65, blue: 0.13)
    static let honey300 = Color(red: 1.00, green: 0.82, blue: 0.54)
    static let honey100 = Color(red: 1.00, green: 0.96, blue: 0.86)

    static let leaf500  = Color(red: 0.36, green: 0.54, blue: 0.24)
    static let amber500 = Color(red: 0.85, green: 0.46, blue: 0.02)
    static let error500 = Color(red: 0.75, green: 0.22, blue: 0.17)

    // MARK: - Adaptive surfaces

    /// Page-level wash. Replaces the legacy `honey100.opacity(0.4)` pattern.
    static let surfacePage = adaptive(
        light: UIColor(red: 1.00, green: 0.96, blue: 0.86, alpha: 0.4),
        dark:  UIColor(red: 0.06, green: 0.05, blue: 0.04, alpha: 1.0)
    )

    /// Elevated card / sheet background.
    static let surfaceCard = adaptive(
        light: .white,
        dark:  UIColor(red: 0.14, green: 0.12, blue: 0.11, alpha: 1.0)
    )

    /// Subtle tile / muted surface — formerly the sandy "comb" beige.
    static let surfaceMuted = adaptive(
        light: UIColor(red: 0.91, green: 0.88, blue: 0.82, alpha: 1.0),
        dark:  UIColor(red: 0.20, green: 0.18, blue: 0.16, alpha: 1.0)
    )

    /// Backwards-compat alias.
    static var comb500: Color { surfaceMuted }

    // MARK: - Adaptive text

    /// Primary text. Was `charcoal900` (literal near-black).
    static let charcoal900 = adaptive(
        light: UIColor(red: 0.10, green: 0.09, blue: 0.08, alpha: 1.0),
        dark:  .white
    )

    /// Secondary text.
    static let charcoal600 = adaptive(
        light: UIColor(red: 0.36, green: 0.33, blue: 0.31, alpha: 1.0),
        dark:  UIColor(red: 0.74, green: 0.71, blue: 0.68, alpha: 1.0)
    )

    /// Tertiary / disabled / hairline.
    static let charcoal300 = adaptive(
        light: UIColor(red: 0.72, green: 0.69, blue: 0.66, alpha: 1.0),
        dark:  UIColor(red: 0.46, green: 0.44, blue: 0.41, alpha: 1.0)
    )

    // MARK: - Helper

    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}
