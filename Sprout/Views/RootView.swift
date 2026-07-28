import SwiftUI

struct RootView: View {
    @StateObject private var store = AppStore()

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
        }
        .tint(.sproutAccent)
        .environmentObject(store)
    }
}

#Preview {
    RootView()
}
