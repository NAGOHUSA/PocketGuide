import Foundation
import SwiftData

// MARK: - Phrase

/// A translated phrase stored in a CityPack for offline use.
/// Covers greetings, directions, food ordering, emergencies, and more.
@Model
final class Phrase: Identifiable {
    @Attribute(.unique) var id: String
    var cityPackID: String
    var originalText: String
    var translatedText: String
    var romanization: String?  // e.g. romaji for Japanese
    var category: PhraseCategory
    var audioFileName: String?  // pre-recorded pronunciation clip

    init(
        id: String,
        cityPackID: String,
        originalText: String,
        translatedText: String,
        romanization: String? = nil,
        category: PhraseCategory,
        audioFileName: String? = nil
    ) {
        self.id = id
        self.cityPackID = cityPackID
        self.originalText = originalText
        self.translatedText = translatedText
        self.romanization = romanization
        self.category = category
        self.audioFileName = audioFileName
    }
}

// MARK: - PhraseCategory

enum PhraseCategory: String, Codable, CaseIterable, Sendable {
    case greetings    = "Greetings"
    case directions   = "Directions"
    case food         = "Food & Dining"
    case shopping     = "Shopping"
    case emergency    = "Emergency"
    case transport    = "Transport"
    case accommodation = "Accommodation"
    case social       = "Social"

    var systemImage: String {
        switch self {
        case .greetings:      return "hand.wave.fill"
        case .directions:     return "signpost.right.fill"
        case .food:           return "fork.knife"
        case .shopping:       return "bag.fill"
        case .emergency:      return "cross.case.fill"
        case .transport:      return "tram.fill"
        case .accommodation:  return "house.fill"
        case .social:         return "person.2.fill"
        }
    }
}
