import SwiftUI

enum WalletType: String, CaseIterable, Identifiable, Codable {
    case cash = "Cash"
    case card = "Card"
    case bank = "Bank"
    case savings = "Savings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .cash: return "banknote"
        case .card: return "creditcard"
        case .bank: return "building.columns"
        case .savings: return "piggy.bank"
        }
    }
}

struct Wallet: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: WalletType
    var currency: Currency
    var balance: Double

    init(id: UUID = UUID(), name: String, type: WalletType, currency: Currency, balance: Double) {
        self.id = id
        self.name = name
        self.type = type
        self.currency = currency
        self.balance = balance
    }

    var balanceLabel: String { currency.format(balance) }
}
