//
//  SettingsView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        // https://blog.techchee.com/build-app-settings-page-with-swiftui/
        NavigationSplitView {
            
            List {
                SettingsView()
            }
            .navigationTitle("Settings")
            
        } detail: {
            Text("")
        }
    }
}

#Preview {
    SettingsView()
}
