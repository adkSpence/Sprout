import SwiftUI

struct AddCategorySheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    /// Called with the newly created category instead of a plain dismiss —
    /// lets a caller (e.g. the transaction sheet) auto-select it.
    var onSave: ((Category) -> Void)? = nil

    @State private var name = ""
    @State private var kind: CategoryKind
    @State private var icon = IconPalette.choices[0]

    init(presetKind: CategoryKind = .expense, onSave: ((Category) -> Void)? = nil) {
        self.onSave = onSave
        _kind = State(initialValue: presetKind)
    }

    var body: some View {
        ModalSheet(title: "Add category") {
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

            SproutButton(title: "Save category") {
                let category = Category(name: name.isEmpty ? "New category" : name, icon: icon, kind: kind)
                store.addCategory(category)
                onSave?(category)
                dismiss()
            }
        }
    }
}

#Preview {
    AddCategorySheet().environmentObject(AppStore())
}
