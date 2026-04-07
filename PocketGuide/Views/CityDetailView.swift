import SwiftUI
import MapKit

/// Detailed offline guide for a downloaded City Pack.
/// Tabs: Overview, Guide Entries, Phrases, Map, AI Assistant.
struct CityDetailView: View {

    let cityPack: CityPack
    @EnvironmentObject private var llmService: OfflineLLMService
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            OverviewTab(cityPack: cityPack)
                .tag(0)
                .tabItem { Label("Overview", systemImage: "doc.text.fill") }

            EntriesTab(cityPack: cityPack)
                .tag(1)
                .tabItem { Label("Guide", systemImage: "list.bullet") }

            TranslationView(cityPack: cityPack)
                .tag(2)
                .tabItem { Label("Phrases", systemImage: "character.bubble.fill") }

            OfflineMapView(cityPack: cityPack)
                .tag(3)
                .tabItem { Label("Map", systemImage: "map.fill") }

            TravelAssistantView(cityPack: cityPack)
                .tag(4)
                .tabItem { Label("AI Guide", systemImage: "sparkles") }
        }
        .navigationTitle(cityPack.city)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Pre-load city context into the LLM service
            llmService.loadCityContext(buildCityContext())
        }
    }

    // MARK: - City context for LLM

    private func buildCityContext() -> String {
        let entrySnippets = cityPack.entries
            .prefix(10)
            .map { "[\($0.category.rawValue)] \($0.title): \($0.body.prefix(200))" }
            .joined(separator: "\n\n")

        return """
        You are helping a traveler visiting \(cityPack.city), \(cityPack.country).
        
        Key information from their downloaded city pack:
        
        \(entrySnippets)
        
        The traveler is currently offline. Provide practical, accurate advice based on this pre-loaded content.
        """
    }
}

// MARK: - OverviewTab

private struct OverviewTab: View {
    let cityPack: CityPack

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero banner
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [.accentColor, .accentColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(cityPack.city)
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        Text("\(cityPack.country) · \(cityPack.region)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding()
                }
                .padding(.horizontal)

                // Offline badge
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    let downloadedLabel = cityPack.downloadedAt.map { formattedDate($0) } ?? "recently"
                    Text("100% Offline · Downloaded \(downloadedLabel)")
                        .font(.footnote)
                }
                .foregroundStyle(.green)
                .padding(.horizontal)

                // Overview text
                VStack(alignment: .leading, spacing: 8) {
                    Text("About this pack")
                        .font(.headline)
                    Text(cityPack.overview)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Stats row
                HStack(spacing: 0) {
                    statItem(value: "\(cityPack.entries.count)", label: "Articles")
                    Divider().frame(height: 40)
                    statItem(value: "\(cityPack.phrases.count)", label: "Phrases")
                    Divider().frame(height: 40)
                    statItem(value: String(format: "%.0f MB", cityPack.sizeInMB), label: "Pack size")
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.title3.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
}

// MARK: - EntriesTab

private struct EntriesTab: View {
    let cityPack: CityPack
    @State private var selectedCategory: EntryCategory?
    @State private var searchText = ""

    private var filteredEntries: [TravelEntry] {
        cityPack.entries
            .filter { entry in
                if let cat = selectedCategory, entry.category != cat { return false }
                if !searchText.isEmpty {
                    return entry.title.localizedCaseInsensitiveContains(searchText) ||
                           entry.body.localizedCaseInsensitiveContains(searchText)
                }
                return true
            }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        NavigationStack {
            List {
                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        categoryChip(nil, label: "All")
                        ForEach(EntryCategory.allCases, id: \.self) { cat in
                            categoryChip(cat, label: cat.rawValue)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                ForEach(filteredEntries) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                        EntryRow(entry: entry)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search guide")
            .listStyle(.plain)
            .navigationTitle("Guide")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func categoryChip(_ category: EntryCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        Button {
            selectedCategory = isSelected ? nil : category
        } label: {
            Text(label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemFill))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - EntryRow

struct EntryRow: View {
    let entry: TravelEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: entry.category.systemImage)
                    .foregroundStyle(.accentColor)
                Text(entry.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if entry.isFeatured {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }
            Text(entry.title)
                .font(.headline)
            Text(entry.body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - EntryDetailView

struct EntryDetailView: View {
    let entry: TravelEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(entry.category.rawValue, systemImage: entry.category.systemImage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(entry.title)
                    .font(.title2.bold())

                Text(entry.body)
                    .font(.body)

                if !entry.tags.isEmpty {
                    FlowLayout(entry.tags) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
        }
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - OfflineMapView

struct OfflineMapView: View {
    let cityPack: CityPack

    @State private var position: MapCameraPosition

    init(cityPack: CityPack) {
        self.cityPack = cityPack
        _position = State(initialValue: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: cityPack.latitude,
                    longitude: cityPack.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        ))
    }

    var body: some View {
        Map(position: $position)
            .overlay(alignment: .bottom) {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    Text("Map tiles are cached for offline use")
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.bottom, 12)
            }
            .mapStyle(.standard)
            .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - FlowLayout (simple tag layout)

struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let content: (Data.Element) -> Content

    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    var body: some View {
        _FlowLayout(spacing: 6) {
            ForEach(Array(data), id: \.self) { item in
                content(item)
            }
        }
    }
}

private struct _FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
