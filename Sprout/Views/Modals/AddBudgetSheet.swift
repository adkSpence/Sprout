import SwiftUI

struct AddBudgetSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var amountText = ""
    @State private var name = ""
    @State private var period: BudgetPeriod = .monthly
    @State private var selectedCategoryIDs: Set<UUID> = []

    var body: some View {
        ModalSheet(title: "Add budget") {
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

            SproutButton(title: "Save") {
                let amount = Double(amountText) ?? 0
                store.addBudget(Budget(
                    name: name.isEmpty ? "New budget" : name, period: period, amount: amount,
                    categoryIDs: Array(selectedCategoryIDs), spent: 0
                ))
                dismiss()
            }
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
    AddBudgetSheet().environmentObject(AppStore())
}
