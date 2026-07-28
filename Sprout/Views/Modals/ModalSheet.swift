import SwiftUI

/// Shared chrome for every add/edit sheet: a title bar with a close button
/// over scrollable content, mirroring the prototype's bottom-sheet modal.
struct ModalSheet<Content: View>: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder var content: Content

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SproutSpacing.s3) {
                    content
                }
                .padding(20)
            }
            .background(Color.sproutBg)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.sproutText)
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(Color.sproutDivider, lineWidth: 1))
                    }
                }
            }
            .toolbarBackground(Color.sproutBg, for: .navigationBar)
        }
        .presentationDetents([.large])
    }
}

/// A row of selectable chips — used for account type, currency, icon and
/// period pickers across the modals.
struct SproutChoiceChip: View {
    let label: String
    var icon: String? = nil
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 12, weight: .semibold))
                }
                Text(label).font(.sproutBody(13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(selected ? Color.sproutBg : Color.sproutText)
            .background(selected ? Color.sproutAccent : Color.sproutSurface)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// The large centered amount entry used by the transaction and budget sheets.
struct SproutAmountHero: View {
    let currencySymbol: String
    @Binding var amount: String
    var background: Color = .sproutAccent100
    var foreground: Color = .sproutAccent900

    var body: some View {
        HStack {
            Text(currencySymbol)
                .font(.sproutBody(12, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(background.opacity(0.6))
                .clipShape(Capsule())
                .foregroundStyle(foreground)
            Spacer()
            TextField("0", text: $amount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.sproutHeading(36))
                .foregroundStyle(foreground)
        }
        .padding(18)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: SproutRadius.lg, style: .continuous))
    }
}
