import Foundation

// MARK: - SampleDataProvider
//
// Hard-coded seed data used when a bundled JSON file is not found.
// This keeps the app functional in the simulator and during UI previews.

enum SampleDataProvider {

    // MARK: - Entries

    static func entries(for cityID: String) -> [TravelEntry] {
        switch cityID {
        case "tokyo":   return tokyoEntries
        case "paris":   return parisEntries
        case "alps":    return alpsEntries
        default:        return genericEntries(cityID: cityID)
        }
    }

    // MARK: - Phrases

    static func phrases(for cityID: String) -> [Phrase] {
        switch cityID {
        case "tokyo":   return tokyoPhrases
        case "paris":   return parisPhrases
        case "alps":    return alpsPhrases
        default:        return []
        }
    }

    // MARK: - Tokyo entries

    private static let tokyoEntries: [TravelEntry] = [
        TravelEntry(
            id: "tokyo-transport-1",
            cityPackID: "tokyo",
            title: "Navigating the Tokyo Metro",
            body: """
            Tokyo's subway system is one of the world's most extensive, with 13 lines serving over 280 stations. \
            Buy a Suica or Pasmo IC card at any station—these work on all trains, buses, and even convenience stores. \
            The IC card costs ¥500 deposit and can be topped up at machines or via Apple Pay. \
            Key lines for tourists: Yamanote Line (JR, loops around central Tokyo), Ginza Line (oldest, connects Asakusa to Shibuya), \
            and Chuo/Sobu Line (east-west across the city). Always stand on the left side of escalators, \
            and keep phone calls silent on the train.
            """,
            category: .gettingAround,
            tags: ["subway", "metro", "IC card", "Suica", "Pasmo"],
            neighborhood: "Citywide",
            isFeatured: true,
            sortOrder: 1
        ),
        TravelEntry(
            id: "tokyo-culture-1",
            cityPackID: "tokyo",
            title: "Essential Japanese Etiquette",
            body: """
            Japan has a rich culture of respect and consideration. Key customs to follow: \
            Remove your shoes before entering a home or traditional restaurant (look for a step-up area called 'genkan'). \
            Bow slightly when greeting—the deeper the bow, the more formal the gesture. \
            Never stick chopsticks upright in rice; it resembles funeral offerings. \
            Slurping noodles is considered a compliment to the chef. \
            Tipping is not practiced and can be considered rude. \
            Always carry cash—many small restaurants and shrines are cash-only. \
            Trash cans are rare; carry your rubbish until you find one at a convenience store.
            """,
            category: .culture,
            tags: ["etiquette", "customs", "bowing", "chopsticks"],
            neighborhood: "Citywide",
            isFeatured: true,
            sortOrder: 2
        ),
        TravelEntry(
            id: "tokyo-food-1",
            cityPackID: "tokyo",
            title: "Where to Eat in Shinjuku",
            body: """
            Shinjuku offers everything from Michelin-starred kaiseki to ¥500 ramen. \
            Omoide Yokocho ('Memory Lane') near the west exit has tiny yakitori stalls open late. \
            Takashimaya Times Square B1 and B2 floors have an excellent food hall (depachika). \
            For ramen, try the Ramen Street inside Shinjuku Station (east exit, basement level). \
            Isomaru Suisan is a reliable standing sushi chain near Kabukicho for late-night sashimi. \
            Budget: street food ¥500-1,000 · casual sit-down ¥1,000-2,500 · mid-range ¥3,000-6,000.
            """,
            category: .food,
            tags: ["ramen", "yakitori", "sushi", "Shinjuku", "depachika"],
            neighborhood: "Shinjuku",
            isFeatured: false,
            sortOrder: 3
        ),
        TravelEntry(
            id: "tokyo-sights-1",
            cityPackID: "tokyo",
            title: "Senso-ji Temple, Asakusa",
            body: """
            Senso-ji is Tokyo's oldest and most visited temple, founded in 645 AD. \
            Enter through the Kaminarimon ('Thunder Gate') with its iconic giant red lantern. \
            The Nakamise shopping street leading to the main hall sells traditional souvenirs and snacks. \
            Arrive before 8 AM to experience the temple with minimal crowds. \
            Draw an omikuji (fortune) for ¥100 from a metal box—shake until a stick falls out, find the matching drawer. \
            The five-storey pagoda and main hall are free to enter. Respectfully clap twice and bow when at the altar.
            """,
            category: .sights,
            tags: ["temple", "Asakusa", "Senso-ji", "history"],
            neighborhood: "Asakusa",
            isFeatured: true,
            sortOrder: 4
        ),
        TravelEntry(
            id: "tokyo-emergency-1",
            cityPackID: "tokyo",
            title: "Emergency Information",
            body: """
            Emergency numbers in Japan: Police 110 · Ambulance/Fire 119. \
            Tokyo Metropolitan Police has a 24-hour English helpline: 03-3501-0110. \
            Japan Helpline (English, 24h): 0570-000-911. \
            Nearest large hospitals with English services: \
            St. Luke's International Hospital (Tsukiji): 03-5550-7166 · \
            Tokyo Medical and Surgical Clinic (Toranomon): 03-3436-3028 · \
            International Clinic Tokyo (Roppongi): 03-3583-7831. \
            Japan does not have a national 112 emergency number—use 110 or 119.
            """,
            category: .emergency,
            tags: ["emergency", "police", "hospital", "English helpline"],
            neighborhood: "Citywide",
            isFeatured: false,
            sortOrder: 5
        )
    ]

