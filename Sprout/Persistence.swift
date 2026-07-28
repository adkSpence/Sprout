import Foundation

/// Everything `AppStore` needs to restore on relaunch, written to a single
/// JSON file in the app's Application Support directory. This is plain local
/// disk storage — it survives app relaunches and rebuilds/reinstalls from
/// Xcode (the on-device container isn't touched by re-signing), but not an
/// app deletion. True iCloud/CloudKit sync needs a paid Apple Developer
/// Program membership to provision, which isn't available here.
struct AppSnapshot: Codable {
    var wallets: [Wallet] = []
    var categories: [Category] = []
    var transactions: [Transaction] = []
    var goals: [Goal] = []
    var budgets: [Budget] = []
}

enum Persistence {
    /// Exposed so `BackupManager` can copy the same bytes out to a
    /// user-chosen backup folder without duplicating the encode logic.
    static var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Sprout", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("data.json")
    }

    static func load() -> AppSnapshot? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(AppSnapshot.self, from: data)
    }

    static func save(_ snapshot: AppSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
