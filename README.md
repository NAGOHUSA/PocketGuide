# PocketGuide

An offline-first iOS travel guide that uses **Apple's on-device LLMs (Apple Intelligence)** to answer your travel questions—no Wi-Fi or cellular data required.

---

## The Problem

Most AI travel assistants stop working the moment you leave a strong connection: hiking in the Alps, navigating Tokyo's subway in a dead zone, or trying to avoid expensive data roaming abroad.

## The Solution

PocketGuide pre-downloads everything you need to a **City Pack**—offline maps, cultural etiquette, phrase books, and AI context—so your on-device assistant keeps working wherever you are.

---

## Features

| Feature | Details |
|---|---|
| 🤖 **On-Device AI** | Uses Apple Intelligence (FoundationModels framework) for local LLM inference. No cloud, no API keys, no data sent anywhere. |
| 📴 **100% Offline** | City Packs download all content to your device via SwiftData. Works in airplane mode, abroad, and in dead zones. |
| 🗺️ **Offline Maps** | MapKit with cached map tiles centred on each destination. |
| 💬 **Phrase Book** | Pre-translated phrases with romanization, organised by category (greetings, directions, food, emergency, etc.). |
| 📖 **Guide Articles** | Curated entries covering transport, sights, food, culture, safety, and emergency info. |
| 🔒 **Privacy First** | Zero analytics. No accounts required. All data stays on your device. |
| 💰 **City Packs** | One-time $4.99 purchase per destination via StoreKit 2. No subscriptions. |

---

## Available City Packs

| City | Country | Pack Size |
|---|---|---|
| Tokyo | Japan | ~143 MB |
| Paris | France | ~138 MB |
| Swiss Alps | Switzerland | ~98 MB |
| Barcelona | Spain | ~126 MB |
| New York City | United States | ~155 MB |

---

## Architecture

```
PocketGuide/
├── PocketGuideApp.swift          # App entry point, SwiftData container setup
├── Models/
│   ├── CityPack.swift            # @Model: purchasable city pack bundle
│   ├── TravelEntry.swift         # @Model: guide article with category
│   └── Phrase.swift              # @Model: translated phrase with romanization
├── Services/
│   ├── OfflineLLMService.swift   # Apple Intelligence on-device LLM wrapper
│   ├── CityPackManager.swift     # SwiftData CRUD + download lifecycle
│   ├── SampleDataProvider.swift  # Seed data for Tokyo, Paris, Alps
│   └── StoreManager.swift        # StoreKit 2 IAP for City Packs
├── Views/
│   ├── ContentView.swift         # Root tab view
│   ├── HomeView.swift            # Downloaded packs list
│   ├── CityDetailView.swift      # Tabbed city guide (overview/entries/phrases/map/AI)
│   ├── TravelAssistantView.swift # Streaming AI chat interface
│   ├── TranslationView.swift     # Offline phrase book with copy-to-clipboard
│   ├── StoreView.swift           # City Pack store (purchase & download)
│   └── AboutView.swift           # App info and how-it-works
└── Resources/
    └── SampleData/
        └── tokyo.json            # Bundled Tokyo guide content
```

---

## How On-Device AI Works

The `OfflineLLMService` wraps Apple's **FoundationModels** framework introduced with Apple Intelligence:

```swift
// Real implementation (iOS 26 SDK):
let session = LanguageModelSession(
    model: .default,
    instructions: Instructions(systemPrompt)
)
let response = try await session.respond(to: Prompt(userQuestion))
```

When a user opens a City Pack, the service loads a city-specific system prompt that includes pre-downloaded travel context (etiquette rules, transport guides, emergency info). The model then answers questions using only this local knowledge—no internet required.

On the simulator or devices without Apple Intelligence, the service falls back to pre-written contextual responses so the full UI remains functional during development.

---

## Requirements

- **iOS 18.1+** (iOS 26 recommended for full Apple Intelligence support)
- **Xcode 16+**
- **Apple Developer account** (for StoreKit testing and device deployment)

---

## Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/NAGOHUSA/PocketGuide.git
   cd PocketGuide
   ```

2. **Open in Xcode**
   ```bash
   open PocketGuide.xcodeproj
   ```

3. **Configure StoreKit** (optional for IAP testing)  
   Add a `Products.storekit` configuration file with the City Pack product IDs from `CityPack.catalog`. Select it in the scheme's **StoreKit Configuration** setting.

4. **Run on device or simulator**  
   City Pack purchases and on-device AI inference require a real device with Apple Intelligence. The app displays a graceful fallback message on unsupported devices.

---

## Running Tests

```bash
xcodebuild test \
  -scheme PocketGuide \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -testPlan PocketGuideTests
```

Tests cover:
- CityPack model initialisation and catalog validation
- CityPackManager CRUD operations (in-memory SwiftData)
- SampleDataProvider data integrity checks
- OfflineLLMService response generation

---

## Business Model

- **One-time purchase**: $4.99 per City Pack (non-consumable IAP)
- **No server costs**: All AI inference runs on-device via Apple Intelligence
- **No subscriptions**: Buy once, use forever, works offline forever
- **Target market**: Digital nomads, international travelers, hikers, backpackers

---

## Privacy

PocketGuide collects **no data**. There are no analytics SDKs, no crash reporters phoning home, and no user accounts. Your questions to the AI assistant are processed entirely on your iPhone and never leave it.

---

## License

MIT