    // MARK: - Paris entries

    private static let parisEntries: [TravelEntry] = [
        TravelEntry(
            id: "paris-transport-1",
            cityPackID: "paris",
            title: "Using the Paris Métro",
            body: """
            The Paris Métro has 16 lines covering the city and inner suburbs. \
            Buy a carnet of 10 tickets (t+ tickets) for best value, or a Navigo Découverte weekly pass. \
            The Navigo card costs €5 and covers unlimited travel on zones 1-5 from Monday to Sunday. \
            Validate your ticket every time you board—inspectors issue spot fines. \
            Night buses (Noctilien) run when the Métro closes (around 1:15 AM on weekdays, 2:15 AM Fri/Sat). \
            Pick-pocketing is common in tourist areas and on busy lines (1, 4)—keep bags in front.
            """,
            category: .gettingAround,
            tags: ["metro", "Navigo", "transport", "bus"],
            neighborhood: "Citywide",
            isFeatured: true,
            sortOrder: 1
        ),
        TravelEntry(
            id: "paris-culture-1",
            cityPackID: "paris",
            title: "French Dining Etiquette",
            body: """
            Meals in France are a social ritual. Key rules: \
            Always greet with 'Bonjour' before asking for anything—skipping this is considered rude. \
            Restaurants typically have two sittings; arrive on time for your reservation. \
            Bread is placed directly on the table or tablecloth, not on the plate. \
            Ask for the check ('L'addition, s'il vous plaît')—it won't be brought automatically. \
            Service is included by law (service compris) but leaving 5-10% extra is appreciated. \
            Lunch (12–2 PM) is often better value than dinner; look for 'formule' or 'menu du jour'.
            """,
            category: .culture,
            tags: ["dining", "etiquette", "restaurants", "tipping"],
            neighborhood: "Citywide",
            isFeatured: true,
            sortOrder: 2
        ),
        TravelEntry(
            id: "paris-sights-1",
            cityPackID: "paris",
            title: "The Eiffel Tower",
            body: """
            Book Eiffel Tower tickets online months in advance—walk-up queues can be 3+ hours. \
            The summit (floors 1, 2, and top) tickets are separate; the top floor has the best view. \
            The tower sparkles for 5 minutes on the hour every evening from dusk until 1 AM—best viewed from Trocadéro or Champ de Mars. \
            Climbing the stairs to floor 2 is allowed and cheaper; it also skips most of the crowd. \
            Nearby: Champ de Mars gardens (free, great picnic spot), Musée du quai Branly (world cultures).
            """,
            category: .sights,
            tags: ["Eiffel Tower", "landmark", "tickets", "views"],
            neighborhood: "7th arrondissement",
            isFeatured: true,
            sortOrder: 3
        )
    ]

    // MARK: - Alps entries

