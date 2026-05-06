import Foundation
import SwiftUI

struct StickerBaseDesign: Identifiable, Hashable {
    let id: String
    let name: String
    let category: Category
    let backgroundColor: Color
    let accentColor: Color

    enum Category: String, Hashable {
        case floral, geometric, vintage, botanical, minimalist, hexagon, watercolor, letterpress, gift
    }

    static let catalog: [StickerBaseDesign] = [
        .init(id: "floral",       name: "Floral",      category: .floral,
              backgroundColor: BeesColors.honey100, accentColor: BeesColors.honey500),
        .init(id: "geometric",    name: "Geometric",   category: .geometric,
              backgroundColor: BeesColors.comb500, accentColor: BeesColors.charcoal900),
        .init(id: "vintage",      name: "Vintage",     category: .vintage,
              backgroundColor: BeesColors.honey300, accentColor: BeesColors.charcoal900),
        .init(id: "botanical",    name: "Botanical",   category: .botanical,
              backgroundColor: BeesColors.honey100, accentColor: BeesColors.leaf500),
        .init(id: "minimalist",   name: "Minimalist",  category: .minimalist,
              backgroundColor: .white, accentColor: BeesColors.charcoal900),
        .init(id: "hexagon",      name: "Hexagon",     category: .hexagon,
              backgroundColor: BeesColors.honey300, accentColor: BeesColors.charcoal900),
        .init(id: "watercolor",   name: "Watercolor",  category: .watercolor,
              backgroundColor: BeesColors.comb500, accentColor: BeesColors.amber500),
        .init(id: "letterpress",  name: "Letterpress", category: .letterpress,
              backgroundColor: BeesColors.charcoal900, accentColor: BeesColors.honey300),
    ]
}

struct StickerFont: Identifiable, Hashable {
    let id: String
    let name: String
    let font: Font

    static let catalog: [StickerFont] = [
        .init(id: "modern-sans",   name: "Modern Sans",
              font: .system(size: 16, weight: .semibold, design: .default)),
        .init(id: "classic-serif", name: "Classic Serif",
              font: .system(size: 16, weight: .regular, design: .serif)),
        .init(id: "handwritten",   name: "Handwritten",
              font: .custom("SnellRoundhand-Bold", size: 16)),
        .init(id: "vintage-bold",  name: "Vintage Bold",
              font: .system(size: 16, weight: .heavy, design: .rounded)),
        .init(id: "minimal-mono",  name: "Minimal Mono",
              font: .system(size: 16, weight: .regular, design: .monospaced)),
    ]
}

struct StickerColor: Identifiable, Hashable {
    let id: String
    let name: String
    let color: Color

    static let catalog: [StickerColor] = [
        .init(id: "charcoal", name: "Charcoal",      color: BeesColors.charcoal900),
        .init(id: "cream",    name: "Cream",         color: BeesColors.honey100),
        .init(id: "honey",    name: "Honey",         color: BeesColors.honey500),
        .init(id: "amber",    name: "Burnt Orange",  color: BeesColors.amber500),
        .init(id: "sage",     name: "Sage",          color: BeesColors.leaf500),
        .init(id: "ocean",    name: "Ocean",         color: Color(red: 0.20, green: 0.45, blue: 0.65)),
    ]
}

struct StickerDesign: Hashable, Identifiable {
    let id: UUID
    var baseDesignId: String
    var line1: String
    var line2: String
    var line3: String
    var fontId: String
    var colorId: String

    var baseDesign: StickerBaseDesign {
        StickerBaseDesign.catalog.first { $0.id == baseDesignId } ?? StickerBaseDesign.catalog[0]
    }

    var font: StickerFont {
        StickerFont.catalog.first { $0.id == fontId } ?? StickerFont.catalog[0]
    }

    var color: StickerColor {
        StickerColor.catalog.first { $0.id == colorId } ?? StickerColor.catalog[0]
    }

    var allLines: [String] { [line1, line2, line3].filter { !$0.isEmpty } }

    static let lineLimit: Int = 18

    static let empty = StickerDesign(
        id: UUID(),
        baseDesignId: "floral",
        line1: "",
        line2: "",
        line3: "",
        fontId: "modern-sans",
        colorId: "charcoal"
    )
}

struct SavedSticker: Identifiable, Hashable {
    let id: UUID
    var nickname: String
    var design: StickerDesign
}
