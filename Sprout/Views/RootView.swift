import SwiftUI

struct RootView: View {
    @StateObject private var store = AppStore()
    @StateObject private var backup = BackupManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                PlanningView()
            }
            .tabItem { Label("Planning", systemImage: "target") }

            NavigationStack {
                StatsView()
            }
            .tabItem { Label("Stats", systemImage: "chart.bar") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.sproutAccent)
        .environmentObject(store)
        .environmentObject(backup)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                backup.performAutoBackupIfDue()
            }
        }
    }
}

#Preview {
    RootView()
}
