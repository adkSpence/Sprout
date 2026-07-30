import SwiftUI

struct EditWalletSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    let wallet: Wallet
    @State private var name: String
    @State private var type: WalletType
    @State private var currency: Currency
    @State private var balanceText: String
    @State private var showDeleteConfirm = false

    init(wallet: Wallet) {
        self.wallet = wallet
        _name = State(initialValue: wallet.name)
        _type = State(initialValue: wallet.type)
        _currency = State(initialValue: wallet.currency)
        _balanceText = State(initialValue: String(format: "%.2f", wallet.balance))
    }

    var body: some View {
        ModalSheet(title: "Edit wallet") {
            SproutTextField(label: "Name", text: $name, placeholder: "e.g. Main card")

            VStack(alignment: .leading, spacing: 6) {
                Text("Account type").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                FlowChips {
                    ForEach(WalletType.allCases) { t in
                        SproutChoiceChip(label: t.rawValue, icon: t.icon, selected: type == t) { type = t }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Currency").font(.sproutBody(12)).foregroundStyle(Color.sproutText.opacity(0.7))
                HStack(spacing: 8) {
                    ForEach(Currency.allCases) { c in
                        SproutChoiceChip(label: "\(c.rawValue) (\(c.symbol))", selected: currency == c) { currency = c }
                    }
                }
            }

            SproutTextField(label: "Balance", text: $balanceText, placeholder: "0.00", keyboardType: .decimalPad)

            SproutButton(title: "Save changes") {
                var updated = wallet
                updated.name = name.isEmpty ? wallet.name : name
                updated.type = type
                updated.currency = currency
                updated.balance = Double(balanceText) ?? wallet.balance
                store.updateWallet(updated)
                dismiss()
            }

            SproutButton(title: "Delete wallet", style: .destructive) {
                showDeleteConfirm = true
            }
        }
        .alert("Delete this wallet?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                store.deleteWallet(wallet.id)
                dismiss()
            }
        } message: {
            Text("This also deletes every transaction recorded against \"\(wallet.name)\". This can't be undone.")
        }
    }
}

#Preview {
    EditWalletSheet(wallet: Wallet(name: "Main card", type: .card, currency: .usd, balance: 100))
        .environmentObject(AppStore())
}
