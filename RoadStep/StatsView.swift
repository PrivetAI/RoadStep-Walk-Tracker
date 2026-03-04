import SwiftUI

struct StatsView: View {
    @EnvironmentObject var store: WalkStore
    @State private var period = 0 // 0=weekly, 1=monthly

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Period", selection: $period) {
                        Text("Weekly").tag(0)
                        Text("Monthly").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Bar chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Distance per Day")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        MiniBarChart(data: chartData)
                            .frame(height: 160)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                    .padding(.horizontal)

                    // Stats cards
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            StatCard(title: "Total Distance", value: String(format: "%.1f km", totalDistance))
                            StatCard(title: "Avg Duration", value: String(format: "%.0f min", avgDuration))
                        }
                        HStack(spacing: 12) {
                            StatCard(title: "Total Walks", value: "\(totalWalks)")
                            StatCard(title: "Streak", value: "\(store.currentStreak()) days")
                        }
                        if let longest = store.longestWalk() {
                            StatCard(title: "Longest Walk", value: String(format: "%.1f km", longest.distance))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.brandLightGray.ignoresSafeArea())
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var filteredWalks: [WalkEntry] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let daysBack = period == 0 ? 7 : 30
        guard let start = cal.date(byAdding: .day, value: -daysBack, to: today) else { return [] }
        return store.walks.filter { $0.date >= start }
    }

    private var chartData: [(String, Double)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let days = period == 0 ? 7 : 30
        let formatter = DateFormatter()
        formatter.dateFormat = days <= 7 ? "EEE" : "d"
        var result: [(String, Double)] = []
        for i in (0..<days).reversed() {
            if let day = cal.date(byAdding: .day, value: -i, to: today) {
                result.append((formatter.string(from: day), store.distanceForDay(day)))
            }
        }
        return result
    }

    private var totalDistance: Double { filteredWalks.reduce(0) { $0 + $1.distance } }
    private var totalWalks: Int { filteredWalks.count }
    private var avgDuration: Double {
        guard !filteredWalks.isEmpty else { return 0 }
        return filteredWalks.reduce(0) { $0 + $1.duration } / Double(filteredWalks.count)
    }
}
