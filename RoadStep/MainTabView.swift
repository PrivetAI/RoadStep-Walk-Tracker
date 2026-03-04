import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    HomeIcon().asImage()
                    Text("Dashboard")
                }
                .tag(0)

            LogWalkView()
                .tabItem {
                    PlusCircleIcon().asImage()
                    Text("Log Walk")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    ClockIcon().asImage()
                    Text("History")
                }
                .tag(2)

            StatsView()
                .tabItem {
                    BarChartIcon().asImage()
                    Text("Stats")
                }
                .tag(3)

            GoalsView()
                .tabItem {
                    TargetIcon().asImage()
                    Text("Goals")
                }
                .tag(4)
        }
        .accentColor(.brandGold)
    }
}
