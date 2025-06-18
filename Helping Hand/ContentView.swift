//
//  ContentView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

struct ContentView: View {
    
    enum Tab {
        case device
        case gestures
        case settings
        case help
    }
    @State var selectedTab: Tab = .device

    var body: some View {
            
        CustomTabView() 
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
