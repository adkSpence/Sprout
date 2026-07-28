import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var backup: BackupManager

    @State private var showFolderPicker = false
    @State private var showRestoreConfirm = false
    @State private var statusMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SproutSpacing.s4) {
                Text("Settings").font(.sproutHeading(26))

                SproutCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Backup").font(.sproutHeading(17))

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Backup folder").font(.sproutBody(13, weight: .semibold))
                                Text(backup.folderName ?? "Not set")
                                    .font(.sproutBody(12))
                                    .foregroundStyle(Color.sproutNeutral700)
                            }
                            Spacer()
                            SproutButton(title: backup.hasFolder ? "Change" : "Choose", style: .secondary) {
                                showFolderPicker = true
                            }
                            .fixedSize()
                        }

                        Divider().overlay(Color.sproutDivider)

                        Toggle(isOn: $backup.autoBackupEnabled) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Auto backup on Sundays").font(.sproutBody(13, weight: .semibold))
                                Text("Silently backs up the next time you open Sprout on or after Sunday evening.")
                                    .font(.sproutBody(11.5))
                                    .foregroundStyle(Color.sproutNeutral700)
                            }
                        }
                        .tint(.sproutAccent)
                        .disabled(!backup.hasFolder)

                        Divider().overlay(Color.sproutDivider)

                        HStack {
                            Text(lastBackupLabel)
                                .font(.sproutBody(12))
                                .foregroundStyle(Color.sproutNeutral700)
                            Spacer()
                        }

                        HStack(spacing: 10) {
                            SproutButton(title: "Back up now", style: .primary) {
                                statusMessage = backup.backupNow() ? "Backed up just now." : "Backup failed — check the folder is still accessible."
                            }
                            .disabled(!backup.hasFolder)

                            SproutButton(title: "Restore", style: .secondary) {
                                showRestoreConfirm = true
                            }
                            .disabled(!backup.hasFolder)
                        }

                        if let statusMessage {
                            Text(statusMessage)
                                .font(.sproutBody(12))
                                .foregroundStyle(Color.sproutAccent700)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color.sproutBg)
        .fileImporter(isPresented: $showFolderPicker, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result {
                backup.setFolder(url)
            }
        }
        .alert("Restore from backup?", isPresented: $showRestoreConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Restore", role: .destructive) {
                statusMessage = backup.restoreLatest(into: store)
                    ? "Restored from backup."
                    : "No backup found in that folder."
            }
        } message: {
            Text("This replaces everything currently in Sprout with the last backup. This can't be undone.")
        }
    }

    private var lastBackupLabel: String {
        guard let date = backup.lastBackupDate else { return "Never backed up" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Last backup: \(formatter.string(from: date))"
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environmentObject(AppStore())
        .environmentObject(BackupManager())
}
