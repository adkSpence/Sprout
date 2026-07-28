import SwiftUI

/// Mirrors the prototype's `.field` + `.input` — a labeled, pill-shaped
/// text field on the surface color.
struct SproutTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.sproutBody(12))
                .foregroundStyle(Color.sproutText.opacity(0.7))
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(.sproutBody(14))
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(Color.sproutSurface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.sproutDivider, lineWidth: 1))
        }
    }
}

/// Mirrors the prototype's `.seg` / `.seg-opt` segmented control.
struct SproutSegmentedControl: View {
    let options: [String]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { i in
                Button {
                    selection = i
                } label: {
                    Text(options[i])
                        .font(.sproutBody(13))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .foregroundStyle(selection == i ? Color.sproutBg : Color.sproutText)
                        .background(selection == i ? Color.sproutAccent : Color.clear)
                }
                .buttonStyle(.plain)
                if i < options.count - 1 {
                    Divider().frame(height: 20)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: SproutRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SproutRadius.md, style: .continuous)
                .stroke(Color.sproutDivider, lineWidth: 1)
        )
    }
}
