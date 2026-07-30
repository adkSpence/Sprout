import SwiftUI

/// A wallet's card on Home — a colored gradient "bank card" look (tinted by
/// wallet type) with a soft diagonal shine, plus a subtle scale/fade as it
/// scrolls away from the center of its horizontal row for a light parallax
/// feel.
struct WalletCard: View {
    let wallet: Wallet
    var centerX: CGFloat
    var coordinateSpace: String

    var body: some View {
        GeometryReader { proxy in
            let midX: CGFloat = proxy.frame(in: .named(coordinateSpace)).midX
            let distance: CGFloat = abs(midX - centerX)
            let progress: CGFloat = min(distance / 260, 1)
            let scale: CGFloat = 1.0 - (progress * 0.08)
            let cardOpacity: Double = Double(1.0 - (progress * 0.25))

            cardBody
                .scaleEffect(scale)
                .opacity(cardOpacity)
        }
        .frame(width: 154, height: 174)
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            SproutIconChip(
                systemImage: wallet.type.icon,
                tint: .white,
                background: .white.opacity(0.24),
                size: 36, iconSize: 17
            )
            Spacer(minLength: 14)
            Text(wallet.name)
                .font(.sproutBody(13, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text(wallet.balanceLabel)
                .font(.sproutHeading(18))
                .foregroundStyle(.white)
                .padding(.bottom, 8)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(wallet.type.rawValue)
                .font(.sproutBody(11, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(.white.opacity(0.22))
                .clipShape(Capsule())
        }
        .padding(16)
        .frame(width: 154, height: 174, alignment: .topLeading)
        .background(
            ZStack {
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                LinearGradient(
                    colors: [.white.opacity(0.24), .clear],
                    startPoint: .top, endPoint: .init(x: 0.5, y: 0.55)
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: gradient.last!.opacity(0.4), radius: 12, y: 7)
    }

    private var gradient: [Color] {
        switch wallet.type {
        case .cash: return [.sproutAccent2_400, .sproutAccent2_700]
        case .card: return [.sproutAccent500, .sproutAccent800]
        case .bank: return [.sproutNeutral500, .sproutNeutral800]
        case .savings: return [.sproutAccent2_500, .sproutAccent2_800]
        }
    }
}
