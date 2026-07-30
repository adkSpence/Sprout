import SwiftUI

struct EditSubcategorySheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let categoryID: UUID
    let subcategory: Subcategory
    @State private var name: String
    @State private var icon: String

    init(categoryID: UUID, subcategory: Subcategory) {
        self.categoryID = categoryID
        self.subcategory = subcategory
        _name = State(initialValue: subcategory.name)
        _icon = State(initialValue: subcategory.icon)
    }

    var body: some View {
        ModalSheet(title: "Edit subcategory") {
            SproutTextField(label: "Name", text: $name, placeholder: "e.g. Coffee")

            VStack(alignment: .leading, spacing: 6) {
                Text("Icon").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                IconPickerGrid(selection: $icon)
            }

            SproutButton(title: "Save changes") {
                var updated = subcategory
                updated.name = name.isEmpty ? subcategory.name : name
                updated.icon = icon
                store.updateSubcategory(updated, in: categoryID)
                dismiss()
            }
        }
    }
}

#Preview {
    EditSubcategorySheet(categoryID: UUID(), subcategory: Subcategory(name: "Coffee", icon: "cup.and.saucer"))
        .environmentObject(AppStore())
}