    private static let alpsEntries: [TravelEntry] = [
        TravelEntry(
            id: "alps-safety-1",
            cityPackID: "alps",
            title: "Mountain Hiking Safety",
            body: """
            The Alps demand respect. Follow the 'Alpine Rule of Thumb': turn back if weather changes or you feel uncertain. \
            Always register your hike plan with the hotel or local tourism office. \
            Essential gear: layered clothing, waterproof jacket, sun cream (UV is intense at altitude), hat, \
            sturdy boots with ankle support, and at least 2L of water per person. \
            Weather can change in minutes; afternoon thunderstorms are common June–August. \
            If caught in a storm: descend immediately, avoid ridgelines and lone trees, crouch low if lightning is close. \
            Emergency mountain rescue: 112 (EU universal) or 1414 (Swiss Air Rescue, REGA).
            """,
            category: .safety,
            tags: ["hiking", "mountain safety", "weather", "emergency"],
            neighborhood: "Alpine Trails",
            isFeatured: true,
            sortOrder: 1
        ),
        TravelEntry(
            id: "alps-transport-1",
            cityPackID: "alps",
            title: "Getting Around the Swiss Alps",
            body: """
            Switzerland's mountain transport is exceptionally reliable. \
            The Swiss Travel Pass covers trains, buses, boats, and many cable cars—excellent value for multi-day trips. \
            Cogwheel railways (Zahnradbahn) serve high mountain stations like Jungfraujoch and Gornergrat. \
            PostBus connects remote villages not served by rail; runs on a strict schedule—don't miss it. \
            Cycling is popular in valley floors; e-bikes are available for rent in most resort towns. \
            Driving: mountain roads have strict right-of-way rules—uphill traffic has priority on narrow roads. \
            A Swiss motorway vignette (CHF 40) is required on highways; sold at border crossings and gas stations.
            """,
            category: .gettingAround,
            tags: ["Swiss Travel Pass", "trains", "PostBus", "cable car"],
            neighborhood: "Countrywide",
            isFeatured: true,
            sortOrder: 2
        )
    ]

    // MARK: - Generic fallback entries

    private static func genericEntries(cityID: String) -> [TravelEntry] {
        [
            TravelEntry(
                id: "\(cityID)-practical-1",
                cityPackID: cityID,
                title: "Getting Around",
                body: "Your city pack includes detailed transport guides. Check the 'Getting Around' section for subway maps, bus routes, and tips on local transport.",
                category: .gettingAround,
                tags: ["transport"],
                isFeatured: true,
                sortOrder: 1
            )
        ]
    }

    // MARK: - Tokyo phrases

    private static let tokyoPhrases: [Phrase] = [
        Phrase(id: "tokyo-phrase-1", cityPackID: "tokyo", originalText: "Hello / Good day", translatedText: "こんにちは", romanization: "Konnichiwa", category: .greetings),
        Phrase(id: "tokyo-phrase-2", cityPackID: "tokyo", originalText: "Thank you very much", translatedText: "ありがとうございます", romanization: "Arigatō gozaimasu", category: .greetings),
        Phrase(id: "tokyo-phrase-3", cityPackID: "tokyo", originalText: "Excuse me / Sorry", translatedText: "すみません", romanization: "Sumimasen", category: .social),
        Phrase(id: "tokyo-phrase-4", cityPackID: "tokyo", originalText: "Where is the subway station?", translatedText: "地下鉄の駅はどこですか？", romanization: "Chikatetsu no eki wa doko desu ka?", category: .directions),
        Phrase(id: "tokyo-phrase-5", cityPackID: "tokyo", originalText: "I would like this, please", translatedText: "これをください", romanization: "Kore o kudasai", category: .food),
        Phrase(id: "tokyo-phrase-6", cityPackID: "tokyo", originalText: "How much does this cost?", translatedText: "いくらですか？", romanization: "Ikura desu ka?", category: .shopping),
        Phrase(id: "tokyo-phrase-7", cityPackID: "tokyo", originalText: "Please call an ambulance", translatedText: "救急車を呼んでください", romanization: "Kyūkyūsha o yonde kudasai", category: .emergency),
        Phrase(id: "tokyo-phrase-8", cityPackID: "tokyo", originalText: "I don't understand Japanese", translatedText: "日本語がわかりません", romanization: "Nihongo ga wakarimasen", category: .social),
        Phrase(id: "tokyo-phrase-9", cityPackID: "tokyo", originalText: "Do you have an English menu?", translatedText: "英語のメニューはありますか？", romanization: "Eigo no menyū wa arimasu ka?", category: .food),
        Phrase(id: "tokyo-phrase-10", cityPackID: "tokyo", originalText: "One ticket to [destination], please", translatedText: "[目的地]まで一枚ください", romanization: "[Mokuteki-chi] made ichimai kudasai", category: .transport)
    ]

