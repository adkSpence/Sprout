import SwiftUI

struct AddGoalSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var targetText = ""
    @State private var deadline = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var icon = IconPalette.choices[0]

    var body: some View {
        ModalSheet(title: "Add goal") {
            SproutTextField(label: "Name", text: $name, placeholder: "e.g. New laptop")
            SproutTextField(label: "Target amount", text: $targetText, placeholder: "0.00", keyboardType: .decimalPad)

            VStack(alignment: .leading, spacing: 6) {
                Text("Deadline").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                DatePicker("", selection: $deadline, displayedComponents: .date)
                    .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Icon").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                IconPickerGrid(selection: $icon)
            }

            SproutButton(title: "Save goal") {
                let target = Double(targetText) ?? 0
                store.addGoal(Goal(name: name.isEmpty ? "New goal" : name, icon: icon, target: target, current: 0, deadline: deadline))
                dismiss()
            }
        }
    }
}

#Preview {
    AddGoalSheet().environmentObject(AppStore())
}
