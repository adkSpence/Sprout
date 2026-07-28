import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showAddWallet = false
    @State private var showAddTransaction = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SproutSpacing.s4) {
                Text("Sprout")
                    .font(.sproutHeading(26))

                monthSelector

                balanceCard

                walletsSection

                recentActivitySection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.sproutBg)
        .sheet(isPresented: $showAddWallet) { AddWalletSheet() }
        .sheet(isPresented: $showAddTransaction) { AddTransactionSheet() }
    }

    private var monthSelector: some View {
        HStack {
            SproutIconButton(systemImage: "chevron.left") { store.prevMonth() }
            Spacer()
            Text(store.monthLabel).font(.sproutHeading(15))
            Spacer()
            SproutIconButton(systemImage: "chevron.right") { store.nextMonth() }
        }
    }

    private var balanceCard: some View {
        SproutCard {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total balance")
                    .font(.sproutBody(11, weight: .medium))
                    .textCase(.uppercase)
                    .foregroundStyle(Color.sproutNeutral700)
                Text(store.totalsPrimaryLabel)
                    .font(.sproutHeading(34))
                    .padding(.bottom, 6)

                if !store.totalsExtraLabels.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(store.totalsExtraLabels, id: \.self) { label in
                            SproutTag(text: label, style: .neutral)
                        }
                    }
                    .padding(.bottom, 6)
                }

                HStack(spacing: 10) {
                    statTile(title: "Income (mo.)", value: store.monthIncomeLabel, bg: .sproutAccent2_100, fg: .sproutAccent2_800)
                    statTile(title: "Expenses (mo.)", value: store.monthExpenseLabel, bg: .sproutAccent100, fg: .sproutAccent800)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func statTile(title: String, value: String, bg: Color, fg: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.sproutBody(11)).foregroundStyle(fg)
            Text(value).font(.sproutHeading(16)).foregroundStyle(fg)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: SproutRadius.md, style: .continuous))
    }

    private var walletsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Wallets").font(.sproutHeading(17))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.wallets) { wallet in
                        NavigationLink {
                            WalletDetailView(walletID: wallet.id)
                        } label: {
                            walletCard(wallet)
                        }
                        .buttonStyle(.plain)
                    }
                    addWalletCard
                }
            }
        }
    }

    private func walletCard(_ wallet: Wallet) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SproutIconChip(systemImage: wallet.type.icon, size: 34, iconSize: 17)
            Text(wallet.name).font(.sproutBody(13, weight: .semibold)).foregroundStyle(Color.sproutText)
            Text(wallet.balanceLabel).font(.sproutHeading(16)).foregroundStyle(Color.sproutText)
            SproutTag(text: wallet.type.rawValue, style: .neutral)
        }
        .padding(14)
        .frame(width: 148, alignment: .leading)
        .background(Color.sproutSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var addWalletCard: some View {
        Button {
            showAddWallet = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "plus").font(.system(size: 20, weight: .semibold))
                Text("Add wallet").font(.sproutBody(12))
            }
            .foregroundStyle(Color.sproutNeutral700)
            .frame(width: 148, height: 138)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .foregroundStyle(Color.sproutNeutral500)
            )
        }
        .buttonStyle(.plain)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent activity").font(.sproutHeading(17))
                Spacer()
                SproutIconButton(systemImage: "plus") { showAddTransaction = true }
            }

            if store.recentTransactions.isEmpty {
                Text("No transactions this month yet.")
                    .font(.sproutBody(13))
                    .foregroundStyle(Color.sproutNeutral600)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                VStack(spacing: 2) {
                    ForEach(store.recentTransactions.prefix(8)) { tx in
                        transactionRow(tx)
                        Divider().overlay(Color.sproutDivider)
                    }
                }
            }
        }
    }

    private func transactionRow(_ tx: Transaction) -> some View {
        let category = store.category(tx.categoryID)
        let sub = store.subcategory(tx.categoryID, tx.subcategoryID)
        return HStack(spacing: 12) {
            SproutIconChip(systemImage: category?.icon ?? "questionmark", size: 36, iconSize: 17)
            VStack(alignment: .leading, spacing: 1) {
                Text(category?.name ?? "Uncategorized").font(.sproutBody(13.5, weight: .semibold))
                Text(sub?.name ?? tx.note).font(.sproutBody(11.5)).foregroundStyle(Color.sproutNeutral700)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text((tx.kind == .income ? "+" : "-") + store.primaryCurrency.format(tx.amount))
                    .font(.sproutHeading(14))
                    .foregroundStyle(tx.kind == .income ? Color.sproutAccent2_700 : Color.sproutAccent700)
                Text(tx.date, format: .dateTime.month(.abbreviated).day())
                    .font(.sproutBody(11))
                    .foregroundStyle(Color.sproutNeutral600)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    NavigationStack { HomeView() }.environmentObject(AppStore())
}
