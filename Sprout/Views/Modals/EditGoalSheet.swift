import SwiftUI

struct EditGoalSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let goal: Goal
    @State private var name: String
    @State private var targetText: String
    @State private var currentText: String
    @State private var deadline: Date
    @State private var icon: String
    @State private var showDeleteConfirm = false

    init(goal: Goal) {
        self.goal = goal
        _name = State(initialValue: goal.name)
        _targetText = State(initialValue: String(format: "%.2f", goal.target))
        _currentText = State(initialValue: String(format: "%.2f", goal.current))
        _deadline = State(initialValue: goal.deadline)
        _icon = State(initialValue: goal.icon)
    }

    var body: some View {
        ModalSheet(title: "Edit goal") {
            SproutTextField(label: "Name", text: $name, placeholder: "e.g. New laptop")
            SproutTextField(label: "Target amount", text: $targetText, placeholder: "0.00", keyboardType: .decimalPad)
            SproutTextField(label: "Saved so far", text: $currentText, placeholder: "0.00", keyboardType: .decimalPad)

            VStack(alignment: .leading, spacing: 6) {
                Text("Deadline").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                DatePicker("", selection: $deadline, displayedComponents: .date)
                    .labelsHidden()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Icon").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                IconPickerGrid(selection: $icon)
            }

            SproutButton(title: "Save changes") {
                var updated = goal
                updated.name = name.isEmpty ? goal.name : name
                updated.target = Double(targetText) ?? goal.target
                updated.current = Double(currentText) ?? goal.current
                updated.deadline = deadline
                updated.icon = icon
                store.updateGoal(updated)
                dismiss()
            }

            SproutButton(title: "Delete goal", style: .destructive) {
                showDeleteConfirm = true
            }
        }
        .alert("Delete this goal?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                store.deleteGoal(goal.id)
                dismiss()
            }
        } message: {
            Text("This can't be undone.")
        }
    }
}

#Preview {
    EditGoalSheet(goal: Goal(name: "New laptop", icon: "laptopcomputer", target: 1800, current: 200, deadline: .now))
        .environmentObject(AppStore())
}
