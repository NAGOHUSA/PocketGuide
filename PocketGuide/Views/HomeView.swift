import SwiftUI
import SwiftData

/// Displays the user's downloaded City Packs and an empty-state prompt
/// to visit the store if none have been downloaded yet.
struct HomeView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<CityPack> { $0.isDownloaded },
        sort: \CityPack.city
    )
    private var downloadedPacks: [CityPack]

    @State private var selectedPack: CityPack?

    var body: some View {
        NavigationStack {
            Group {
                if downloadedPacks.isEmpty {
                    emptyState
                } else {
                    packList
                }
            }
            .navigationTitle("My Guides")
            .navigationDestination(item: $selectedPack) { pack in
                CityDetailView(cityPack: pack)
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "map")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("No City Packs Yet")
                    .font(.title2.bold())

                Text("Download a City Pack from the store to explore destinations 100% offline—no Wi-Fi required.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Label("Works in dead zones & abroad", systemImage: "antenna.radiowaves.left.and.right.slash")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var packList: some View {
        List {
            Section {
                ForEach(downloadedPacks) { pack in
                    Button {
                        selectedPack = pack
                    } label: {
                        CityPackRow(pack: pack)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Label("Offline & ready", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.footnote.weight(.semibold))
                    .textCase(nil)
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - CityPackRow

struct CityPackRow: View {
    let pack: CityPack

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.gradient)
                    .frame(width: 50, height: 50)
                Image(systemName: "map.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(pack.city)
                    .font(.headline)
                Text(pack.country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: CityPack.self, TravelEntry.self, Phrase.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let sample = CityPack(
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
    sample.isDownloaded = true
    container.mainContext.insert(sample)

    return HomeView()
        .modelContainer(container)
        .environmentObject(StoreManager())
        .environmentObject(OfflineLLMService())
}
