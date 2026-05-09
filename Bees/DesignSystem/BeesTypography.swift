import SwiftUI

/// Type system. The display tier uses **Calistoga** — a chunky friendly
/// serif by Sorkin Type. It carries the warm/farmhouse/cozy brand
/// voice better than system serif (.system .serif = New York, which
/// reads as more editorial-formal). Calistoga ships only as Regular,
/// so we don't try to assign weights to it.
///
/// Headings, body, and captions stay on system sans (SF Pro) for
/// reliability and Apple HIG conformance — never use a serif for app
/// chrome (controls, lists, forms).
enum BeesType {
    // Display — system serif (SF / New York). Reverted from Calistoga.
    static let displayXL = Font.system(size: 40, weight: .bold,     design: .serif)
    static let displayL  = Font.system(size: 32, weight: .semibold, design: .serif)
    static let displayM  = Font.system(size: 24, weight: .semibold, design: .serif)

    // Headings — system sans (SF Pro), bold weight for hierarchy.
    static let headingL  = Font.system(size: 24, weight: .semibold)
    static let headingM  = Font.system(size: 20, weight: .semibold)

    // Body
    static let bodyL     = Font.system(size: 17, weight: .regular)
    static let bodyM     = Font.system(size: 15, weight: .regular)

    // Captions
    static let captionM  = Font.system(size: 13, weight: .regular)
    static let captionS  = Font.system(size: 11, weight: .medium)

    // Monospaced — for numeric / data displays.
    static let monoM     = Font.system(size: 15, weight: .regular, design: .monospaced)
    static let monoL     = Font.system(size: 32, weight: .semibold, design: .monospaced)
}
