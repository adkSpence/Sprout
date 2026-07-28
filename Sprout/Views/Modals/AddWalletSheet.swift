import SwiftUI

struct AddWalletSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: WalletType = .card
    @State private var currency: Currency = .usd
    @State private var balanceText = ""

    var body: some View {
        ModalSheet(title: "Add wallet") {
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

            SproutTextField(label: "Starting balance", text: $balanceText, placeholder: "0.00", keyboardType: .decimalPad)

            SproutButton(title: "Save wallet") {
                let balance = Double(balanceText) ?? 0
                store.addWallet(Wallet(name: name.isEmpty ? "New wallet" : name, type: type, currency: currency, balance: balance))
                dismiss()
            }
        }
    }
}

/// A simple wrapping HStack for chip rows that may overflow one line.
struct FlowChips<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        // Horizontal scroll keeps this simple and avoids a custom layout;
        // chip counts here are small (4 wallet types, 10 icons, etc).
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) { content }
        }
    }
}

#Preview {
    AddWalletSheet().environmentObject(AppStore())
}
