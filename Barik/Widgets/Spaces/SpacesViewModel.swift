import SwiftUI
import Combine

@MainActor
class SpacesViewModel: ObservableObject {
    @Published private(set) var spaces: [AnySpace] = []

    private let provider: AnySpacesProvider?
    private var cancellables = Set<AnyCancellable>()

    init() {
        provider = AnySpacesProvider(NativeSpaceProvider())
        startMonitoring()
        loadSpaces()
    }

    deinit {
        cancellables.removeAll()
    }

    private func startMonitoring() {
        // Monitor space changes
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadSpaces()
            }
            .store(in: &cancellables)
        
        // Monitor window changes (opened/closed/minimized)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didLaunchApplicationNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadSpaces()
            }
            .store(in: &cancellables)
        
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didTerminateApplicationNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadSpaces()
            }
            .store(in: &cancellables)
        
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadSpaces()
            }
            .store(in: &cancellables)
    }

    private func loadSpaces() {
        Task {
            spaces = await Task.detached { [weak provider] in
                provider?.getSpacesWithWindows() ?? []
            }.value
        }
    }

    func switchToSpace(_ space: AnySpace, needWindowFocus: Bool = false) {
        Task.detached(priority: .userInitiated) { [weak provider] in
            provider?.focusSpace(spaceId: space.id, needWindowFocus: needWindowFocus)
        }
    }

    func switchToWindow(_ window: AnyWindow) {
        Task.detached(priority: .userInitiated) { [weak provider] in
            provider?.focusWindow(windowId: String(window.id))
        }
    }
}

class IconCache {
    static let shared = IconCache()
    private let cache = NSCache<NSString, NSImage>()
    
    func icon(for appName: String) -> NSImage? {
        if let cached = cache.object(forKey: appName as NSString) {
            return cached
        }
        
        let workspace = NSWorkspace.shared
        guard
            let app = workspace.runningApplications.first(where: {
                $0.localizedName == appName
            }),
            let bundleURL = app.bundleURL
        else { return nil }
        
        let icon = workspace.icon(forFile: bundleURL.path)
        cache.setObject(icon, forKey: appName as NSString)
        
        return icon
    }
}
