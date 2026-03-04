import SwiftUI

struct StepLoadingScreen: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 24) {
                FootprintIcon()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(hex: "D4A017"))
                    .scaleEffect(pulse ? 1.1 : 0.9)
                    .animation(
                        Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: pulse
                    )
                Text("RoadStep")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "4A4A4A"))
                Text("Walk Tracker")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "4A4A4A").opacity(0.6))
            }
        }
        .onAppear { pulse = true }
    }
}
