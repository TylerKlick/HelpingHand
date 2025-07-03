//
//  SettingsView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

struct SettingsView: View {
    
    var options: [RowView] = [
        .init(systemImageName: "gear", title: "General", backgroundColor: .gray, fillWidth: true),
        
        .init(systemImageName: "person.crop.circle", title: "Profile", backgroundColor: .blue, fillWidth: true),
        
        
        .init(systemImageName: "hammer.fill", title: "Testing", backgroundColor: .green, fillWidth: true)
    ]
    
    var body: some View {
        // https://blog.techchee.com/build-app-settings-page-with-swiftui/
        NavigationSplitView {
            ScrollView {
                ForEach(options) { option in
                    NavigationLink(destination: option.destination) {
                        option
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal)
            .navigationTitle("Settings")
        } detail: {
            Text("")
        }
    }
}

#Preview {
    SettingsView()
}
