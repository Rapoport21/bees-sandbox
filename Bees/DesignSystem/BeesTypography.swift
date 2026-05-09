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
    /// PostScript name of the bundled Calistoga font.
    private static let calistoga = "Calistoga-Regular"

    // Display — Calistoga, single Regular weight. Sized one notch
    // bigger than before since Calistoga has more visual weight than
    // SF Serif and earns the room.
    static let displayXL = Font.custom(calistoga, size: 44, relativeTo: .largeTitle)
    static let displayL  = Font.custom(calistoga, size: 34, relativeTo: .title)
    static let displayM  = Font.custom(calistoga, size: 26, relativeTo: .title2)

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
