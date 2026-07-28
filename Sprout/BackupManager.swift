import Foundation

/// Backs up the local data store to a folder the user picks once (e.g. an
/// iCloud Drive folder) via a security-scoped bookmark, and restores from it.
///
/// This works without any Apple Developer Program membership because it
/// never touches CloudKit or an iCloud container entitlement — it just
/// writes a plain JSON file into a folder the user granted access to through
/// the system file picker. Whether that folder happens to live in iCloud
/// Drive, on a local disk, or elsewhere is entirely up to the user.
final class BackupManager: ObservableObject {
    @Published private(set) var folderName: String?
    @Published private(set) var lastBackupDate: Date?
    @Published var autoBackupEnabled: Bool {
        didSet { UserDefaults.standard.set(autoBackupEnabled, forKey: Keys.autoEnabled) }
    }

    private enum Keys {
        static let bookmark = "backupFolderBookmark"
        static let lastBackup = "lastBackupDate"
        static let autoEnabled = "autoBackupEnabled"
    }

    private static let backupFilename = "sprout-backup.json"

    init() {
        autoBackupEnabled = UserDefaults.standard.bool(forKey: Keys.autoEnabled)
        lastBackupDate = UserDefaults.standard.object(forKey: Keys.lastBackup) as? Date
        folderName = Self.resolveFolderURL()?.lastPathComponent
    }

    var hasFolder: Bool { folderName != nil }

    /// Called with the URL handed back by `.fileImporter` after the user
    /// picks a destination folder. Persists a security-scoped bookmark so we
    /// can write to it again later without re-prompting.
    func setFolder(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let bookmark = try? url.bookmarkData() else { return }
        UserDefaults.standard.set(bookmark, forKey: Keys.bookmark)
        folderName = url.lastPathComponent
    }

    private static func resolveFolderURL() -> URL? {
        guard let bookmark = UserDefaults.standard.data(forKey: Keys.bookmark) else { return nil }
        var isStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmark, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale) else {
            return nil
        }
        return url
    }

    @discardableResult
    func backupNow() -> Bool {
        guard let folder = Self.resolveFolderURL() else { return false }
        guard folder.startAccessingSecurityScopedResource() else { return false }
        defer { folder.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: Persistence.fileURL) else { return false }
        let dest = folder.appendingPathComponent(Self.backupFilename)
        guard (try? data.write(to: dest, options: .atomic)) != nil else { return false }
        let now = Date()
        lastBackupDate = now
        UserDefaults.standard.set(now, forKey: Keys.lastBackup)
        return true
    }

    @discardableResult
    func restoreLatest(into store: AppStore) -> Bool {
        guard let folder = Self.resolveFolderURL() else { return false }
        guard folder.startAccessingSecurityScopedResource() else { return false }
        defer { folder.stopAccessingSecurityScopedResource() }
        let source = folder.appendingPathComponent(Self.backupFilename)
        guard let data = try? Data(contentsOf: source),
              let snapshot = try? JSONDecoder().decode(AppSnapshot.self, from: data) else {
            return false
        }
        store.restore(from: snapshot)
        return true
    }

    /// Call whenever the app becomes active. If auto-backup is on and we
    /// haven't backed up since the most recent Sunday 6pm, silently writes a
    /// fresh backup — no prompts, since the folder permission was already
    /// granted once.
    ///
    /// Note: iOS has no reliable way to run this at an exact time while the
    /// app is closed — background scheduling is opportunistic at best, and
    /// is suspended entirely if the user force-quits the app. Checking on
    /// every foreground/launch is what actually guarantees the backup
    /// happens (the next time Sprout is opened on or after Sunday evening).
    func performAutoBackupIfDue() {
        guard autoBackupEnabled, hasFolder else { return }
        guard let dueSince = Self.mostRecentSundayEvening(before: .now) else { return }
        if let last = lastBackupDate, last >= dueSince { return }
        backupNow()
    }

    private static func mostRecentSundayEvening(before date: Date) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = 1 // Sunday
        components.hour = 18
        components.minute = 0
        components.second = 0
        guard let thisWeekSunday = calendar.date(from: components) else { return nil }
        if thisWeekSunday <= date {
            return thisWeekSunday
        }
        return calendar.date(byAdding: .day, value: -7, to: thisWeekSunday)
    }
}
