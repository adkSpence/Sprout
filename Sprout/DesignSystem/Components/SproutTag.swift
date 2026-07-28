import SwiftUI

/// Mirrors the prototype's `.tag` variants used for small labels.
enum SproutTagStyle {
    case accent, accent2, neutral, outline
}

struct SproutTag: View {
    let text: String
    var style: SproutTagStyle = .neutral

    var body: some View {
        Text(text)
            .font(.sproutBody(11, weight: .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(Capsule())
            .overlay {
                if style == .outline {
                    Capsule().stroke(Color.sproutAccent, lineWidth: 1)
                }
            }
    }

    private var foreground: Color {
        switch style {
        case .accent: return .sproutAccent800
        case .accent2: return .sproutAccent2_800
        case .neutral: return .sproutNeutral800
        case .outline: return .sproutAccent
        }
    }

    private var background: Color {
        switch style {
        case .accent: return .sproutAccent100
        case .accent2: return .sproutAccent2_100
        case .neutral: return .sproutNeutral100
        case .outline: return .clear
        }
    }
}
