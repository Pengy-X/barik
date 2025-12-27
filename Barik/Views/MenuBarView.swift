import SwiftUI

struct MenuBarView: View {
    @ObservedObject private var systemMenuBarDetector = SystemMenuBarDetector.shared
    @AppStorage("theme") private var themeValue = "system"
    @AppStorage("foregroundHorizontalPadding") private var foregroundPadding: Double = 14
    @AppStorage("foregroundSpacing") private var foregroundSpacing: Double = 15
    @AppStorage("foregroundHeight") private var foregroundHeight = "default"
    @AppStorage("widgetsDisplayed") private var widgetsDisplayedData: Data = Data()
    
    // Widget-specific settings
    @AppStorage("widget.spaces.showKey") private var spacesShowKey = true
    @AppStorage("widget.spaces.showTitle") private var spacesShowTitle = true
    @AppStorage("widget.spaces.titleMaxLength") private var spacesTitleMaxLength: Double = 50
    
    @AppStorage("widget.battery.showPercentage") private var batteryShowPercentage = true
    @AppStorage("widget.battery.warningLevel") private var batteryWarningLevel: Double = 30
    @AppStorage("widget.battery.criticalLevel") private var batteryCriticalLevel: Double = 10
    
    @AppStorage("widget.time.format") private var timeFormat = "E d, J:mm"
    @AppStorage("widget.time.calendarFormat") private var timeCalendarFormat = "J:mm"
    @AppStorage("widget.time.showEvents") private var timeShowEvents = true
    @AppStorage("widget.time.timeTimeZone") private var timeTimeZone: String = "automatic"
    
    private var theme: ColorScheme? {
        switch themeValue {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }
    
    private var resolvedForegroundHeight: CGFloat {
        switch foregroundHeight {
        case "default":
            return CGFloat(Constants.menuBarHeight)
        case "menu-bar":
            return NSApplication.shared.mainMenu.map({ CGFloat($0.menuBarHeight) }) ?? CGFloat(Constants.menuBarHeight)
        default:
            if let customValue = Float(foregroundHeight) {
                return CGFloat(customValue)
            }
            return CGFloat(Constants.menuBarHeight)
        }
    }
    
    private var items: [String] {
        if let decoded = try? JSONDecoder().decode([String].self, from: widgetsDisplayedData) {
            return decoded
        }
        return ["default.spaces", "spacer", "default.network", "default.battery", "divider", "default.time"]
    }

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: foregroundSpacing) {
                ForEach(0..<items.count, id: \.self) { index in
                    let itemId = items[index]
                    buildView(for: itemId)
                }
            }

            if !items.contains("system-banner") {
                SystemBannerWidget(withLeftPadding: true)
            }
        }
        .foregroundStyle(Color.foregroundOutside)
        .frame(height: max(resolvedForegroundHeight, 1.0))
        .frame(maxWidth: .infinity)
        .padding(.horizontal, foregroundPadding)
        .background(.black.opacity(0.001))
        .opacity(systemMenuBarDetector.isSystemMenuBarVisible ? 0.0 : 1.0)
        .offset(y: systemMenuBarDetector.isSystemMenuBarVisible ? 8 : 0)
        .animation(.easeInOut(duration: 0.2), value: systemMenuBarDetector.isSystemMenuBarVisible)
        .preferredColorScheme(theme)
    }

    @ViewBuilder
    private func buildView(for itemId: String) -> some View {
        switch itemId {
        case "default.spaces":
            SpacesWidget(
                showKey: spacesShowKey,
                showTitle: spacesShowTitle,
                titleMaxLength: Int(spacesTitleMaxLength)
            )

        case "default.network":
            NetworkWidget()

        case "default.battery":
            BatteryWidget(
                showPercentage: batteryShowPercentage,
                warningLevel: Int(batteryWarningLevel),
                criticalLevel: Int(batteryCriticalLevel)
            )

        case "default.time":
            TimeWidget(
                format: timeFormat,
                timeZone: timeTimeZone, // Add @AppStorage for this if needed
                calendarFormat: timeCalendarFormat,
                showEvents: timeShowEvents,
                calendarManager: CalendarManager()
            )
            
        case "default.nowplaying":
            NowPlayingWidget()

        case "spacer":
            Spacer().frame(minWidth: 50, maxWidth: .infinity)

        case "divider":
            Rectangle()
                .fill(Color.active)
                .frame(width: 2, height: 15)
                .clipShape(Capsule())

        case "system-banner":
            SystemBannerWidget()

        default:
            Text("?\(itemId)?").foregroundColor(.red)
        }
    }
}
