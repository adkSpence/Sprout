import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject private var store: AppStore

    private let palette: [Color] = [
        .sproutAccent500, .sproutAccent2_500, .sproutAccent700, .sproutAccent2_700,
        .sproutAccent300, .sproutAccent2_300, .sproutNeutral600, .sproutAccent900,
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SproutSpacing.s4) {
                Text("Statistics").font(.sproutHeading(26))

                monthSelector

                HStack(spacing: 10) {
                    statTile(title: "Income", value: store.monthIncomeLabel, bg: .sproutAccent2_100, fg: .sproutAccent2_800)
                    statTile(title: "Expenses", value: store.monthExpenseLabel, bg: .sproutAccent100, fg: .sproutAccent800)
                }

                let breakdown = store.statsCategoryBreakdown
                if breakdown.isEmpty {
                    Text("No spending recorded this month yet.")
                        .font(.sproutBody(13))
                        .foregroundStyle(Color.sproutNeutral600)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    donutChart(breakdown)
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)

                    VStack(spacing: 12) {
                        ForEach(Array(breakdown.enumerated()), id: \.element.category.id) { index, row in
                            categoryRow(row, color: palette[index % palette.count])
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.sproutBg)
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

    private func statTile(title: String, value: String, bg: Color, fg: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.sproutBody(11)).foregroundStyle(fg)
            Text(value).font(.sproutHeading(17)).foregroundStyle(fg)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: SproutRadius.md, style: .continuous))
    }

    private func donutChart(_ breakdown: [(category: Category, amount: Double, pct: Double)]) -> some View {
        ZStack {
            Chart(Array(breakdown.enumerated()), id: \.element.category.id) { index, row in
                SectorMark(
                    angle: .value("Amount", row.amount),
                    innerRadius: .ratio(0.64),
                    angularInset: 1.5
                )
                .cornerRadius(3)
                .foregroundStyle(palette[index % palette.count])
            }
            VStack(spacing: 2) {
                Text("Spent").font(.sproutBody(10)).foregroundStyle(Color.sproutNeutral700)
                Text(store.monthExpenseLabel).font(.sproutHeading(14))
            }
        }
    }

    private func categoryRow(_ row: (category: Category, amount: Double, pct: Double), color: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 10, height: 10)
                Text(row.category.name).font(.sproutBody(13, weight: .semibold))
                Spacer()
                Text(store.primaryCurrency.format(row.amount)).font(.sproutBody(13)).foregroundStyle(Color.sproutNeutral700)
            }
            SproutProgressBar(progress: row.pct, fillColor: color, height: 6)
                .padding(.leading, 20)
        }
    }
}

#Preview {
    NavigationStack { StatsView() }.environmentObject(AppStore())
}
