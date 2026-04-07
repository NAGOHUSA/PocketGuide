import XCTest
import SwiftData
@testable import PocketGuide

// MARK: - CityPackTests

final class CityPackTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    override func setUpWithError() throws {
        let schema = Schema([CityPack.self, TravelEntry.self, Phrase.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - CityPack model

    func testCityPackInitialization() {
        let pack = CityPack(
            id: "tokyo",
            city: "Tokyo",
            country: "Japan",
            region: "Asia",
            storeProductID: "com.pocketguide.citypack.tokyo",
            overview: "Navigate Tokyo offline.",
            latitude: 35.6762,
            longitude: 139.6503,
            sizeInMB: 142.5,
            coverImageName: "tokyo_cover"
        )

        XCTAssertEqual(pack.id, "tokyo")
        XCTAssertEqual(pack.city, "Tokyo")
        XCTAssertEqual(pack.country, "Japan")
        XCTAssertFalse(pack.isPurchased)
        XCTAssertFalse(pack.isDownloaded)
        XCTAssertNil(pack.downloadedAt)
        XCTAssertTrue(pack.entries.isEmpty)
        XCTAssertTrue(pack.phrases.isEmpty)
        XCTAssertEqual(pack.packVersion, "1.0")
    }

    func testCityPackCatalogNotEmpty() {
        XCTAssertFalse(CityPack.catalog.isEmpty)
    }

    func testCityPackCatalogContainsTokyo() {
        let tokyo = CityPack.catalog.first { $0.id == "tokyo" }
        XCTAssertNotNil(tokyo)
        XCTAssertEqual(tokyo?.city, "Tokyo")
        XCTAssertEqual(tokyo?.country, "Japan")
        XCTAssertEqual(tokyo?.storeProductID, "com.pocketguide.citypack.tokyo")
    }

    func testCityPackCatalogAllHaveProductIDs() {
        for descriptor in CityPack.catalog {
            XCTAssertFalse(
                descriptor.storeProductID.isEmpty,
                "\(descriptor.city) has no storeProductID"
            )
        }
    }

    func testCityPackCatalogUniqueIDs() {
        let ids = CityPack.catalog.map(\.id)
        let uniqueIDs = Set(ids)
        XCTAssertEqual(ids.count, uniqueIDs.count, "Catalog contains duplicate IDs")
    }

    // MARK: - TravelEntry model

    func testTravelEntryInitialization() {
        let entry = TravelEntry(
            id: "test-entry-1",
            cityPackID: "tokyo",
            title: "Test Entry",
            body: "Test body text",
            category: .culture,
            tags: ["test", "culture"],
            neighborhood: "Shinjuku",
            isFeatured: true,
            sortOrder: 1
        )

        XCTAssertEqual(entry.id, "test-entry-1")
        XCTAssertEqual(entry.cityPackID, "tokyo")
        XCTAssertEqual(entry.category, .culture)
        XCTAssertEqual(entry.tags, ["test", "culture"])
        XCTAssertTrue(entry.isFeatured)
        XCTAssertEqual(entry.sortOrder, 1)
    }

    func testEntryCategoryAllCasesHaveSystemImages() {
        for category in EntryCategory.allCases {
            XCTAssertFalse(
                category.systemImage.isEmpty,
                "\(category.rawValue) has no systemImage"
            )
        }
    }

    // MARK: - Phrase model

    func testPhraseInitialization() {
        let phrase = Phrase(
            id: "phrase-1",
            cityPackID: "tokyo",
            originalText: "Hello",
            translatedText: "こんにちは",
            romanization: "Konnichiwa",
            category: .greetings
        )

        XCTAssertEqual(phrase.id, "phrase-1")
        XCTAssertEqual(phrase.originalText, "Hello")
        XCTAssertEqual(phrase.translatedText, "こんにちは")
        XCTAssertEqual(phrase.romanization, "Konnichiwa")
        XCTAssertEqual(phrase.category, .greetings)
        XCTAssertNil(phrase.audioFileName)
    }

    func testPhraseCategoryAllCasesHaveSystemImages() {
        for category in PhraseCategory.allCases {
            XCTAssertFalse(
                category.systemImage.isEmpty,
                "\(category.rawValue) has no systemImage"
            )
        }
    }
}

// MARK: - CityPackManagerTests

final class CityPackManagerTests: XCTestCase {

    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!
    private var manager: CityPackManager!

    override func setUpWithError() throws {
        let schema = Schema([CityPack.self, TravelEntry.self, Phrase.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
        manager = CityPackManager(modelContext: modelContext)
    }

    @MainActor
    func testSeedCatalogCreatesRecords() throws {
        try manager.seedCatalogIfNeeded()
        let all = try manager.fetchAllPacks()
        XCTAssertEqual(all.count, CityPack.catalog.count)
    }

    @MainActor
    func testSeedCatalogIsIdempotent() throws {
        try manager.seedCatalogIfNeeded()
        try manager.seedCatalogIfNeeded()
        let all = try manager.fetchAllPacks()
        XCTAssertEqual(all.count, CityPack.catalog.count, "Seeding twice should not duplicate records")
    }

    @MainActor
    func testFetchDownloadedPacksReturnsOnlyDownloaded() throws {
        try manager.seedCatalogIfNeeded()
        let all = try manager.fetchAllPacks()

        // Mark one pack as downloaded
        all.first?.isDownloaded = true
        try modelContext.save()

        let downloaded = try manager.fetchDownloadedPacks()
        XCTAssertEqual(downloaded.count, 1)
    }

    @MainActor
    func testDeletePackClearsDownloadedFlag() throws {
        try manager.seedCatalogIfNeeded()
        let all = try manager.fetchAllPacks()
        let pack = all[0]
        pack.isDownloaded = true
        pack.entries = [TravelEntry(id: "e1", cityPackID: pack.id, title: "T", body: "B", category: .practical)]
        try modelContext.save()

        try manager.deletePack(id: pack.id)

        let fetched = try manager.fetchPack(id: pack.id)
        XCTAssertFalse(fetched?.isDownloaded ?? true)
        XCTAssertTrue(fetched?.entries.isEmpty ?? false)
    }

    @MainActor
    func testDownloadPackSetsFlags() async throws {
        try manager.seedCatalogIfNeeded()

        let descriptor = CityPack.catalog.first { $0.id == "tokyo" }!
        await manager.downloadPack(descriptor: descriptor)

        let pack = try manager.fetchPack(id: "tokyo")
        XCTAssertNotNil(pack)
        XCTAssertTrue(pack?.isPurchased ?? false)
        XCTAssertTrue(pack?.isDownloaded ?? false)
        XCTAssertNotNil(pack?.downloadedAt)
    }
}

// MARK: - SampleDataProviderTests

final class SampleDataProviderTests: XCTestCase {

    func testTokyoEntriesNotEmpty() {
        let entries = SampleDataProvider.entries(for: "tokyo")
        XCTAssertFalse(entries.isEmpty)
    }

    func testTokyoPhrasesNotEmpty() {
        let phrases = SampleDataProvider.phrases(for: "tokyo")
        XCTAssertFalse(phrases.isEmpty)
    }

    func testParisEntriesNotEmpty() {
        let entries = SampleDataProvider.entries(for: "paris")
        XCTAssertFalse(entries.isEmpty)
    }

    func testAlpsEntriesNotEmpty() {
        let entries = SampleDataProvider.entries(for: "alps")
        XCTAssertFalse(entries.isEmpty)
    }

    func testTokyoPhrasesCoverEmergency() {
        let phrases = SampleDataProvider.phrases(for: "tokyo")
        let hasEmergency = phrases.contains { $0.category == .emergency }
        XCTAssertTrue(hasEmergency, "Tokyo phrases should include at least one emergency phrase")
    }

    func testAllPhrasesCityPackIDIsSet() {
        let cityIDs = ["tokyo", "paris", "alps"]
        for cityID in cityIDs {
            let phrases = SampleDataProvider.phrases(for: cityID)
            for phrase in phrases {
                XCTAssertEqual(phrase.cityPackID, cityID,
                               "Phrase '\(phrase.id)' has wrong cityPackID")
            }
        }
    }

    func testAllEntriesCityPackIDIsSet() {
        let cityIDs = ["tokyo", "paris", "alps"]
        for cityID in cityIDs {
            let entries = SampleDataProvider.entries(for: cityID)
            for entry in entries {
                XCTAssertEqual(entry.cityPackID, cityID,
                               "Entry '\(entry.id)' has wrong cityPackID")
            }
        }
    }
}

// MARK: - OfflineLLMServiceTests

final class OfflineLLMServiceTests: XCTestCase {

    @MainActor
    func testAskCollectedReturnsNonEmptyResponse() async throws {
        let service = OfflineLLMService()
        service.loadCityContext("Test city context for Tokyo.")
        let answer = try await service.askCollected("What is the best way to get around?")
        XCTAssertFalse(answer.isEmpty)
    }

    @MainActor
    func testAskCollectedSubwayQuestion() async throws {
        let service = OfflineLLMService()
        let answer = try await service.askCollected("How do I use the subway?")
        // The fallback response should mention subway/city pack
        XCTAssertFalse(answer.isEmpty)
        let lower = answer.lowercased()
        XCTAssertTrue(lower.contains("subway") || lower.contains("getting around") || lower.contains("city pack"))
    }

    @MainActor
    func testLoadCityContextDoesNotThrow() {
        let service = OfflineLLMService()
        service.loadCityContext("You are guiding a traveler in Tokyo.")
        // Verify state is updated
        XCTAssertFalse(service.isProcessing)
    }
}
