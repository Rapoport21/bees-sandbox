import Foundation

enum Fixtures {
    static let demoHive = Hive(
        id: "hive-47",
        hiveNumber: 47,
        name: "Buzzy McHive",
        farmName: "Sunny Acre Farm",
        farmLocation: "Sonoma County, California",
        paintedNameStatus: .notRequested,
        status: .live
    )

    static let demoFarm = Farm(
        id: "farm-sunny-acre",
        name: "Sunny Acre Farm",
        location: "Sonoma County, California",
        farmerName: "Maya Hernandez",
        farmerBio: "Third-generation beekeeper with 12 years tending hives in Sonoma's hills.",
        coverImageName: nil,
        story: "Sunny Acre is a 40-acre family farm in the rolling hills of Sonoma County. We tend 60 hives across the property, with bees foraging on wildflower meadows, lavender fields, and our heritage apple orchard."
    )

    static let demoSnapshot = HiveSnapshot(
        temperatureF: 92,
        humidityPct: 64,
        weightLb: 47.2,
        populationEstimate: 58_400,
        takeoffsLast24h: 12_472,
        landingsLast24h: 12_530,
        soundLevel: .active,
        health: .thriving,
        lastReadingAt: Date()
    )

    static let demoActivity = LiveActivity(
        takeoffsLast60s: 8,
        landingsLast60s: 9,
        rollingTakeoffs: 12_472,
        rollingLandings: 12_530
    )
}
