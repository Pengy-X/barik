//
//  SettingsView.swift
//  Barik
//
//  Created by Pengy X on 12/23/25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    // Use @AppStorage to automatically save and load the setting's value.
    // The value is stored in UserDefaults, so it persists between app launches.
    @AppStorage("showNotifications") private var showNotifications = false
    @AppStorage("userName") private var userName = ""

    // MARK: - Body
    var body: some View {
        // Container for settings
        Form {
            // Group related settings together.
            Section(header: Text("General")) {
                // A Toggle is for on/off settings.
                Toggle(isOn: $showNotifications) {
                    Text("Enable Notifications")
                }
            }

            Section(header: Text("User Profile")) {
                // A TextField bound to the userName property.
                // The $ creates a two-way binding, so changes to the field update the property, and vice-versa.
                TextField(text: $userName, prompt: Text("This is a box that I made")) {}
            }
        }
        .padding() // Add some space around the form.
    }
}

// MARK: - Preview
// This allows you to see your view in the Xcode canvas.
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
