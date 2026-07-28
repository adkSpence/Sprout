import SwiftUI

/// Font pairing for Sprout: Poppins for display/heading text (replacing the
/// prototype's Caprasimo), Inter for body text (replacing Figtree). Both are
/// bundled TTFs registered at launch in `SproutApp.init`.
extension Font {
    static func sproutHeading(_ size: CGFloat, weight: SproutHeadingWeight = .semibold) -> Font {
        .custom(weight.fontName, size: size)
    }

    static func sproutBody(_ size: CGFloat, weight: SproutBodyWeight = .regular) -> Font {
        .custom(weight.fontName, size: size)
    }

    // Fixed type scale, mirroring the prototype's h1-h6 sizes.
    static let sproutH1 = Font.sproutHeading(42, weight: .bold)
    static let sproutH2 = Font.sproutHeading(32, weight: .bold)
    static let sproutH3 = Font.sproutHeading(25, weight: .semibold)
    static let sproutH4 = Font.sproutHeading(20, weight: .semibold)
    static let sproutH5 = Font.sproutHeading(16, weight: .semibold)
    static let sproutH6 = Font.sproutHeading(13, weight: .medium)
}

enum SproutHeadingWeight {
    case medium, semibold, bold

    var fontName: String {
        switch self {
        case .medium: return "Poppins-Medium"
        case .semibold: return "Poppins-SemiBold"
        case .bold: return "Poppins-Bold"
        }
    }
}

enum SproutBodyWeight {
    case regular, medium, semibold, bold

    var fontName: String {
        switch self {
        case .regular: return "Inter-Regular"
        case .medium: return "Inter-Medium"
        case .semibold: return "Inter-SemiBold"
        case .bold: return "Inter-Bold"
        }
    }
}
