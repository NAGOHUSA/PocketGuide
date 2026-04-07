import SwiftUI
import SwiftData

/// City Pack store — browse available packs, purchase for $4.99 each,
/// and download for 100% offline use.
struct StoreView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var storeManager: StoreManager
    @StateObject private var packManager: CityPackManager

    @Query(sortBy: \CityPack.city) private var allPacks: [CityPack]
    @State private var downloadingIDs: Set<String> = []
    @State private var showRestoreAlert = false

    init() {
        // We can't inject modelContext at init time, so we initialize with
        // a placeholder; the real context is set in onAppear.
        _packManager = StateObject(wrappedValue: CityPackManager(
            modelContext: ModelContext(try! ModelContainer(
                for: CityPack.self, TravelEntry.self, Phrase.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            ))
        ))
    }

    var body: some View {
        NavigationStack {
            List {
                // Header section
                Section {
                    valuePropBanner
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                // City packs
                Section("Available City Packs") {
                    ForEach(allPacks) { pack in
                        CityPackStoreRow(
                            pack: pack,
                            isDownloading: downloadingIDs.contains(pack.id),
                            onPurchase: { handlePurchase(pack) },
                            onDownload: { handleDownload(pack) }
                        )
                    }
                }

                // Restore purchases
                Section {
                    Button("Restore Purchases") {
                        Task {
                            await storeManager.restorePurchases()
                            showRestoreAlert = true
                        }
                    }
                    .foregroundStyle(.accentColor)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("City Packs")
            .alert("Purchases Restored", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Any previously purchased city packs have been restored to your account.")
            }
        }
    }

    // MARK: - Value Prop Banner

    private var valuePropBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 36))
                .foregroundStyle(.accentColor)

            Text("Works 100% Offline")
                .font(.title3.bold())

            Text("Each City Pack pre-downloads maps, cultural guides, phrase books, and an AI travel assistant to your device. Perfect for dead zones, expensive data plans, or anywhere you travel.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 20) {
                featurePill("On-Device AI", icon: "cpu")
                featurePill("Offline Maps", icon: "map.fill")
                featurePill("Phrase Book", icon: "character.bubble.fill")
            }
        }
        .padding()
    }

    private func featurePill(_ text: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.accentColor)
            Text(text)
                .font(.caption2.weight(.medium))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Actions

    private func handlePurchase(_ pack: CityPack) {
        Task {
            let purchased = await storeManager.purchase(productID: pack.storeProductID)
            if purchased {
                pack.isPurchased = true
                try? modelContext.save()
                handleDownload(pack)
            }
        }
    }

    private func handleDownload(_ pack: CityPack) {
        downloadingIDs.insert(pack.id)
        let ctx = modelContext
        Task {
            let mgr = CityPackManager(modelContext: ctx)
            await mgr.downloadPack(descriptor: CityPackDescriptor(
                id: pack.id,
                city: pack.city,
                country: pack.country,
                region: pack.region,
                storeProductID: pack.storeProductID,
                overview: pack.overview,
                latitude: pack.latitude,
                longitude: pack.longitude,
                sizeInMB: pack.sizeInMB,
                coverImageName: pack.coverImageName
            ))
            downloadingIDs.remove(pack.id)
        }
    }
}

// MARK: - CityPackStoreRow

struct CityPackStoreRow: View {
    let pack: CityPack
    let isDownloading: Bool
    let onPurchase: () -> Void
    let onDownload: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // City icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.gradient)
                    .frame(width: 50, height: 50)
                Image(systemName: "mappin.and.ellipse")
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(pack.city)
                    .font(.headline)
                Text("\(pack.country) · \(pack.region)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(pack.overview)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Action button
            actionButton
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var actionButton: some View {
        if isDownloading {
            ProgressView()
                .frame(width: 72)
        } else if pack.isDownloaded {
            Label("Ready", systemImage: "checkmark.circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.green)
        } else if pack.isPurchased {
            Button(action: onDownload) {
                Label("Download", systemImage: "arrow.down.circle")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        } else {
            Button(action: onPurchase) {
                Text("$4.99")
                    .font(.caption.weight(.bold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
    }
}

#Preview {
    StoreView()
        .modelContainer(for: [CityPack.self, TravelEntry.self, Phrase.self],
                        inMemory: true)
        .environmentObject(StoreManager())
}
