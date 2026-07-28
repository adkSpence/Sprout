import SwiftUI

struct AddFundsSheet: View {
    let goalID: UUID
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var amountText = ""

    var body: some View {
        ModalSheet(title: "Add funds") {
            SproutTextField(label: "Amount to add", text: $amountText, placeholder: "0.00", keyboardType: .decimalPad)

            SproutButton(title: "Add funds") {
                let amount = Double(amountText) ?? 0
                store.addFunds(amount, to: goalID)
                dismiss()
            }
        }
    }
}

#Preview {
    AddFundsSheet(goalID: UUID()).environmentObject(AppStore())
}
