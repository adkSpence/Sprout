import SwiftUI

/// A wrapping grid of icon buttons, used by the category/subcategory/goal
/// sheets to pick a symbol.
struct IconPickerGrid: View {
    @Binding var selection: String
    var columns: Int = 6

    private var grid: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: columns)
    }

    var body: some View {
        LazyVGrid(columns: grid, spacing: 8) {
            ForEach(IconPalette.choices, id: \.self) { icon in
                Button {
                    selection = icon
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(selection == icon ? Color.sproutBg : Color.sproutText)
                        .frame(width: 36, height: 36)
                        .background(selection == icon ? Color.sproutAccent : Color.sproutSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
