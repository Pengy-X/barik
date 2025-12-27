import SwiftUI

struct BackgroundView: View {
    @ObservedObject private var systemMenuBarDetector = SystemMenuBarDetector.shared
    @AppStorage("theme") private var themeValue = "system"
    @AppStorage("backgroundEnabled") private var backgroundEnabled = true
    @AppStorage("backgroundBlur") private var backgroundBlur: Double = 3
    @AppStorage("backgroundHeight") private var backgroundHeight = "default"
    
    private var backgroundMaterial: Material {
        let materials: [Material] = [.ultraThin, .thin, .regular, .thick, .ultraThick, .bar, .bar]
        let index = Int(backgroundBlur) - 1
        return materials[min(max(index, 0), materials.count - 1)]
    }
    
    private var isBackgroundBlack: Bool {
        Int(backgroundBlur) == 7
    }
    
    private var theme: ColorScheme? {
        switch themeValue {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }
    
    private func resolveHeight(geometry: GeometryProxy) -> CGFloat {
        switch backgroundHeight {
        case "default":
            return geometry.size.height
        case "menu-bar":
            return NSApplication.shared.mainMenu.map({ CGFloat($0.menuBarHeight) }) ?? geometry.size.height
        default:
            // If it's a custom numeric value
            if let customValue = Float(backgroundHeight) {
                return CGFloat(customValue)
            }
            return geometry.size.height
        }
    }
    
    @ViewBuilder
    private var backgroundContent: some View {
        if backgroundEnabled {
            if isBackgroundBlack {
                Color.black
            } else {
                Rectangle()
                    .fill(backgroundMaterial)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .frame(height: resolveHeight(geometry: geometry))
                .background {
                    backgroundContent
                }
                .preferredColorScheme(theme)
                .edgesIgnoringSafeArea(.all).opacity(systemMenuBarDetector.isSystemMenuBarVisible ? 0.0 : 1.0)
                .offset(y: systemMenuBarDetector.isSystemMenuBarVisible ? 8 : 0)
                .animation(.easeInOut(duration: 0.2), value: systemMenuBarDetector.isSystemMenuBarVisible)
        }
    }
}
