import SwiftUI

enum BeesType {
    static let displayXL = Font.system(size: 40, weight: .bold, design: .serif)
    static let displayL  = Font.system(size: 32, weight: .semibold, design: .serif)
    static let displayM  = Font.system(size: 24, weight: .semibold, design: .serif)

    static let headingL  = Font.system(size: 24, weight: .semibold)
    static let headingM  = Font.system(size: 20, weight: .semibold)

    static let bodyL     = Font.system(size: 17, weight: .regular)
    static let bodyM     = Font.system(size: 15, weight: .regular)

    static let captionM  = Font.system(size: 13, weight: .regular)
    static let captionS  = Font.system(size: 11, weight: .medium)

    static let monoM     = Font.system(size: 15, weight: .regular, design: .monospaced)
    static let monoL     = Font.system(size: 32, weight: .semibold, design: .monospaced)
}
