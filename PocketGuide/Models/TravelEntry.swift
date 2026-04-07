import Foundation
import SwiftData

// MARK: - TravelEntry

/// A single guide entry within a CityPack—covering sights, safety tips,
/// transportation, food recommendations, or cultural etiquette.
@Model
final class TravelEntry: Identifiable {
    @Attribute(.unique) var id: String
    var cityPackID: String
    var title: String
    var body: String
    var category: EntryCategory
    var tags: [String]
    var neighborhood: String?
    var isFeatured: Bool
    var sortOrder: Int

    init(
        id: String,
        cityPackID: String,
        title: String,
        body: String,
        category: EntryCategory,
        tags: [String] = [],
        neighborhood: String? = nil,
        isFeatured: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.cityPackID = cityPackID
        self.title = title
        self.body = body
        self.category = category
        self.tags = tags
        self.neighborhood = neighborhood
        self.isFeatured = isFeatured
        self.sortOrder = sortOrder
    }
}

// MARK: - EntryCategory

enum EntryCategory: String, Codable, CaseIterable, Sendable {
    case gettingAround    = "Getting Around"
    case sights           = "Sights & Attractions"
    case food             = "Food & Drink"
    case culture          = "Culture & Etiquette"
    case safety           = "Safety & Health"
    case accommodation    = "Where to Stay"
    case shopping         = "Shopping"
    case dayTrips         = "Day Trips"
    case practical        = "Practical Info"
    case emergency        = "Emergency"

    var systemImage: String {
        switch self {
        case .gettingAround:  return "tram.fill"
        case .sights:         return "binoculars.fill"
        case .food:           return "fork.knife"
        case .culture:        return "building.columns.fill"
        case .safety:         return "shield.fill"
        case .accommodation:  return "bed.double.fill"
        case .shopping:       return "bag.fill"
        case .dayTrips:       return "map.fill"
        case .practical:      return "info.circle.fill"
        case .emergency:      return "cross.case.fill"
        }
    }
}
