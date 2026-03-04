import SwiftUI

struct GoalProgressBar: View {
    let current: Double
    let target: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.brandLightGray)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.brandGold)
                    .frame(width: geo.size.width * min(CGFloat(target > 0 ? current / target : 0), 1.0))
            }
        }
        .frame(height: 20)
    }
}

struct GoalsView: View {
    @EnvironmentObject var store: WalkStore
    @State private var distGoalText = ""
    @State private var dailyGoalText = ""
    @State private var showPrivacy = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly distance goal
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weekly Distance Goal (km)")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        HStack {
                            TextField("\(String(format: "%.1f", store.weeklyGoal.distanceKm))", text: $distGoalText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Set") {
                                if let v = Double(distGoalText), v > 0 {
                                    store.weeklyGoal.distanceKm = v
                                    store.saveGoal()
                                    distGoalText = ""
                                }
                            }
                            .foregroundColor(.brandGold)
                            .font(.headline)
                        }
                        let weekDist = store.thisWeekDistance()
                        GoalProgressBar(current: weekDist, target: store.weeklyGoal.distanceKm)
                        Text(String(format: "%.1f / %.1f km", weekDist, store.weeklyGoal.distanceKm))
                            .font(.caption)
                            .foregroundColor(.brandDarkGray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)

                    // Daily walk count goal
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Walk Count Goal")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        HStack {
                            TextField("\(store.weeklyGoal.dailyWalkCount)", text: $dailyGoalText)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Set") {
                                if let v = Int(dailyGoalText), v > 0 {
                                    store.weeklyGoal.dailyWalkCount = v
                                    store.saveGoal()
                                    dailyGoalText = ""
                                }
                            }
                            .foregroundColor(.brandGold)
                            .font(.headline)
                        }
                        let todayCount = Double(store.todayWalks().count)
                        GoalProgressBar(current: todayCount, target: Double(store.weeklyGoal.dailyWalkCount))
                        Text("\(Int(todayCount)) / \(store.weeklyGoal.dailyWalkCount) walks today")
                            .font(.caption)
                            .foregroundColor(.brandDarkGray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)

                    // Goal history
                    if !store.goalHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Goal Achievements")
                                .font(.headline)
                                .foregroundColor(.brandDarkGray)
                            ForEach(store.goalHistory) { a in
                                HStack {
                                    Text(weekString(a.weekStart))
                                        .font(.caption)
                                        .foregroundColor(.brandDarkGray)
                                    Spacer()
                                    Text(String(format: "%.1f/%.1f km", a.achievedKm, a.targetKm))
                                        .font(.caption)
                                        .foregroundColor(.brandGold)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
                    }

                    // Privacy Policy
                    Button(action: { showPrivacy = true }) {
                        Text("Privacy Policy")
                            .font(.subheadline)
                            .foregroundColor(.brandGold)
                            .underline()
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .background(Color.brandLightGray.ignoresSafeArea())
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPrivacy) {
                NavigationView {
                    StepWebPanel(urlString: "https://roadstepwalktracker.org/click.php")
                        .navigationTitle("Privacy Policy")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") { showPrivacy = false }
                                    .foregroundColor(.brandGold)
                            }
                        }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func weekString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        return "Week of \(f.string(from: date))"
    }
}
