import SwiftUI

struct CategoriesManagerView: View {
    @EnvironmentObject private var store: AppStore

    @State private var expanded: Set<UUID> = []
    @State private var showAddCategory = false
    @State private var addSubcategoryFor: UUID?
    @State private var editCategory: Category?
    @State private var editSubcategory: (categoryID: UUID, sub: Subcategory)?
    @State private var deleteCategoryTarget: Category?
    @State private var deleteSubcategoryTarget: (categoryID: UUID, sub: Subcategory)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SproutSpacing.s4) {
                section(title: "Expense", kind: .expense)
                section(title: "Income", kind: .income)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.sproutBg)
        .navigationTitle("Categories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SproutIconButton(systemImage: "plus") { showAddCategory = true }
            }
        }
        .sheet(isPresented: $showAddCategory) { AddCategorySheet() }
        .sheet(item: Binding(
            get: { addSubcategoryFor.map(IdentifiableUUID.init) },
            set: { addSubcategoryFor = $0?.id }
        )) { wrapped in
            AddSubcategorySheet(categoryID: wrapped.id)
        }
        .sheet(item: $editCategory) { category in
            EditCategorySheet(category: category)
        }
        .sheet(item: Binding(
            get: { editSubcategory.map { EditSubTarget(categoryID: $0.categoryID, sub: $0.sub) } },
            set: { editSubcategory = $0.map { ($0.categoryID, $0.sub) } }
        )) { target in
            EditSubcategorySheet(categoryID: target.categoryID, subcategory: target.sub)
        }
        .alert("Delete category?", isPresented: Binding(
            get: { deleteCategoryTarget != nil },
            set: { if !$0 { deleteCategoryTarget = nil } }
        )) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let target = deleteCategoryTarget { store.deleteCategory(target.id) }
            }
        } message: {
            Text("Existing transactions in \"\(deleteCategoryTarget?.name ?? "")\" will show as Uncategorized. This can't be undone.")
        }
        .alert("Delete subcategory?", isPresented: Binding(
            get: { deleteSubcategoryTarget != nil },
            set: { if !$0 { deleteSubcategoryTarget = nil } }
        )) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let target = deleteSubcategoryTarget {
                    store.deleteSubcategory(target.sub.id, from: target.categoryID)
                }
            }
        } message: {
            Text("This can't be undone.")
        }
    }

    private func section(title: String, kind: CategoryKind) -> some View {
        let items = store.categories.filter { $0.kind == kind }
        return VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.sproutHeading(17))
            if items.isEmpty {
                Text("No \(title.lowercased()) categories yet.")
                    .font(.sproutBody(13))
                    .foregroundStyle(Color.sproutNeutral600)
            } else {
                VStack(spacing: 8) {
                    ForEach(items) { category in
                        categoryRow(category)
                    }
                }
            }
        }
    }

    private func categoryRow(_ category: Category) -> some View {
        let isExpanded = expanded.contains(category.id)
        return VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    if isExpanded { expanded.remove(category.id) } else { expanded.insert(category.id) }
                } label: {
                    HStack(spacing: 12) {
                        SproutIconChip(systemImage: category.icon, size: 32, iconSize: 16)
                        Text(category.name).font(.sproutBody(13.5, weight: .semibold)).foregroundStyle(Color.sproutText)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.sproutNeutral600)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                }
                .buttonStyle(.plain)

                Button { editCategory = category } label: {
                    Image(systemName: "pencil").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.sproutAccent)
                }
                Button { deleteCategoryTarget = category } label: {
                    Image(systemName: "trash").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.sproutStatusDanger)
                }
            }
            .padding(14)

            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(category.subcategories) { sub in
                        HStack(spacing: 10) {
                            SproutIconChip(systemImage: sub.icon, size: 26, iconSize: 13)
                            Text(sub.name).font(.sproutBody(12.5))
                            Spacer()
                            Button { editSubcategory = (category.id, sub) } label: {
                                Image(systemName: "pencil").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.sproutAccent)
                            }
                            Button { deleteSubcategoryTarget = (category.id, sub) } label: {
                                Image(systemName: "trash").font(.system(size: 12, weight: .semibold)).foregroundStyle(Color.sproutStatusDanger)
                            }
                        }
                        .padding(10)
                        .background(Color.sproutBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    Button("+ Subcategory") { addSubcategoryFor = category.id }
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

private struct EditSubTarget: Identifiable {
    let categoryID: UUID
    let sub: Subcategory
    var id: UUID { sub.id }
}

#Preview {
    NavigationStack { CategoriesManagerView() }.environmentObject(AppStore())
}
