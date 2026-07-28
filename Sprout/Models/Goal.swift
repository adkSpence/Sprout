import Foundation

struct Goal: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var target: Double
    var current: Double
    var deadline: Date

    init(id: UUID = UUID(), name: String, icon: String, target: Double, current: Double, deadline: Date) {
        self.id = id
        self.name = name
        self.icon = icon
        self.target = target
        self.current = current
        self.deadline = deadline
    }

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1)
    }
}

enum BudgetPeriod: String, CaseIterable, Identifiable, Codable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"

    var id: String { rawValue }
}

struct Budget: Identifiable, Codable {
    let id: UUID
    var name: String
    var period: BudgetPeriod
    var amount: Double
    var categoryIDs: [UUID]
    var spent: Double

    init(id: UUID = UUID(), name: String, period: BudgetPeriod, amount: Double, categoryIDs: [UUID], spent: Double) {
        self.id = id
        self.name = name
        self.period = period
        self.amount = amount
        self.categoryIDs = categoryIDs
        self.spent = spent
    }

    var remaining: Double { max(amount - spent, 0) }
    var progress: Double {
        guard amount > 0 else { return 0 }
        return min(spent / amount, 1)
    }
}
