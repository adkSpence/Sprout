import SwiftUI

struct PlanningView: View {
    @EnvironmentObject private var store: AppStore
    @State private var tab = 0 // 0 = goals, 1 = budgets
    @State private var showAddGoal = false
    @State private var showAddBudget = false
    @State private var addFundsGoalID: UUID?
    @State private var editGoalTarget: Goal?
    @State private var deleteGoalTarget: Goal?
    @State private var editBudgetTarget: Budget?
    @State private var deleteBudgetTarget: Budget?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SproutSpacing.s4) {
                HStack {
                    Text("Planning").font(.sproutHeading(26))
                    Spacer()
                    SproutIconButton(systemImage: "plus") {
                        if tab == 0 { showAddGoal = true } else { showAddBudget = true }
                    }
                }

                SproutSegmentedControl(options: ["Planned payments", "Budgets"], selection: $tab)

                if tab == 0 {
                    goalsSection
                } else {
                    budgetsSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.sproutBg)
        .sheet(isPresented: $showAddGoal) { AddGoalSheet() }
        .sheet(isPresented: $showAddBudget) { AddBudgetSheet() }
        .sheet(item: Binding(
            get: { addFundsGoalID.map(IdentifiableUUID.init) },
            set: { addFundsGoalID = $0?.id }
        )) { wrapped in
            AddFundsSheet(goalID: wrapped.id)
        }
        .sheet(item: $editGoalTarget) { goal in EditGoalSheet(goal: goal) }
        .sheet(item: $editBudgetTarget) { budget in EditBudgetSheet(budget: budget) }
        .alert("Delete this goal?", isPresented: Binding(
            get: { deleteGoalTarget != nil },
            set: { if !$0 { deleteGoalTarget = nil } }
        )) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let target = deleteGoalTarget { store.deleteGoal(target.id) }
            }
        } message: { Text("This can't be undone.") }
        .alert("Delete this budget?", isPresented: Binding(
            get: { deleteBudgetTarget != nil },
            set: { if !$0 { deleteBudgetTarget = nil } }
        )) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let target = deleteBudgetTarget { store.deleteBudget(target.id) }
            }
        } message: { Text("This can't be undone.") }
    }

    private var goalsSection: some View {
        Group {
            if store.goals.isEmpty {
                emptyState(text: "No goals yet — plan for something you're saving toward.")
            } else {
                VStack(spacing: 10) {
                    ForEach(store.goals) { goal in
                        goalCard(goal)
                    }
                }
            }
        }
    }

    private func goalCard(_ goal: Goal) -> some View {
        SproutCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    SproutIconChip(systemImage: goal.icon, tint: .sproutAccent2_800, background: .sproutAccent2_100, size: 34, iconSize: 17)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.name).font(.sproutBody(14, weight: .semibold))
                        Text("By \(goal.deadline, format: .dateTime.month(.abbreviated).year())")
                            .font(.sproutBody(11.5))
                            .foregroundStyle(Color.sproutNeutral700)
                    }
                    Spacer()
                    Button("+ Add") { addFundsGoalID = goal.id }
                        .font(.sproutBody(11.5, weight: .semibold))
                        .foregroundStyle(Color.sproutAccent)
                }
                SproutProgressBar(progress: goal.progress, fillColor: .sproutAccent2_500)
                HStack {
                    Text(store.primaryCurrency.format(goal.current)).font(.sproutBody(12)).foregroundStyle(Color.sproutNeutral700)
                    Spacer()
                    Text(store.primaryCurrency.format(goal.target)).font(.sproutBody(12)).foregroundStyle(Color.sproutNeutral700)
                }
            }
        }
        .contextMenu {
            Button { editGoalTarget = goal } label: { Label("Edit goal", systemImage: "pencil") }
            Button(role: .destructive) { deleteGoalTarget = goal } label: { Label("Delete goal", systemImage: "trash") }
        }
    }

    private var budgetsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(BudgetPeriod.allCases) { period in
                        SproutChoiceChip(label: period.rawValue, selected: store.budgetPeriodFilter == period) {
                            store.budgetPeriodFilter = period
                        }
                    }
                }
            }

            let budgets = store.budgets(for: store.budgetPeriodFilter)
            if budgets.isEmpty {
                VStack(spacing: 18) {
                    Image("BudgetEmpty")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    Text("No \(store.budgetPeriodFilter.rawValue.lowercased()) budgets yet").font(.sproutHeading(17))
                    Text("Create one to keep this period's spending on track.")
                        .font(.sproutBody(13))
                        .foregroundStyle(Color.sproutNeutral600)
                        .multilineTextAlignment(.center)
                    SproutButton(title: "Create budget") { showAddBudget = true }
                        .frame(maxWidth: 220)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
            } else {
                VStack(spacing: 10) {
                    ForEach(budgets) { budget in
                        budgetCard(budget)
                    }
                }
            }
        }
    }

    private func budgetCard(_ budget: Budget) -> some View {
        SproutCard {
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(store.primaryCurrency.format(budget.remaining))
                            .font(.sproutHeading(17))
                        + Text("  of \(store.primaryCurrency.format(budget.amount))")
                            .font(.sproutBody(11.5))
                            .foregroundColor(Color.sproutNeutral600)
                    }
                    Spacer()
                    Text(budget.name).font(.sproutBody(13.5, weight: .semibold))
                }
                Text("\(store.primaryCurrency.format(budget.spent)) spent")
                    .font(.sproutBody(12))
                    .foregroundStyle(Color.sproutNeutral700)
                SproutProgressBar(
                    progress: budget.progress,
                    fillColor: budget.progress > 0.9 ? .sproutStatusDanger : .sproutAccent500
                )
            }
        }
        .contextMenu {
            Button { editBudgetTarget = budget } label: { Label("Edit budget", systemImage: "pencil") }
            Button(role: .destructive) { deleteBudgetTarget = budget } label: { Label("Delete budget", systemImage: "trash") }
        }
    }

    private func emptyState(text: String) -> some View {
        Text(text)
            .font(.sproutBody(13))
            .foregroundStyle(Color.sproutNeutral600)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.vertical, 40)
    }
}

#Preview {
    NavigationStack { PlanningView() }.environmentObject(AppStore())
}
