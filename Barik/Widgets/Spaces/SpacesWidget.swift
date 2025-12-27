import SwiftUI

struct SpacesWidget: View {
    @StateObject var viewModel = SpacesViewModel()
    
    @AppStorage("foregroundHeight") private var foregroundHeightString = "default"
    
    let showKey: Bool
    let showTitle: Bool
    let titleMaxLength: Int
    
    private var foregroundHeight: CGFloat {
        switch foregroundHeightString {
        case "default":
            return CGFloat(Constants.menuBarHeight)
        case "menu-bar":
            return NSApplication.shared.mainMenu.map({ CGFloat($0.menuBarHeight) }) ?? CGFloat(Constants.menuBarHeight)
        default:
            if let customValue = Float(foregroundHeightString) {
                return CGFloat(customValue)
            }
            return CGFloat(Constants.menuBarHeight)
        }
    }

    var body: some View {
        HStack(spacing: foregroundHeight < 30 ? 0 : 8) {
            ForEach(viewModel.spaces) { space in
                SpaceView(
                    space: space,
                    showKey: showKey,
                    showTitle: showTitle,
                    titleMaxLength: titleMaxLength,
                    foregroundHeight: foregroundHeight
                )
            }
        }
        .animation(.smooth(duration: 0.3), value: viewModel.spaces)
        .foregroundStyle(Color.foreground)
        .environmentObject(viewModel)
    }
}

/// This view shows a space with its windows.
private struct SpaceView: View {
    @EnvironmentObject var viewModel: SpacesViewModel

    let space: AnySpace
    let showKey: Bool
    let showTitle: Bool
    let titleMaxLength: Int
    let foregroundHeight: CGFloat

    @State var isHovered = false

    var body: some View {
        let isFocused = space.windows.contains { $0.isFocused } || space.isFocused
        HStack(spacing: 0) {
            Spacer().frame(width: 10)
            if showKey {
                Text(space.label)
                    .font(.headline)
                    .frame(minWidth: 15)
                    .fixedSize(horizontal: true, vertical: false)
                Spacer().frame(width: 5)
            }
            HStack(spacing: 2) {
                ForEach(space.windows) { window in
                    WindowView(
                        window: window,
                        space: space,
                        showTitle: showTitle,
                        titleMaxLength: titleMaxLength
                    )
                }
            }
            Spacer().frame(width: 10)
        }
        .frame(height: 30)
        .background(
            foregroundHeight < 30 ?
            (isFocused
             ? Color.noActive
             : Color.clear) :
                (isFocused
                 ? Color.active
                 : isHovered ? Color.noActive : Color.noActive)
        )
        .clipShape(RoundedRectangle(cornerRadius: foregroundHeight < 30 ? 0 : 8, style: .continuous))
        .shadow(color: .shadow, radius: foregroundHeight < 30 ? 0 : 2)
        .transition(.blurReplace)
        .onTapGesture {
            viewModel.switchToSpace(space, needWindowFocus: true)
        }
        .animation(.smooth, value: isHovered)
        .onHover { value in
            isHovered = value
        }
    }
}

/// This view shows a window and its icon.
private struct WindowView: View {
    @EnvironmentObject var viewModel: SpacesViewModel

    let window: AnyWindow
    let space: AnySpace
    let showTitle: Bool
    let titleMaxLength: Int

    @State var isHovered = false

    var body: some View {
        let size: CGFloat = 21
        let sameAppCount = space.windows.filter { $0.appName == window.appName }.count
        // Simplified: always use app name for multiple windows of same app
        let title = sameAppCount > 1 ? window.title : (window.appName ?? "")
        let spaceIsFocused = space.windows.contains { $0.isFocused }
        
        HStack {
            ZStack {
                if let icon = window.appIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: size, height: size)
                        .shadow(
                            color: .iconShadow,
                            radius: 2
                        )
                } else {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .frame(width: size, height: size)
                }
            }
            .opacity(spaceIsFocused && !window.isFocused ? 0.5 : 1)
            .transition(.blurReplace)

            if window.isFocused, !title.isEmpty, showTitle {
                HStack {
                    Text(
                        title.count > titleMaxLength
                            ? String(title.prefix(titleMaxLength)) + "..."
                            : title
                    )
                    .fixedSize(horizontal: true, vertical: false)
                    .shadow(color: .foregroundShadow, radius: 3)
                    .fontWeight(.semibold)
                    Spacer().frame(width: 5)
                }
                .transition(.blurReplace)
            }
        }
        .padding(.all, 2)
        .background(isHovered || (!showTitle && window.isFocused) ? .selected : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .animation(.smooth, value: isHovered)
        .frame(height: 30)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.switchToSpace(space)
            usleep(100_000)
            viewModel.switchToWindow(window)
        }
        .onHover { value in
            isHovered = value
        }
    }
}
