import SwiftUI

/// App information, privacy policy, and links.
struct AboutView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.accentColor)
                        Text("PocketGuide")
                            .font(.title.bold())
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .listRowBackground(Color.clear)

                Section("How It Works") {
                    featureRow(
                        icon: "cpu",
                        color: .purple,
                        title: "On-Device AI (Apple Intelligence)",
                        detail: "Your AI travel assistant runs entirely on your iPhone using Apple's on-device language models. No cloud servers. No data sent anywhere."
                    )
                    featureRow(
                        icon: "wifi.slash",
                        color: .blue,
                        title: "100% Offline",
                        detail: "Once you download a City Pack, everything works without any internet connection—perfect for dead zones and international travel."
                    )
                    featureRow(
                        icon: "lock.shield.fill",
                        color: .green,
                        title: "Privacy First",
                        detail: "Your questions, location, and travel habits never leave your device. PocketGuide has no analytics, no tracking, and no accounts required."
                    )
                    featureRow(
                        icon: "bag.fill",
                        color: .orange,
                        title: "City Packs",
                        detail: "Each City Pack is a one-time $4.99 purchase that includes AI context, offline maps, cultural guides, and a phrase book for one destination."
                    )
                }

                Section("Technology") {
                    infoRow("AI Engine", value: "Apple Intelligence (on-device)")
                    infoRow("Maps", value: "Apple Maps (MapKit)")
                    infoRow("Purchases", value: "StoreKit 2")
                    infoRow("Storage", value: "SwiftData (local only)")
                    infoRow("Minimum iOS", value: "iOS 18.1+")
                }
            }
            .navigationTitle("About")
        }
    }

    private func featureRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.gradient)
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline)
        }
    }
}

#Preview {
    AboutView()
}