    // MARK: - Paris phrases

    private static let parisPhrases: [Phrase] = [
        Phrase(id: "paris-phrase-1", cityPackID: "paris", originalText: "Hello / Good day", translatedText: "Bonjour", category: .greetings),
        Phrase(id: "paris-phrase-2", cityPackID: "paris", originalText: "Thank you very much", translatedText: "Merci beaucoup", category: .greetings),
        Phrase(id: "paris-phrase-3", cityPackID: "paris", originalText: "Excuse me", translatedText: "Excusez-moi", category: .social),
        Phrase(id: "paris-phrase-4", cityPackID: "paris", originalText: "Where is the nearest Métro station?", translatedText: "Où est la station de Métro la plus proche ?", category: .directions),
        Phrase(id: "paris-phrase-5", cityPackID: "paris", originalText: "The bill, please", translatedText: "L'addition, s'il vous plaît", category: .food),
        Phrase(id: "paris-phrase-6", cityPackID: "paris", originalText: "How much is this?", translatedText: "Combien ça coûte ?", category: .shopping),
        Phrase(id: "paris-phrase-7", cityPackID: "paris", originalText: "Call the police", translatedText: "Appelez la police", category: .emergency),
        Phrase(id: "paris-phrase-8", cityPackID: "paris", originalText: "I'm lost", translatedText: "Je suis perdu(e)", category: .directions),
        Phrase(id: "paris-phrase-9", cityPackID: "paris", originalText: "A table for two, please", translatedText: "Une table pour deux, s'il vous plaît", category: .food),
        Phrase(id: "paris-phrase-10", cityPackID: "paris", originalText: "I don't speak French", translatedText: "Je ne parle pas français", category: .social)
    ]

    // MARK: - Alps (multilingual) phrases

    private static let alpsPhrases: [Phrase] = [
        Phrase(id: "alps-phrase-1", cityPackID: "alps", originalText: "Hello (German)", translatedText: "Hallo / Grüezi (Swiss German)", category: .greetings),
        Phrase(id: "alps-phrase-2", cityPackID: "alps", originalText: "Hello (French)", translatedText: "Bonjour (Swiss French)", category: .greetings),
        Phrase(id: "alps-phrase-3", cityPackID: "alps", originalText: "Hello (Italian)", translatedText: "Buongiorno (Swiss Italian)", category: .greetings),
        Phrase(id: "alps-phrase-4", cityPackID: "alps", originalText: "Where is the trail to [peak]?", translatedText: "Wo ist der Weg nach [Gipfel]? (DE)", romanization: "Wo ist der Weg nach [Gipfel]?", category: .directions),
        Phrase(id: "alps-phrase-5", cityPackID: "alps", originalText: "I need mountain rescue", translatedText: "Ich brauche Bergrettung (DE) · J'ai besoin d'un sauvetage en montagne (FR)", category: .emergency),
        Phrase(id: "alps-phrase-6", cityPackID: "alps", originalText: "How long to the summit?", translatedText: "Wie lange bis zum Gipfel? (DE)", category: .directions),
        Phrase(id: "alps-phrase-7", cityPackID: "alps", originalText: "A room for one night, please", translatedText: "Ein Zimmer für eine Nacht, bitte (DE)", category: .accommodation),
        Phrase(id: "alps-phrase-8", cityPackID: "alps", originalText: "The weather is changing", translatedText: "Das Wetter ändert sich (DE) · La météo change (FR)", category: .directions)
    ]
}
