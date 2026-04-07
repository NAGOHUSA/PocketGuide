import SwiftUI

/// Root view — a tab bar with My Guides, Store, and App Info tabs.
struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("My Guides", systemImage: "map.fill")
                }

            StoreView()
                .tabItem {
                    Label("City Packs", systemImage: "bag.fill")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CityPack.self, TravelEntry.self, Phrase.self],
                        inMemory: true)
        .environmentObject(StoreManager())
        .environmentObject(OfflineLLMService())
}
