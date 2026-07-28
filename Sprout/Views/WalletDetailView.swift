import SwiftUI

struct WalletDetailView: View {
    let walletID: UUID
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var expanded: Set<UUID> = []
    @State private var showAddCategory = false
    @State private var addSubcategoryFor: UUID?
    @State private var addTransactionFor: UUID?

    private var wallet: Wallet? { store.wallet(walletID) }

    var body: some View {
        ScrollView {
            if let wallet {
                VStack(alignment: .leading, spacing: SproutSpacing.s4) {
                    walletHeader(wallet)

                    HStack {
                        Text("Categories").font(.sproutHeading(17))
                        Spacer()
                        SproutIconButton(systemImage: "plus") { showAddCategory = true }
                    }

                    VStack(spacing: 8) {
                        ForEach(store.categories) { category in
                            categoryRow(category, wallet: wallet)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color.sproutBg)
        .navigationTitle(wallet?.name ?? "Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCategory) { AddCategorySheet() }
        .sheet(item: Binding(
            get: { addSubcategoryFor.map(IdentifiableUUID.init) },
            set: { addSubcategoryFor = $0?.id }
        )) { wrapped in
            AddSubcategorySheet(categoryID: wrapped.id)
        }
        .sheet(item: Binding(
            get: { addTransactionFor.map(IdentifiableUUID.init) },
            set: { addTransactionFor = $0?.id }
        )) { wrapped in
            AddTransactionSheet(preselectedWalletID: walletID, preselectedCategoryID: wrapped.id)
        }
    }

    private func walletHeader(_ wallet: Wallet) -> some View {
        HStack(spacing: 14) {
            SproutIconChip(systemImage: wallet.type.icon, size: 44, iconSize: 21)
            VStack(alignment: .leading, spacing: 4) {
                Text(wallet.balanceLabel).font(.sproutHeading(22))
                SproutTag(text: "\(wallet.type.rawValue) · \(wallet.currency.rawValue)", style: .neutral)
            }
        }
        .padding(18)
        .background(Color.sproutSurface)
        .clipShape(RoundedRectangle(cornerRadius: SproutRadius.card, style: .continuous))
    }

    private func categoryRow(_ category: Category, wallet: Wallet) -> some View {
        let isExpanded = expanded.contains(category.id)
        let spend = store.spend(categoryID: category.id, walletID: wallet.id)
        return VStack(spacing: 0) {
            Button {
                if isExpanded { expanded.remove(category.id) } else { expanded.insert(category.id) }
            } label: {
                HStack(spacing: 12) {
                    SproutIconChip(systemImage: category.icon, size: 32, iconSize: 16)
                    Text(category.name).font(.sproutBody(13.5, weight: .semibold)).foregroundStyle(Color.sproutText)
                    Spacer()
                    Text(wallet.currency.format(spend)).font(.sproutBody(13)).foregroundStyle(Color.sproutNeutral700)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.sproutNeutral600)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(category.subcategories) { sub in
                        HStack(spacing: 10) {
                            SproutIconChip(systemImage: sub.icon, size: 26, iconSize: 13)
                            Text(sub.name).font(.sproutBody(12.5))
                            Spacer()
                            Text(wallet.currency.format(store.spend(categoryID: category.id, subcategoryID: sub.id, walletID: wallet.id)))
                                .font(.sproutBody(12))
                                .foregroundStyle(Color.sproutNeutral700)
                        }
                        .padding(10)
                        .background(Color.sproutBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    HStack(spacing: 8) {
                        Button("+ Subcategory") { addSubcategoryFor = category.id }
                        Button("+ Transaction") { addTransactionFor = category.id }
                    }
                    .font(.sproutBody(11.5, weight: .medium))
                    .foregroundStyle(Color.sproutAccent)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
            }
        }
        .background(Color.sproutSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    let store = AppStore()
    return NavigationStack {
        WalletDetailView(walletID: store.wallets.first!.id)
    }.environmentObject(store)
}
