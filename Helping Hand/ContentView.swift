//
//  ContentView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

struct ContentView: View {
    

    private var tabs: [TabInfo] = [
        TabInfo(title: "Profile", icon: "person.fill", color: .blue),
        TabInfo(title: "Search", icon: "brain.fill", color: .purple),
        TabInfo(title: "Favorites", icon: "heart.fill", color: .green),
        TabInfo(title: "Settings", icon: "gearshape.fill", color: .pink)
    ]
    
    
    var body: some View {
//            DeviceListView()
        CustomTabView(tabs: tabs)
//        TabView(selection: $selectedTab) {
//            
//            MyDeviceView()
//                .tabItem {
//                    Label("My Device", systemImage: "hands.sparkles")
//                }
//                .tag(Tab.device)
//            
//            CustomTabView()
//                .tabItem {
//                    Label("Gestures", systemImage: "brain.fill")
//                }
//                .tag(Tab.device)
//            
//            Image(systemName: "house")
//                .tabItem {
//                    Label("Help", systemImage: "exclamationmark.message.fill")
//                }
//                .tag(Tab.help)
//            
//            SettingsView()
//                .tabItem {
//                    Label("Settings", systemImage: "gearshape.fill")
//                }
//                .tag(Tab.settings)
//        }
    }
}

#Preview {
    ContentView()
}
