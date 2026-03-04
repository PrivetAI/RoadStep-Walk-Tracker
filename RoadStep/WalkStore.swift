import SwiftUI

struct WalkEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var date: Date
    var distance: Double // always stored in km
    var duration: Double // minutes
    var intensity: String // Easy, Moderate, Fast
    var note: String
}

struct WeeklyGoal: Codable {
    var distanceKm: Double
    var dailyWalkCount: Int
}

struct GoalAchievement: Identifiable, Codable {
    var id: String = UUID().uuidString
    var weekStart: Date
    var targetKm: Double
    var achievedKm: Double
    var targetDailyWalks: Int
    var daysWithWalks: Int
}

class WalkStore: ObservableObject {
    @Published var walks: [WalkEntry] = []
    @Published var weeklyGoal: WeeklyGoal = WeeklyGoal(distanceKm: 10, dailyWalkCount: 1)
    @Published var goalHistory: [GoalAchievement] = []

    private let walksKey = "roadstep_walks"
    private let goalKey = "roadstep_goal"
    private let goalHistoryKey = "roadstep_goal_history"

    init() { load() }

    func load() {
        if let data = UserDefaults.standard.data(forKey: walksKey),
           let decoded = try? JSONDecoder().decode([WalkEntry].self, from: data) {
            walks = decoded
        }
        if let data = UserDefaults.standard.data(forKey: goalKey),
           let decoded = try? JSONDecoder().decode(WeeklyGoal.self, from: data) {
            weeklyGoal = decoded
        }
        if let data = UserDefaults.standard.data(forKey: goalHistoryKey),
           let decoded = try? JSONDecoder().decode([GoalAchievement].self, from: data) {
            goalHistory = decoded
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(walks) {
            UserDefaults.standard.set(data, forKey: walksKey)
        }
        if let data = try? JSONEncoder().encode(weeklyGoal) {
            UserDefaults.standard.set(data, forKey: goalKey)
        }
        if let data = try? JSONEncoder().encode(goalHistory) {
            UserDefaults.standard.set(data, forKey: goalHistoryKey)
        }
    }

    func addWalk(_ walk: WalkEntry) {
        walks.append(walk)
        save()
    }

    func deleteWalk(at offsets: IndexSet) {
        let sorted = walks.sorted { $0.date > $1.date }
        let toDelete = offsets.map { sorted[$0].id }
        walks.removeAll { toDelete.contains($0.id) }
        save()
    }

    func deleteWalk(id: String) {
        walks.removeAll { $0.id == id }
        save()
    }

    var sortedWalks: [WalkEntry] {
        walks.sorted { $0.date > $1.date }
    }

    func todayWalks() -> [WalkEntry] {
        let cal = Calendar.current
        return walks.filter { cal.isDateInToday($0.date) }
    }

    func walksForDay(_ date: Date) -> [WalkEntry] {
        let cal = Calendar.current
        return walks.filter { cal.isDate($0.date, inSameDayAs: date) }
    }

    func distanceForDay(_ date: Date) -> Double {
        walksForDay(date).reduce(0) { $0 + $1.distance }
    }

    func last7DaysDistances() -> [(String, Double)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var result: [(String, Double)] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        for i in (0..<7).reversed() {
            if let day = cal.date(byAdding: .day, value: -i, to: today) {
                result.append((formatter.string(from: day), distanceForDay(day)))
            }
        }
        return result
    }

    func thisWeekDistance() -> Double {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: today)!
        return walks.filter { $0.date >= startOfWeek }.reduce(0) { $0 + $1.distance }
    }

    func currentStreak() -> Int {
        let cal = Calendar.current
        var streak = 0
        var day = cal.startOfDay(for: Date())
        while true {
            if walksForDay(day).isEmpty { break }
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    func longestWalk() -> WalkEntry? {
        walks.max(by: { $0.distance < $1.distance })
    }

    func saveGoal() { save() }

    func addGoalAchievement(_ a: GoalAchievement) {
        goalHistory.append(a)
        save()
    }
}
