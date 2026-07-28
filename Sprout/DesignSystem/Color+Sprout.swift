import SwiftUI

/// Design tokens ported from the Finance Tracker prototype's `styles.css`.
/// Colors are the warm "Organic" palette: a cream ground, terracotta accent,
/// sage second accent, each with a 100-900 tonal ramp.
extension Color {
    // Roles
    static let sproutBg = Color(hex: 0xF5EAD8)
    static let sproutSurface = Color(hex: 0xEBDDC5)
    static let sproutText = Color(hex: 0x201E1D)
    static let sproutAccent = Color(hex: 0xC67139)
    static let sproutAccent2 = Color(hex: 0x7A8A5E)
    static let sproutDivider = Color(hex: 0x201E1D).opacity(0.16)

    // Neutral ramp
    static let sproutNeutral100 = Color(hex: 0xF9F4ED)
    static let sproutNeutral200 = Color(hex: 0xEEE7DB)
    static let sproutNeutral300 = Color(hex: 0xDCD3C4)
    static let sproutNeutral400 = Color(hex: 0xC0B6A5)
    static let sproutNeutral500 = Color(hex: 0xA19786)
    static let sproutNeutral600 = Color(hex: 0x82796A)
    static let sproutNeutral700 = Color(hex: 0x645C50)
    static let sproutNeutral800 = Color(hex: 0x474238)
    static let sproutNeutral900 = Color(hex: 0x2E2B25)

    // Accent (terracotta) ramp
    static let sproutAccent100 = Color(hex: 0xFFF2EB)
    static let sproutAccent200 = Color(hex: 0xFFE1D0)
    static let sproutAccent300 = Color(hex: 0xFFC6A5)
    static let sproutAccent400 = Color(hex: 0xF6A06B)
    static let sproutAccent500 = Color(hex: 0xD67F48)
    static let sproutAccent600 = Color(hex: 0xB2622D)
    static let sproutAccent700 = Color(hex: 0x8C491A)
    static let sproutAccent800 = Color(hex: 0x643312)
    static let sproutAccent900 = Color(hex: 0x402310)

    // Accent-2 (sage) ramp
    static let sproutAccent2_100 = Color(hex: 0xF0FAE1)
    static let sproutAccent2_200 = Color(hex: 0xE1EECC)
    static let sproutAccent2_300 = Color(hex: 0xCCDBB2)
    static let sproutAccent2_400 = Color(hex: 0xAEBF92)
    static let sproutAccent2_500 = Color(hex: 0x8FA073)
    static let sproutAccent2_600 = Color(hex: 0x728157)
    static let sproutAccent2_700 = Color(hex: 0x56633F)
    static let sproutAccent2_800 = Color(hex: 0x3D472B)
    static let sproutAccent2_900 = Color(hex: 0x272E1B)

    // Status colors used for planning/stats callouts.
    static let sproutStatusOK = Color(hex: 0x7A9A5E)
    static let sproutStatusWarn = Color(hex: 0xC9923F)
    static let sproutStatusDanger = Color(hex: 0xA8523F)

    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Spacing scale — the prototype's 1.10x-density `--space-*` tokens.
enum SproutSpacing {
    static let s1: CGFloat = 4.4
    static let s2: CGFloat = 8.8
    static let s3: CGFloat = 13.2
    static let s4: CGFloat = 17.6
    static let s6: CGFloat = 26.4
    static let s8: CGFloat = 35.2
}

/// Corner radii — the prototype rounds cards and dialogs further still
/// ("everything softens, small controls go pill").
enum SproutRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 28
    static let card: CGFloat = 28 * 1.15
    static let pill: CGFloat = 999
}

/// Elevation shadows tuned to the warm ground.
enum SproutShadow {
    static let sm = (color: Color(hex: 0x2E2B25).opacity(0.14), radius: CGFloat(2), y: CGFloat(1))
    static let md = (color: Color(hex: 0x2E2B25).opacity(0.16), radius: CGFloat(10), y: CGFloat(3))
    static let lg = (color: Color(hex: 0x2E2B25).opacity(0.22), radius: CGFloat(32), y: CGFloat(12))
}
