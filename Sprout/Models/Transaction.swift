import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    var walletID: UUID
    var categoryID: UUID
    var subcategoryID: UUID?
    var kind: CategoryKind
    var amount: Double
    var date: Date
    var note: String

    init(
        id: UUID = UUID(),
        walletID: UUID,
        categoryID: UUID,
        subcategoryID: UUID? = nil,
        kind: CategoryKind,
        amount: Double,
        date: Date,
        note: String = ""
    ) {
        self.id = id
        self.walletID = walletID
        self.categoryID = categoryID
        self.subcategoryID = subcategoryID
        self.kind = kind
        self.amount = amount
        self.date = date
        self.note = note
    }
}
