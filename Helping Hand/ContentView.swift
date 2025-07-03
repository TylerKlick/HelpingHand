//
//  ContentView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

struct ContentView: View {
    

    private var tabs: [TabInfo] = [
        TabInfo(title: "Profile", imagePath: "person.fill", accentColor: .blue, onTap: {}),
        TabInfo(title: "Search", imagePath: "brain.fill", accentColor: .purple, onTap: {}),
        TabInfo(title: "Favorites", imagePath: "heart.fill", accentColor: .green, onTap: {}),
        TabInfo(title: "Settings", imagePath: "gearshape.fill", accentColor: .pink, onTap: {} )
    ]
    
    
    var body: some View {
//            DeviceListView()
//        CustomTabView(tabs: tabs)
    }
}

#Preview {
    ContentView()
}
