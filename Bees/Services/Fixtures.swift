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

    static let demoActiveDesign = StickerDesign(
        id: UUID(),
        baseDesignId: "floral",
        line1: "Buzzy Bee",
        line2: "Spring 2026",
        line3: "",
        fontId: "modern-sans",
        colorId: "honey"
    )

    static let demoActiveShipment = Shipment(
        id: UUID(),
        jarCount: 1,
        status: .customizing,
        scheduledShipDate: Calendar.current.date(byAdding: .day, value: 13, to: Date())!,
        lockInDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!,
        deliveredAt: nil,
        trackingNumber: nil,
        carrier: nil,
        design: demoActiveDesign
    )

    static let demoHistory: [Shipment] = [
        Shipment(
            id: UUID(),
            jarCount: 1,
            status: .delivered,
            scheduledShipDate: Calendar.current.date(byAdding: .day, value: -25, to: Date())!,
            lockInDate: Calendar.current.date(byAdding: .day, value: -32, to: Date())!,
            deliveredAt: Calendar.current.date(byAdding: .day, value: -18, to: Date()),
            trackingNumber: "9400 1000 0000 0000 0000 00",
            carrier: .usps,
            design: StickerDesign(id: UUID(), baseDesignId: "geometric", line1: "Buzzy", line2: "April 2026", line3: "", fontId: "vintage-bold", colorId: "amber")
        ),
        Shipment(
            id: UUID(),
            jarCount: 1,
            status: .delivered,
            scheduledShipDate: Calendar.current.date(byAdding: .day, value: -55, to: Date())!,
            lockInDate: Calendar.current.date(byAdding: .day, value: -62, to: Date())!,
            deliveredAt: Calendar.current.date(byAdding: .day, value: -48, to: Date()),
            trackingNumber: "1Z999AA10123456784",
            carrier: .ups,
            design: StickerDesign(id: UUID(), baseDesignId: "botanical", line1: "Hive 47", line2: "March 2026", line3: "", fontId: "classic-serif", colorId: "sage")
        ),
        Shipment(
            id: UUID(),
            jarCount: 1,
            status: .delivered,
            scheduledShipDate: Calendar.current.date(byAdding: .day, value: -85, to: Date())!,
            lockInDate: Calendar.current.date(byAdding: .day, value: -92, to: Date())!,
            deliveredAt: Calendar.current.date(byAdding: .day, value: -78, to: Date()),
            trackingNumber: "9400 1000 0000 0000 0000 11",
            carrier: .usps,
            design: StickerDesign(id: UUID(), baseDesignId: "watercolor", line1: "First jar!", line2: "Feb 2026", line3: "", fontId: "handwritten", colorId: "honey")
        ),
    ]

    static let demoSavedStickers: [SavedSticker] = [
        SavedSticker(id: UUID(), nickname: "Default",
                     design: StickerDesign(id: UUID(), baseDesignId: "minimalist", line1: "Buzzy", line2: "", line3: "", fontId: "modern-sans", colorId: "charcoal")),
        SavedSticker(id: UUID(), nickname: "For mom",
                     design: StickerDesign(id: UUID(), baseDesignId: "vintage", line1: "For Mom", line2: "with love", line3: "", fontId: "handwritten", colorId: "amber")),
    ]

    static func chartSamplePoints(stat: StatType, range: TimeRange) -> [StatChartPoint] {
        let count: Int
        switch range {
        case .hour:     count = 60
        case .day:      count = 96
        case .week:     count = 7 * 24
        case .month:    count = 30
        case .season:   count = 90
        case .lifetime: count = 365
        }

        let baseValue: Double
        switch stat {
        case .temperature: baseValue = 91
        case .humidity:    baseValue = 62
        case .weight:      baseValue = 45
        case .population:  baseValue = 56_000
        case .takeoffs:    baseValue = 1_100
        case .landings:    baseValue = 1_115
        case .sound:       baseValue = 0.4
        }

        var seed: Double = 0
        let now = Date()
        let stride = Double(count) / 100
        return (0..<count).map { i in
            seed += Double.random(in: -0.3...0.3)
            let drift = sin(Double(i) / stride) * (baseValue * 0.06) + (seed * baseValue * 0.005)
            let value = baseValue + drift
            let secondsBack = Double(count - i) * 60
            return StatChartPoint(
                date: now.addingTimeInterval(-secondsBack),
                value: max(0, value)
            )
        }
    }
}
