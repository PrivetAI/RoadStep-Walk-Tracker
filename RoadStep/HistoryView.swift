import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: WalkStore
    @State private var selectedWalk: WalkEntry?
    @State private var showDetail = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.brandLightGray.ignoresSafeArea()
                if store.sortedWalks.isEmpty {
                    VStack(spacing: 12) {
                        FootprintIcon()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.brandGold.opacity(0.4))
                        Text("No walks logged yet")
                            .foregroundColor(.brandDarkGray.opacity(0.6))
                    }
                } else {
                    List {
                        ForEach(store.sortedWalks) { walk in
                            Button(action: {
                                selectedWalk = walk
                                showDetail = true
                            }) {
                                WalkRow(walk: walk)
                            }
                        }
                        .onDelete { offsets in
                            store.deleteWalk(at: offsets)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDetail) {
                if let walk = selectedWalk {
                    WalkDetailSheet(walk: walk)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct WalkRow: View {
    let walk: WalkEntry
    private let df: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(df.string(from: walk.date))
                    .font(.subheadline)
                    .foregroundColor(.brandDarkGray)
                Text(String(format: "%.1f km  •  %d min", walk.distance, Int(walk.duration)))
                    .font(.caption)
                    .foregroundColor(.brandDarkGray.opacity(0.7))
            }
            Spacer()
            Text(walk.intensity)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(intensityColor(walk.intensity).opacity(0.2))
                .foregroundColor(intensityColor(walk.intensity))
                .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }

    private func intensityColor(_ i: String) -> Color {
        switch i {
        case "Fast": return .red
        case "Moderate": return .orange
        default: return .green
        }
    }
}

struct WalkDetailSheet: View {
    let walk: WalkEntry
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                StatCard(title: "Distance", value: String(format: "%.2f km", walk.distance))
                StatCard(title: "Duration", value: "\(Int(walk.duration)) min")
                StatCard(title: "Intensity", value: walk.intensity)
                if !walk.note.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        Text(walk.note)
                            .foregroundColor(.brandDarkGray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                Spacer()
            }
            .padding()
            .background(Color.brandLightGray.ignoresSafeArea())
            .navigationTitle("Walk Detail")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                        .foregroundColor(.brandGold)
                }
            }
        }
    }
}
