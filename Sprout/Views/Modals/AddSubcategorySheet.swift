import SwiftUI

struct AddSubcategorySheet: View {
    let categoryID: UUID
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var icon = IconPalette.choices[0]

    var body: some View {
        ModalSheet(title: "Add subcategory") {
            SproutTextField(label: "Name", text: $name, placeholder: "e.g. Coffee")

            VStack(alignment: .leading, spacing: 6) {
                Text("Icon").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                IconPickerGrid(selection: $icon)
            }

            SproutButton(title: "Save subcategory") {
                store.addSubcategory(Subcategory(name: name.isEmpty ? "New subcategory" : name, icon: icon), to: categoryID)
                dismiss()
            }
        }
    }
}

#Preview {
    AddSubcategorySheet(categoryID: UUID()).environmentObject(AppStore())
}
