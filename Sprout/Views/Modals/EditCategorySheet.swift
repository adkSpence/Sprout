import SwiftUI

struct EditCategorySheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let category: Category
    @State private var name: String
    @State private var kind: CategoryKind
    @State private var icon: String

    init(category: Category) {
        self.category = category
        _name = State(initialValue: category.name)
        _kind = State(initialValue: category.kind)
        _icon = State(initialValue: category.icon)
    }

    var body: some View {
        ModalSheet(title: "Edit category") {
            SproutTextField(label: "Name", text: $name, placeholder: "e.g. Pets")

            VStack(alignment: .leading, spacing: 6) {
                Text("Type").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                HStack(spacing: 8) {
                    SproutChoiceChip(label: "Expense", selected: kind == .expense) { kind = .expense }
                    SproutChoiceChip(label: "Income", selected: kind == .income) { kind = .income }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Icon").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                IconPickerGrid(selection: $icon)
            }

            SproutButton(title: "Save changes") {
                var updated = category
                updated.name = name.isEmpty ? category.name : name
                updated.kind = kind
                updated.icon = icon
                store.updateCategory(updated)
                dismiss()
            }
        }
    }
}

#Preview {
    EditCategorySheet(category: Category(name: "Groceries", icon: "cart"))
        .environmentObject(AppStore())
}
