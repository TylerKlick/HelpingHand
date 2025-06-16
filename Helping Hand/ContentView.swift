//
//  ContentView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

struct ContentView: View {
    
    enum Tab {
        case home
        case device
        case train
        case settings
        case help
    }
    @State var selectedTab: Tab = .home

    var body: some View {
            
        
        TabView(selection: $selectedTab) {
            
            Image(systemName: "house")
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            Image(systemName: "house")
                .tabItem {
                    Label("My Device", systemImage: "hands.sparkles")
                }
                .tag(Tab.device)
            
            Image(systemName: "house")
                .tabItem {
                    Label("Train", systemImage: "brain.fill")
                }
                .tag(Tab.train)
            
            Image(systemName: "house")
                .tabItem {
                    Label("Help", systemImage: "exclamationmark.message.fill")
                }
                .tag(Tab.help)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    ContentView()
}
