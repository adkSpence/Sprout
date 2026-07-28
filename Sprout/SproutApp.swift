import SwiftUI
import CoreText

@main
struct SproutApp: App {

    init() {
        FontLoader.registerBundledFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Registers the bundled Poppins/Inter TTFs with Core Text at launch, since
/// they're plain resources in the app bundle rather than declared via
/// `UIAppFonts` in Info.plist.
enum FontLoader {
    static func registerBundledFonts() {
        let names = [
            "Poppins-Regular", "Poppins-Medium", "Poppins-SemiBold", "Poppins-Bold",
            "Inter-Regular", "Inter-Medium", "Inter-SemiBold", "Inter-Bold",
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
