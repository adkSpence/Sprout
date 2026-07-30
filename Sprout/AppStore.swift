import SwiftUI
import Combine

/// Central store for Sprout. Owns all data and the derived values each
/// screen reads (month totals, per-wallet spend, category breakdowns).
/// Starts empty on first launch and persists every change to a local JSON
/// file (see `Persistence`), so data survives relaunches and rebuilds.
final class AppStore: ObservableObject {
    @Published var wallets: [Wallet] { didSet { persist() } }
    @Published var categories: [Category] { didSet { persist() } }
    @Published var transactions: [Transaction] { didSet { persist() } }
    @Published var goals: [Goal] { didSet { persist() } }
    @Published var budgets: [Budget] { didSet { persist() } }
    @Published var selectedMonth: Date
    @Published var budgetPeriodFilter: BudgetPeriod = .monthly

    private let calendar: Calendar = .current

    init() {
        let snapshot = Persistence.load() ?? AppSnapshot()
        wallets = snapshot.wallets
        categories = snapshot.categories
        transactions = snapshot.transactions
        goals = snapshot.goals
        budgets = snapshot.budgets
        selectedMonth = Calendar.current.dateInterval(of: .month, for: .now)?.start ?? .now
    }

    private func persist() {
        Persistence.save(AppSnapshot(
            wallets: wallets, categories: categories, transactions: transactions,
            goals: goals, budgets: budgets
        ))
    }

    // MARK: - Month navigation

    var monthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    func prevMonth() {
        if let d = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = d
        }
    }

    func nextMonth() {
        if let d = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = d
        }
    }

    private func isInSelectedMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
    }

    // MARK: - Totals

    /// Wallet balances grouped by currency, the currency actually holding the
    /// most money first (falling back to wallet count to break ties between
    /// two currencies with equal — including zero — balances).
    var totalsByCurrency: [(currency: Currency, total: Double)] {
        let grouped = Dictionary(grouping: wallets, by: \.currency)
        let sums = grouped.map { (currency: $0.key, total: $0.value.reduce(0) { $0 + $1.balance }) }
        return sums.sorted { lhs, rhs in
            if abs(lhs.total) != abs(rhs.total) { return abs(lhs.total) > abs(rhs.total) }
            return (grouped[lhs.currency]?.count ?? 0) > (grouped[rhs.currency]?.count ?? 0)
        }
    }

    var totalsPrimaryLabel: String {
        guard let primary = totalsByCurrency.first else { return Currency.usd.format(0) }
        return primary.currency.format(primary.total)
    }

    var totalsExtraLabels: [String] {
        totalsByCurrency.dropFirst().map { $0.currency.format($0.total) }
    }

    var primaryCurrency: Currency {
        totalsByCurrency.first?.currency ?? .usd
    }

    private func monthTransactions() -> [Transaction] {
        transactions.filter { isInSelectedMonth($0.date) }
    }

    var monthIncome: Double {
        monthTransactions().filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
    }

    var monthExpense: Double {
        monthTransactions().filter { $0.kind == .expense }.reduce(0) { $0 + $1.amount }
    }

    var monthIncomeLabel: String { primaryCurrency.format(monthIncome) }
    var monthExpenseLabel: String { primaryCurrency.format(monthExpense) }

    // MARK: - Recent activity

    var recentTransactions: [Transaction] {
        monthTransactions().sorted { $0.date > $1.date }
    }

    func wallet(_ id: UUID) -> Wallet? { wallets.first { $0.id == id } }
    func category(_ id: UUID) -> Category? { categories.first { $0.id == id } }
    func subcategory(_ categoryID: UUID, _ subID: UUID?) -> Subcategory? {
        guard let subID else { return nil }
        return category(categoryID)?.subcategories.first { $0.id == subID }
    }

    // MARK: - Per-wallet / per-category spend

    func spend(categoryID: UUID, subcategoryID: UUID? = nil, walletID: UUID? = nil) -> Double {
        monthTransactions().filter { tx in
            tx.kind == .expense
                && tx.categoryID == categoryID
                && (subcategoryID == nil || tx.subcategoryID == subcategoryID)
                && (walletID == nil || tx.walletID == walletID)
        }.reduce(0) { $0 + $1.amount }
    }

    func totalExpense(walletID: UUID) -> Double {
        monthTransactions().filter { $0.kind == .expense && $0.walletID == walletID }.reduce(0) { $0 + $1.amount }
    }

    /// Category → percentage-of-expense breakdown for the Stats screen.
    var statsCategoryBreakdown: [(category: Category, amount: Double, pct: Double)] {
        let expense = monthExpense
        guard expense > 0 else { return [] }
        return categories
            .filter { $0.kind == .expense }
            .compactMap { cat -> (Category, Double, Double)? in
                let amount = spend(categoryID: cat.id)
                guard amount > 0 else { return nil }
                return (cat, amount, amount / expense)
            }
            .sorted { $0.1 > $1.1 }
    }

    // MARK: - Mutations

    func addWallet(_ wallet: Wallet) { wallets.append(wallet) }
    func addCategory(_ category: Category) { categories.append(category) }
    func addSubcategory(_ sub: Subcategory, to categoryID: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[idx].subcategories.append(sub)
    }

    func updateCategory(_ category: Category) {
        guard let idx = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[idx] = category
    }

    /// Deletes the category and scrubs it out of any budget that referenced
    /// it. Transactions keep their (now-dangling) categoryID and fall back to
    /// showing "Uncategorized" rather than being deleted along with it.
    func deleteCategory(_ id: UUID) {
        categories.removeAll { $0.id == id }
        for i in budgets.indices {
            budgets[i].categoryIDs.removeAll { $0 == id }
        }
    }

    func updateSubcategory(_ sub: Subcategory, in categoryID: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == categoryID }),
              let subIdx = categories[idx].subcategories.firstIndex(where: { $0.id == sub.id }) else { return }
        categories[idx].subcategories[subIdx] = sub
    }

    func deleteSubcategory(_ subID: UUID, from categoryID: UUID) {
        guard let idx = categories.firstIndex(where: { $0.id == categoryID }) else { return }
        categories[idx].subcategories.removeAll { $0.id == subID }
    }
    func addTransaction(_ tx: Transaction) {
        transactions.append(tx)
        guard let idx = wallets.firstIndex(where: { $0.id == tx.walletID }) else { return }
        wallets[idx].balance += tx.kind == .income ? tx.amount : -tx.amount
    }
    func addGoal(_ goal: Goal) { goals.append(goal) }
    func addFunds(_ amount: Double, to goalID: UUID) {
        guard let idx = goals.firstIndex(where: { $0.id == goalID }) else { return }
        goals[idx].current += amount
    }
    func addBudget(_ budget: Budget) { budgets.append(budget) }

    func budgets(for period: BudgetPeriod) -> [Budget] {
        budgets.filter { $0.period == period }
    }

    // MARK: - Backup restore

    /// Replaces all data with a previously exported snapshot (see
    /// `BackupManager`). Each assignment re-triggers `persist()` via
    /// `didSet`, so the local store stays in sync too.
    func restore(from snapshot: AppSnapshot) {
        wallets = snapshot.wallets
        categories = snapshot.categories
        transactions = snapshot.transactions
        goals = snapshot.goals
        budgets = snapshot.budgets
    }
}
