import SwiftUI

struct EditBudgetSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let budget: Budget
    @State private var amountText: String
    @State private var name: String
    @State private var period: BudgetPeriod
    @State private var selectedCategoryIDs: Set<UUID>
    @State private var showDeleteConfirm = false

    init(budget: Budget) {
        self.budget = budget
        _amountText = State(initialValue: String(format: "%.2f", budget.amount))
        _name = State(initialValue: budget.name)
        _period = State(initialValue: budget.period)
        _selectedCategoryIDs = State(initialValue: Set(budget.categoryIDs))
    }

    var body: some View {
        ModalSheet(title: "Edit budget") {
            SproutAmountHero(currencySymbol: store.primaryCurrency.symbol, amount: $amountText)

            SproutTextField(label: "Budget name", text: $name, placeholder: "e.g. Groceries")

            VStack(alignment: .leading, spacing: 8) {
                Text("Period").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                FlowChips {
                    ForEach(BudgetPeriod.allCases) { p in
                        SproutChoiceChip(label: p.rawValue, selected: period == p) { period = p }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Categories").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                VStack(spacing: 6) {
                    ForEach(store.categories.filter { $0.kind == .expense }) { c in
                        categoryRow(c)
                    }
                }
            }

            SproutButton(title: "Save changes") {
                var updated = budget
                updated.amount = Double(amountText) ?? budget.amount
                updated.name = name.isEmpty ? budget.name : name
                updated.period = period
                updated.categoryIDs = Array(selectedCategoryIDs)
                store.updateBudget(updated)
                dismiss()
            }

            SproutButton(title: "Delete budget", style: .destructive) {
                showDeleteConfirm = true
            }
        }
        .alert("Delete this budget?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                store.deleteBudget(budget.id)
                dismiss()
            }
        } message: {
            Text("This can't be undone.")
        }
    }

    private func categoryRow(_ category: Category) -> some View {
        let selected = selectedCategoryIDs.contains(category.id)
        return Button {
            if selected { selectedCategoryIDs.remove(category.id) } else { selectedCategoryIDs.insert(category.id) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selected ? Color.sproutAccent : Color.sproutNeutral500)
                SproutIconChip(systemImage: category.icon, size: 28, iconSize: 13)
                Text(category.name).font(.sproutBody(13.5, weight: .semibold))
                Spacer()
            }
            .padding(10)
            .background(Color.sproutBg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EditBudgetSheet(budget: Budget(name: "Groceries", period: .monthly, amount: 400, categoryIDs: [], spent: 84))
        .environmentObject(AppStore())
}
