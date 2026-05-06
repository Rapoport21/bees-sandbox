import Foundation

struct Hive: Identifiable, Hashable, Codable {
    let id: String
    var hiveNumber: Int
    var name: String
    var farmName: String
    var farmLocation: String
    var paintedNameStatus: PaintedNameStatus
    var status: HiveStatus

    enum PaintedNameStatus: String, Codable {
        case notRequested, pending, painted, declined
    }

    enum HiveStatus: String, Codable {
        case live, dormant, emergency, collapsed, maintenance
    }
}

struct Farm: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var location: String
    var farmerName: String
    var farmerBio: String
    var coverImageName: String?
    var story: String
}
