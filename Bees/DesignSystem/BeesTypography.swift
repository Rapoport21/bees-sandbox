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

    // MARK: Display — Calistoga, single Regular weight
    //
    // Sized for impact. Each step is roughly a 1.28 ratio so the
    // serif carries hierarchy on its own without weight variation.

    static let displayXL = Font.custom(calistoga, size: 46, relativeTo: .largeTitle)
    static let displayL  = Font.custom(calistoga, size: 36, relativeTo: .title)
    static let displayM  = Font.custom(calistoga, size: 28, relativeTo: .title2)

    // MARK: Headings — SF Pro Semibold
    //
    // Sans-serif contrast against Calistoga. Tightened from 24/20 →
    // 22/19 to give displayM a clear step down (28 → 22, ratio 1.27)
    // instead of the muddy 26 → 24.

    static let headingL  = Font.system(size: 22, weight: .semibold)
    static let headingM  = Font.system(size: 19, weight: .semibold)

    // MARK: Body — SF Pro Regular
    //
    // bodyM dropped 15 → 14 to give bodyL clear hierarchy (1.21 ratio
    // vs previous 1.13). 14pt is still comfortably readable for
    // secondary copy / descriptions; Bees has no long-form reading.

    static let bodyL     = Font.system(size: 17, weight: .regular)
    static let bodyM     = Font.system(size: 14, weight: .regular)

    // MARK: Captions
    //
    // captionM 13 → 12. captionS stays 11pt medium — that's the
    // canonical ALL-CAPS label tier (used with .tracking(1.0) +
    // .textCase(.uppercase)).

    static let captionM  = Font.system(size: 12, weight: .regular)
    static let captionS  = Font.system(size: 11, weight: .medium)

    // MARK: Monospaced — for numeric / data displays.

    static let monoM     = Font.system(size: 15, weight: .regular, design: .monospaced)
    static let monoL     = Font.system(size: 32, weight: .semibold, design: .monospaced)
}
