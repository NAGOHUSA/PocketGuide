import SwiftUI

/// Offline phrase book — browse and search pre-downloaded translations.
struct TranslationView: View {

    let cityPack: CityPack
    @State private var searchText = ""
    @State private var selectedCategory: PhraseCategory?

    private var filteredPhrases: [Phrase] {
        cityPack.phrases.filter { phrase in
            if let cat = selectedCategory, phrase.category != cat { return false }
            if !searchText.isEmpty {
                return phrase.originalText.localizedCaseInsensitiveContains(searchText) ||
                       phrase.translatedText.localizedCaseInsensitiveContains(searchText)
            }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryPicker

                if filteredPhrases.isEmpty {
                    emptyState
                } else {
                    phraseList
                }
            }
            .searchable(text: $searchText, prompt: "Search phrases")
            .navigationTitle("Phrases")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    offlineBadge
                }
            }
        }
    }

    // MARK: - Subviews

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(nil, label: "All")
                ForEach(PhraseCategory.allCases, id: \.self) { cat in
                    filterChip(cat, label: cat.rawValue)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.secondarySystemBackground))
    }

    private var phraseList: some View {
        List(filteredPhrases) { phrase in
            PhraseRow(phrase: phrase)
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "character.bubble")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No phrases found")
                .font(.headline)
            Text("Try a different search or category.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var offlineBadge: some View {
        Label("Offline", systemImage: "antenna.radiowaves.left.and.right.slash")
            .font(.caption)
            .foregroundStyle(.green)
    }

    @ViewBuilder
    private func filterChip(_ category: PhraseCategory?, label: String) -> some View {
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

// MARK: - PhraseRow

struct PhraseRow: View {
    let phrase: Phrase
    @State private var isCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Original (English)
            Text(phrase.originalText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Translated text
            Text(phrase.translatedText)
                .font(.body.bold())

            // Romanization (e.g. romaji)
            if let romanization = phrase.romanization {
                Text(romanization)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label(phrase.category.rawValue, systemImage: phrase.category.systemImage)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Spacer()

                Button {
                    UIPasteboard.general.string = phrase.translatedText
                    isCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isCopied = false
                    }
                } label: {
                    Label(isCopied ? "Copied!" : "Copy", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption2)
                        .foregroundStyle(isCopied ? .green : .accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
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
    pack.phrases = SampleDataProvider.phrases(for: "tokyo")
    return TranslationView(cityPack: pack)
}
