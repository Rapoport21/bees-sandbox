import Foundation
import Observation

protocol StickerService: AnyObject {
    var savedStickers: [SavedSticker] { get }
    var maxSaved: Int { get }

    func save(_ design: StickerDesign, nickname: String)
    func remove(_ savedSticker: SavedSticker)
}

@Observable
final class MockStickerService: StickerService {
    private(set) var savedStickers: [SavedSticker]
    let maxSaved: Int

    init(savedStickers: [SavedSticker], maxSaved: Int) {
        self.savedStickers = savedStickers
        self.maxSaved = maxSaved
    }

    func save(_ design: StickerDesign, nickname: String) {
        let new = SavedSticker(id: UUID(), nickname: nickname, design: design)
        if savedStickers.count >= maxSaved {
            savedStickers.removeFirst()
        }
        savedStickers.append(new)
    }

    func remove(_ savedSticker: SavedSticker) {
        savedStickers.removeAll { $0.id == savedSticker.id }
    }
}
