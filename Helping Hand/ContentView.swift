//
//  ContentView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        CustomTabView {
            CustomTab(title: "Home", image: "house", accentColor: .blue) {
                VStack {
                    Text("Home View")
                        .font(.largeTitle)
                    Spacer()
                }
            }
            CustomTab(title: "Settings", image: "gear", accentColor: .green) {
                VStack {
                    Text("Settings View")
                        .font(.largeTitle)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
