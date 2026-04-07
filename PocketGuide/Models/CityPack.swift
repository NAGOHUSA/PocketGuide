import Foundation
import SwiftData

// MARK: - CityPack

/// A purchasable offline city guide bundle containing maps, cultural info,
/// translations, and AI context for a specific destination.
@Model
final class CityPack: Identifiable {
    @Attribute(.unique) var id: String
    var city: String
    var country: String
    var region: String
    var storeProductID: String
    var isPurchased: Bool
    var isDownloaded: Bool
    var downloadedAt: Date?
    var packVersion: String
    var sizeInMB: Double
    var coverImageName: String
    var overview: String
    var latitude: Double
    var longitude: Double

    @Relationship(deleteRule: .cascade)
    var entries: [TravelEntry]

    @Relationship(deleteRule: .cascade)
    var phrases: [Phrase]

    init(
        id: String,
        city: String,
        country: String,
        region: String,
        storeProductID: String,
        overview: String,
        latitude: Double,
        longitude: Double,
        sizeInMB: Double,
        coverImageName: String,
        packVersion: String = "1.0"
    ) {
        self.id = id
        self.city = city
        self.country = country
        self.region = region
        self.storeProductID = storeProductID
        self.isPurchased = false
        self.isDownloaded = false
        self.downloadedAt = nil
        self.packVersion = packVersion
        self.sizeInMB = sizeInMB
        self.coverImageName = coverImageName
        self.overview = overview
        self.latitude = latitude
        self.longitude = longitude
        self.entries = []
        self.phrases = []
    }
}

// MARK: - Available City Packs catalog

extension CityPack {
    static let catalog: [CityPackDescriptor] = [
        CityPackDescriptor(
            id: "tokyo",
            city: "Tokyo",
            country: "Japan",
            region: "Asia",
            storeProductID: "com.pocketguide.citypack.tokyo",
            overview: "Navigate Tokyo's vibrant neighborhoods, master subway lines, and discover hidden gems—all without a data connection.",
            latitude: 35.6762,
            longitude: 139.6503,
            sizeInMB: 142.5,
            coverImageName: "tokyo_cover"
        ),
        CityPackDescriptor(
            id: "paris",
            city: "Paris",
            country: "France",
            region: "Europe",
            storeProductID: "com.pocketguide.citypack.paris",
            overview: "Explore Parisian culture, navigate the Métro, and converse like a local—no Wi-Fi needed.",
            latitude: 48.8566,
            longitude: 2.3522,
            sizeInMB: 138.0,
            coverImageName: "paris_cover"
        ),
        CityPackDescriptor(
            id: "alps",
            city: "Swiss Alps",
            country: "Switzerland",
            region: "Europe",
            storeProductID: "com.pocketguide.citypack.alps",
            overview: "Hike safely through alpine trails, understand mountain safety, and communicate in four languages—even in remote valleys.",
            latitude: 46.8182,
            longitude: 8.2275,
            sizeInMB: 98.3,
            coverImageName: "alps_cover"
        ),
        CityPackDescriptor(
            id: "barcelona",
            city: "Barcelona",
            country: "Spain",
            region: "Europe",
            storeProductID: "com.pocketguide.citypack.barcelona",
            overview: "Discover Gaudí's masterpieces, tapas bars, and beach culture with a full offline guide to Catalunya's capital.",
            latitude: 41.3851,
            longitude: 2.1734,
            sizeInMB: 125.7,
            coverImageName: "barcelona_cover"
        ),
        CityPackDescriptor(
            id: "new_york",
            city: "New York City",
            country: "United States",
            region: "North America",
            storeProductID: "com.pocketguide.citypack.newyork",
            overview: "Conquer the five boroughs, navigate the subway, and find the best local spots without burning through your data plan.",
            latitude: 40.7128,
            longitude: -74.0060,
            sizeInMB: 155.2,
            coverImageName: "nyc_cover"
        )
    ]
}

// MARK: - CityPackDescriptor (lightweight catalog entry, not persisted)

struct CityPackDescriptor: Identifiable, Sendable {
    let id: String
    let city: String
    let country: String
    let region: String
    let storeProductID: String
    let overview: String
    let latitude: Double
    let longitude: Double
    let sizeInMB: Double
    let coverImageName: String
}
