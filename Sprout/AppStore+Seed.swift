import Foundation

extension AppStore {
    struct SeedData {
        let wallets: [Wallet]
        let categories: [Category]
        let transactions: [Transaction]
        let goals: [Goal]
        let budgets: [Budget]
    }

    static func seedData() -> SeedData {
        let calendar = Calendar.current
        let now = Date()
        func daysAgo(_ n: Int) -> Date { calendar.date(byAdding: .day, value: -n, to: now) ?? now }

        let mainCard = Wallet(name: "Main card", type: .card, currency: .usd, balance: 2840.55)
        let cash = Wallet(name: "Cash", type: .cash, currency: .usd, balance: 165.00)
        let wallets = [mainCard, cash]

        let groceries = Category(
            name: "Groceries", icon: "cart", kind: .expense,
            subcategories: [Subcategory(name: "Supermarket", icon: "cart"), Subcategory(name: "Farmers market", icon: "leaf")]
        )
        let dining = Category(name: "Dining", icon: "cup.and.saucer", kind: .expense,
            subcategories: [Subcategory(name: "Coffee", icon: "cup.and.saucer"), Subcategory(name: "Restaurants", icon: "fork.knife")])
        let transport = Category(name: "Transport", icon: "car", kind: .expense,
            subcategories: [Subcategory(name: "Fuel", icon: "fuelpump")])
        let entertainment = Category(name: "Entertainment", icon: "film", kind: .expense, subcategories: [])
        let shopping = Category(name: "Shopping", icon: "bag", kind: .expense, subcategories: [])
        let health = Category(name: "Health", icon: "heart", kind: .expense, subcategories: [])
        let housing = Category(name: "Housing", icon: "house", kind: .expense, subcategories: [])
        let salary = Category(name: "Salary", icon: "banknote", kind: .income, subcategories: [])
        let freelance = Category(name: "Freelance", icon: "briefcase", kind: .income, subcategories: [])

        let categories = [groceries, dining, transport, entertainment, shopping, health, housing, salary, freelance]

        let transactions = [
            Transaction(walletID: mainCard.id, categoryID: salary.id, kind: .income, amount: 3200, date: daysAgo(2), note: "Monthly salary"),
            Transaction(walletID: mainCard.id, categoryID: groceries.id, subcategoryID: groceries.subcategories.first?.id, kind: .expense, amount: 84.32, date: daysAgo(1), note: "Weekly shop"),
            Transaction(walletID: cash.id, categoryID: dining.id, subcategoryID: dining.subcategories.first?.id, kind: .expense, amount: 6.50, date: daysAgo(1), note: "Coffee"),
            Transaction(walletID: mainCard.id, categoryID: transport.id, subcategoryID: transport.subcategories.first?.id, kind: .expense, amount: 42.00, date: daysAgo(3), note: "Gas"),
            Transaction(walletID: mainCard.id, categoryID: housing.id, kind: .expense, amount: 1200, date: daysAgo(5), note: "Rent"),
            Transaction(walletID: mainCard.id, categoryID: entertainment.id, kind: .expense, amount: 15.99, date: daysAgo(6), note: "Streaming"),
            Transaction(walletID: cash.id, categoryID: shopping.id, kind: .expense, amount: 58.20, date: daysAgo(8), note: "New shoes"),
        ]

        let goals = [
            Goal(name: "New laptop", icon: "laptopcomputer", target: 1800, current: 640, deadline: calendar.date(byAdding: .month, value: 4, to: now) ?? now),
            Goal(name: "Trip to Japan", icon: "airplane", target: 3200, current: 950, deadline: calendar.date(byAdding: .month, value: 9, to: now) ?? now),
        ]

        let budgets = [
            Budget(name: "Groceries", period: .monthly, amount: 400, categoryIDs: [groceries.id], spent: 84.32),
            Budget(name: "Fun money", period: .monthly, amount: 150, categoryIDs: [entertainment.id, dining.id], spent: 22.49),
        ]

        return SeedData(wallets: wallets, categories: categories, transactions: transactions, goals: goals, budgets: budgets)
    }
}
