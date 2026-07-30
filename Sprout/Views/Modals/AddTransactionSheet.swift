import SwiftUI

struct AddTransactionSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var preselectedWalletID: UUID? = nil
    var preselectedCategoryID: UUID? = nil
    var existingTransaction: Transaction? = nil

    @State private var kind: CategoryKind = .expense
    @State private var amountText = ""
    @State private var walletID: UUID?
    @State private var categoryID: UUID?
    @State private var subcategoryID: UUID?
    @State private var date = Date()
    @State private var note = ""
    @State private var showAddCategory = false
    @State private var showDeleteConfirm = false

    private var isEditing: Bool { existingTransaction != nil }

    private var canSave: Bool {
        walletID != nil && categoryID != nil && (Double(amountText) ?? 0) > 0
    }

    private var kindCategories: [Category] {
        store.categories.filter { $0.kind == kind }
    }

    private var selectedCategory: Category? {
        store.categories.first { $0.id == categoryID }
    }

    var body: some View {
        ModalSheet(title: isEditing ? "Edit transaction" : "Add transaction") {
            HStack(spacing: 0) {
                segTab("Expense", .expense)
                segTab("Income", .income)
            }
            .clipShape(RoundedRectangle(cornerRadius: SproutRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: SproutRadius.md, style: .continuous).stroke(Color.sproutDivider, lineWidth: 1))

            SproutAmountHero(currencySymbol: store.primaryCurrency.symbol, amount: $amountText)

            VStack(alignment: .leading, spacing: 8) {
                Text("Account").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                FlowChips {
                    ForEach(store.wallets) { w in
                        SproutChoiceChip(label: w.name, selected: walletID == w.id) { walletID = w.id }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Category").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                if kindCategories.isEmpty {
                    Text("No \(kind == .expense ? "expense" : "income") categories yet.")
                        .font(.sproutBody(12))
                        .foregroundStyle(Color.sproutNeutral600)
                }
                FlowChips {
                    ForEach(kindCategories) { c in
                        SproutChoiceChip(label: c.name, icon: c.icon, selected: categoryID == c.id) {
                            categoryID = c.id
                            subcategoryID = nil
                        }
                    }
                    SproutChoiceChip(label: "New category", icon: "plus", selected: false) {
                        showAddCategory = true
                    }
                }
                if let sub = selectedCategory, !sub.subcategories.isEmpty {
                    FlowChips {
                        ForEach(sub.subcategories) { s in
                            SproutChoiceChip(label: s.name, selected: subcategoryID == s.id) { subcategoryID = s.id }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Date & time").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                DatePicker("", selection: $date)
                    .labelsHidden()
            }

            SproutTextField(label: "Note", text: $note, placeholder: "Add a note")

            SproutButton(title: isEditing ? "Save changes" : "Save") {
                guard let walletID, let categoryID else { return }
                let amount = Double(amountText) ?? 0
                let tx = Transaction(
                    id: existingTransaction?.id ?? UUID(),
                    walletID: walletID, categoryID: categoryID, subcategoryID: subcategoryID,
                    kind: kind, amount: amount, date: date, note: note
                )
                if isEditing {
                    store.updateTransaction(tx)
                } else {
                    store.addTransaction(tx)
                }
                dismiss()
            }
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.45)

            if isEditing {
                SproutButton(title: "Delete transaction", style: .destructive) {
                    showDeleteConfirm = true
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategorySheet(presetKind: kind) { newCategory in
                categoryID = newCategory.id
                subcategoryID = nil
            }
        }
        .alert("Delete this transaction?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let id = existingTransaction?.id { store.deleteTransaction(id) }
                dismiss()
            }
        } message: { Text("This can't be undone.") }
        .onAppear {
            if let tx = existingTransaction {
                kind = tx.kind
                amountText = String(format: "%.2f", tx.amount)
                walletID = tx.walletID
                categoryID = tx.categoryID
                subcategoryID = tx.subcategoryID
                date = tx.date
                note = tx.note
            } else {
                walletID = preselectedWalletID ?? store.wallets.first?.id
                categoryID = preselectedCategoryID
            }
        }
    }

    private func segTab(_ label: String, _ value: CategoryKind) -> some View {
        Button {
            kind = value
            categoryID = nil
            subcategoryID = nil
        } label: {
            Text(label)
                .font(.sproutBody(13, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .foregroundStyle(kind == value ? Color.sproutBg : Color.sproutText)
                .background(kind == value ? Color.sproutAccent : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddTransactionSheet().environmentObject(AppStore())
}
