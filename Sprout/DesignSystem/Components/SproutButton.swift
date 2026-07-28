import SwiftUI

/// Mirrors the prototype's `.btn` variants: primary (solid accent fill),
/// secondary (outlined), and ghost (text-only accent).
enum SproutButtonStyle {
    case primary, secondary, ghost
}

struct SproutButton: View {
    let title: String
    var style: SproutButtonStyle = .primary
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(title)
                    .font(.sproutHeading(14))
            }
            .padding(.vertical, SproutSpacing.s2)
            .padding(.horizontal, SproutSpacing.s3 * 1.2)
            .frame(maxWidth: style == .primary ? .infinity : nil)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                if style == .secondary {
                    Capsule().stroke(Color.sproutDivider, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch style {
        case .primary: return .sproutBg
        case .secondary: return .sproutText
        case .ghost: return .sproutAccent
        }
    }

    private var background: Color {
        switch style {
        case .primary: return .sproutAccent
        case .secondary: return .clear
        case .ghost: return .clear
        }
    }
}

/// A circular icon-only button — mirrors `.btn.btn-icon.btn-secondary`.
struct SproutIconButton: View {
    let systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.sproutText)
                .frame(width: 36, height: 36)
                .overlay(Circle().stroke(Color.sproutDivider, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
