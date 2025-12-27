import SwiftUI

struct SettingsView: View {
    // Appearance
    @AppStorage("theme") private var themeValue = "system"
    
    // Background settings
    @AppStorage("backgroundEnabled") private var backgroundEnabled = true
    @AppStorage("backgroundBlur") private var backgroundBlur: Double = 3
    @AppStorage("backgroundHeight") private var backgroundHeight = "default"
    
    // Foreground settings
    @AppStorage("foregroundHeight") private var foregroundHeightDouble: Double = 40.0
    @AppStorage("foregroundHorizontalPadding") private var foregroundPadding: Double = 20
    @AppStorage("foregroundSpacing") private var foregroundSpacing: Double = 20
    
    // Widget background settings
    @AppStorage("widgetsBackgroundEnabled") private var widgetsBackgroundEnabled = false
    @AppStorage("widgetsBackgroundBlur") private var widgetsBackgroundBlur: Double = 3
    
    @State private var selectedAppearance = Appearance.auto
    
    //Appearance settings
    enum Appearance: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case auto = "Auto"
        
        var storageValue: String {
            switch self {
            case .light: return "light"
            case .dark: return "dark"
            case .auto: return "system"
            }
        }
        
        static func from(storageValue: String) -> Appearance {
            switch storageValue {
            case "light": return .light
            case "dark": return .dark
            case "system": return .auto
            default: return .auto
            }
        }
    }
    
    var backgroundMaterial: Material {
        let materials: [Material] = [.ultraThin, .thin, .regular, .thick, .ultraThick, .bar, .bar]
        let index = Int(backgroundBlur) - 1
        return materials[min(max(index, 0), materials.count - 1)]
    }
    
    var widgetBackgroundMaterial: Material {
        let materials: [Material] = [.ultraThin, .thin, .regular, .thick, .ultraThick, .bar]
        let index = Int(widgetsBackgroundBlur) - 1
        return materials[min(max(index, 0), materials.count - 1)]
    }
    
    var isBackgroundBlack: Bool {
        Int(backgroundBlur) == 7
    }
   
    var body: some View {
        Form {
            // MARK: - Appearance Section
            Section {
                HStack(spacing: 12) {
                    ForEach(Appearance.allCases, id: \.self) { appearance in
                        appearanceButton(appearance)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Appearance")
            }
            
            // MARK: - Background Section
            Section {
                Toggle("Enable Background", isOn: $backgroundEnabled)
                
                if backgroundEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Blur Intensity")
                            Spacer()
                            HStack(spacing: 4) {
                                Text("\(Int(backgroundBlur))")
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                                if isBackgroundBlack {
                                    Text("(Black)")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        HStack {
                            Text("Level 7 is opaque")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            Slider(value: $backgroundBlur, in: 1...7, step: 1)
                        }
                        
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Background")
            } footer: {
                if backgroundEnabled {
                    Text("Show background blur effect")
                } else {
                    Text("Show background blur effect")
                }
            }
            
            // MARK: - Foreground Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Horizontal Padding") // Main label
                        Spacer()
                        
                        Text("\(Int(foregroundPadding))pt")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    HStack {
                        Text("Default: 20")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Slider(value: $foregroundPadding, in: 0...50, step: 5)
                    }
                    
                }

                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Widget Spacing")
                        Spacer()
                        Text("\(Int(foregroundSpacing))pt")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    HStack {
                        Text("Default: 20")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Slider(value: $foregroundSpacing, in: 0...50, step: 5)
                    }
                    
                }
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Menu Bar Height")
                        Spacer()
                        Text("\(Int(foregroundHeightDouble))pt")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    HStack {
                        Text("Default: 40")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        Slider(value: $foregroundHeightDouble, in: 0...100, step: 10)
                    }
                    
                }
                .padding(.vertical, 4)
            } header: {
                Text("Menu Bar")
            }
            
            // MARK: - Widget Background Section
            Section {
                Toggle("Enable Widget Backgrounds", isOn: $widgetsBackgroundEnabled)
                
                if widgetsBackgroundEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Blur Intensity")
                            Spacer()
                            Text("\(Int(widgetsBackgroundBlur))")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        
                        Slider(value: $widgetsBackgroundBlur, in: 1...6, step: 1)
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Widget Background")
            } footer: {
                if widgetsBackgroundEnabled {
                    Text("Show blur background behind each widget")
                } else {
                    Text("Show blur background behind each widget")
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            selectedAppearance = Appearance.from(storageValue: themeValue)
            applyAppearance(selectedAppearance)
        }
    }
    
    // Appearance button
    @ViewBuilder
    func appearanceButton(_ appearance: Appearance) -> some View {
        Button(action: {
            withAnimation(.smooth(duration: 0.3)) {
                selectedAppearance = appearance
                themeValue = appearance.storageValue
                applyAppearance(appearance)
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: iconName(for: appearance))
                    .font(.system(size: 20))
                    .foregroundStyle(selectedAppearance == appearance ? .white : .primary)
                
                Text(appearance.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(selectedAppearance == appearance ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedAppearance == appearance ?
                          Color.accentColor : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        selectedAppearance == appearance ?
                        Color.clear : Color.primary.opacity(0.15),
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    func iconName(for appearance: Appearance) -> String {
        switch appearance {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .auto: return "circle.lefthalf.filled"
        }
    }
    
    func applyAppearance(_ appearance: Appearance) {
        switch appearance {
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        case .auto:
            NSApp.appearance = nil
        }
    }
}

#Preview {
    SettingsView()
}
