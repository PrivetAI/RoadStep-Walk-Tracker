import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: WalkStore

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Today summary cards
                    HStack(spacing: 12) {
                        StatCard(title: "Distance", value: String(format: "%.1f km", todayDistance))
                        StatCard(title: "Time", value: "\(Int(todayDuration)) min")
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        StatCard(title: "Walks", value: "\(todayCount)")
                        StatCard(title: "Streak", value: "\(store.currentStreak()) days")
                    }
                    .padding(.horizontal)

                    // Weekly mini chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last 7 Days")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        MiniBarChart(data: store.last7DaysDistances())
                            .frame(height: 140)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.brandLightGray.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var todayDistance: Double {
        store.todayWalks().reduce(0) { $0 + $1.distance }
    }
    private var todayDuration: Double {
        store.todayWalks().reduce(0) { $0 + $1.duration }
    }
    private var todayCount: Int {
        store.todayWalks().count
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.brandGold)
            Text(title)
                .font(.caption)
                .foregroundColor(.brandDarkGray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}

struct MiniBarChart: View {
    let data: [(String, Double)]

    var body: some View {
        let maxVal = max(data.map { $0.1 }.max() ?? 1, 0.1)
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<data.count, id: \.self) { i in
                    VStack(spacing: 4) {
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.brandGold)
                            .frame(height: max(CGFloat(data[i].1 / maxVal) * (geo.size.height - 24), 4))
                        Text(data[i].0)
                            .font(.system(size: 10))
                            .foregroundColor(.brandDarkGray)
                    }
                }
            }
        }
    }
}
