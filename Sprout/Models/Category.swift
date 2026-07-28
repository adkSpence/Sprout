import SwiftUI

enum CategoryKind: String, Codable {
    case expense, income
}

struct Subcategory: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String

    init(id: UUID = UUID(), name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var kind: CategoryKind
    var subcategories: [Subcategory]

    init(id: UUID = UUID(), name: String, icon: String, kind: CategoryKind = .expense, subcategories: [Subcategory] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.kind = kind
        self.subcategories = subcategories
    }
}
