import SwiftUI

@available(macOS 26.0, *)
@main
struct BarikApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Empty Settings scene - actual settings window managed in AppDelegate
        Settings {
            EmptyView()
        }
    }
}
