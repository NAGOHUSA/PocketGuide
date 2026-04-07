import Foundation
import SwiftData

// MARK: - CityPackManager
//
// Manages the lifecycle of CityPacks: downloading, caching, and
// seeding sample data. All storage is local (SwiftData) so the app
// works 100% offline after the initial pack download.

@MainActor
final class CityPackManager: ObservableObject {

    // MARK: - Published state

    @Published var downloadingPackIDs: Set<String> = []
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let modelContext: ModelContext

    // MARK: - Init

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Fetching

    func fetchDownloadedPacks() throws -> [CityPack] {
        let descriptor = FetchDescriptor<CityPack>(
            predicate: #Predicate { $0.isDownloaded },
            sortBy: [SortDescriptor(\.city)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchAllPacks() throws -> [CityPack] {
        let descriptor = FetchDescriptor<CityPack>(
            sortBy: [SortDescriptor(\.city)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchPack(id: String) throws -> CityPack? {
        let descriptor = FetchDescriptor<CityPack>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Download

    /// Simulates downloading a purchased city pack.
    /// In production this would pull pre-built JSON + Core ML assets
    /// from a CDN and store them locally.
    func downloadPack(descriptor: CityPackDescriptor) async {
        downloadingPackIDs.insert(descriptor.id)
        defer { downloadingPackIDs.remove(descriptor.id) }

        // Simulate network latency for a pack download
        try? await Task.sleep(for: .seconds(2))

        do {
            let pack = try fetchPack(id: descriptor.id) ?? makePack(from: descriptor)
            pack.isPurchased = true
            pack.isDownloaded = true
            pack.downloadedAt = Date()

            // Seed guide entries and phrases from bundled JSON
            if let entries = try? loadEntries(for: descriptor.id) {
                pack.entries = entries
            }
            if let phrases = try? loadPhrases(for: descriptor.id) {
                pack.phrases = phrases
            }

            try modelContext.save()
        } catch {
            errorMessage = "Failed to download \(descriptor.city): \(error.localizedDescription)"
        }
    }

    /// Remove a downloaded pack from local storage.
    func deletePack(id: String) throws {
        guard let pack = try fetchPack(id: id) else { return }
        pack.isDownloaded = false
        pack.downloadedAt = nil
        pack.entries.removeAll()
        pack.phrases.removeAll()
        try modelContext.save()
    }

    // MARK: - Seeding catalog

    /// Ensures every city in the catalog has a corresponding SwiftData record
    /// (purchased = false, downloaded = false) so the store UI can display them.
    func seedCatalogIfNeeded() throws {
        let existing = try fetchAllPacks()
        let existingIDs = Set(existing.map(\.id))

        for descriptor in CityPack.catalog where !existingIDs.contains(descriptor.id) {
            let pack = makePack(from: descriptor)
            modelContext.insert(pack)
        }
        try modelContext.save()
    }

    // MARK: - Helpers

    private func makePack(from descriptor: CityPackDescriptor) -> CityPack {
        CityPack(
            id: descriptor.id,
            city: descriptor.city,
            country: descriptor.country,
            region: descriptor.region,
            storeProductID: descriptor.storeProductID,
            overview: descriptor.overview,
            latitude: descriptor.latitude,
            longitude: descriptor.longitude,
            sizeInMB: descriptor.sizeInMB,
            coverImageName: descriptor.coverImageName
        )
    }

    // MARK: - Bundled content loaders

    private func loadEntries(for cityID: String) throws -> [TravelEntry] {
        guard let url = Bundle.main.url(
            forResource: cityID,
            withExtension: "json",
            subdirectory: "SampleData"
        ) else {
            return SampleDataProvider.entries(for: cityID)
        }
        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder().decode(CityPackPayload.self, from: data)
        return payload.entries.map { dto in
            TravelEntry(
                id: dto.id,
                cityPackID: cityID,
                title: dto.title,
                body: dto.body,
                category: EntryCategory(rawValue: dto.category) ?? .practical,
                tags: dto.tags,
                neighborhood: dto.neighborhood,
                isFeatured: dto.isFeatured,
                sortOrder: dto.sortOrder
            )
        }
    }

    private func loadPhrases(for cityID: String) throws -> [Phrase] {
        guard let url = Bundle.main.url(
            forResource: cityID,
            withExtension: "json",
            subdirectory: "SampleData"
        ) else {
            return SampleDataProvider.phrases(for: cityID)
        }
        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder().decode(CityPackPayload.self, from: data)
        return payload.phrases.map { dto in
            Phrase(
                id: dto.id,
                cityPackID: cityID,
                originalText: dto.originalText,
                translatedText: dto.translatedText,
                romanization: dto.romanization,
                category: PhraseCategory(rawValue: dto.category) ?? .social
            )
        }
    }
}

// MARK: - JSON DTOs

private struct CityPackPayload: Decodable {
    var entries: [EntryDTO]
    var phrases: [PhraseDTO]
}

private struct EntryDTO: Decodable {
    var id: String
    var title: String
    var body: String
    var category: String
    var tags: [String]
    var neighborhood: String?
    var isFeatured: Bool
    var sortOrder: Int
}

private struct PhraseDTO: Decodable {
    var id: String
    var originalText: String
    var translatedText: String
    var romanization: String?
    var category: String
}
