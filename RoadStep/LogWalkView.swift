import SwiftUI

struct LogWalkView: View {
    @EnvironmentObject var store: WalkStore
    @State private var distanceText = ""
    @State private var durationText = ""
    @State private var intensity = "Easy"
    @State private var note = ""
    @State private var useMiles = false
    @State private var showConfirmation = false

    private let intensities = ["Easy", "Moderate", "Fast"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Distance
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Distance")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        HStack {
                            TextField("0.0", text: $distanceText)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Picker("Unit", selection: $useMiles) {
                                Text("km").tag(false)
                                Text("mi").tag(true)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 100)
                        }
                    }

                    // Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duration (minutes)")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        TextField("0", text: $durationText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // Intensity
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Intensity")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        Picker("Intensity", selection: $intensity) {
                            ForEach(intensities, id: \.self) { Text($0) }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.headline)
                            .foregroundColor(.brandDarkGray)
                        TextEditor(text: $note)
                            .frame(height: 80)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.brandLightGray))
                    }

                    // Save button
                    Button(action: saveWalk) {
                        Text("Save Walk")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandGold)
                            .cornerRadius(12)
                    }

                    if showConfirmation {
                        Text("Walk saved!")
                            .font(.headline)
                            .foregroundColor(.green)
                            .transition(.opacity)
                    }
                }
                .padding()
            }
            .background(Color.brandLightGray.ignoresSafeArea())
            .navigationTitle("Log Walk")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func saveWalk() {
        guard let dist = Double(distanceText), dist > 0,
              let dur = Double(durationText), dur > 0 else { return }

        let km = useMiles ? dist * 1.60934 : dist
        let walk = WalkEntry(date: Date(), distance: km, duration: dur, intensity: intensity, note: note)
        store.addWalk(walk)

        distanceText = ""
        durationText = ""
        intensity = "Easy"
        note = ""

        withAnimation { showConfirmation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showConfirmation = false }
        }
    }
}
