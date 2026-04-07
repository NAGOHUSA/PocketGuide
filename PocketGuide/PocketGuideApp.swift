import SwiftUI
import SwiftData

@main
struct PocketGuideApp: App {

    // MARK: - SwiftData container

    let modelContainer: ModelContainer = {
        let schema = Schema([
            CityPack.self,
            TravelEntry.self,
            Phrase.self
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    // MARK: - Shared services

    @StateObject private var storeManager = StoreManager()
    @StateObject private var llmService = OfflineLLMService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environmentObject(storeManager)
                .environmentObject(llmService)
                .onAppear {
                    seedCatalog()
                }
        }
    }

    // MARK: - Helpers

    private func seedCatalog() {
        let context = modelContainer.mainContext
        let manager = CityPackManager(modelContext: context)
        try? manager.seedCatalogIfNeeded()
    }
}
