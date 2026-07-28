import SwiftUI

struct AddCategorySheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var kind: CategoryKind = .expense
    @State private var icon = IconPalette.choices[0]

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
                store.addCategory(Category(name: name.isEmpty ? "New category" : name, icon: icon, kind: kind))
                dismiss()
            }
        }
    }
}

#Preview {
    AddCategorySheet().environmentObject(AppStore())
}
