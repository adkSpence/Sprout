import SwiftUI

/// A surface-filled container mirroring the prototype's `.card`, over-rounded
/// per the system's "rounded frame" rule.
struct SproutCard<Content: View>: View {
    var elevated: Bool = true
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(SproutSpacing.s3)
            .background(Color.sproutSurface)
            .clipShape(RoundedRectangle(cornerRadius: SproutRadius.card, style: .continuous))
            .shadow(
                color: elevated ? SproutShadow.sm.color : .clear,
                radius: elevated ? SproutShadow.sm.radius : 0,
                y: elevated ? SproutShadow.sm.y : 0
            )
    }
}

/// A rounded, tinted square used for wallet/category/subcategory icons.
struct SproutIconChip: View {
    let systemImage: String
    var tint: Color = .sproutAccent800
    var background: Color = .sproutAccent100
    var size: CGFloat = 34
    var iconSize: CGFloat = 16

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.32, style: .continuous))
    }
}

/// A rounded progress bar used for goal/budget cards.
struct SproutProgressBar: View {
    let progress: Double // 0...1
    var trackColor: Color = .sproutNeutral300
    var fillColor: Color = .sproutAccent2_500
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(trackColor)
                Capsule()
                    .fill(fillColor)
                    .frame(width: geo.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: height)
    }
}
