//
//  ContentView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI
internal import FluidGradient

struct ContentView: View {
    
    var body: some View {
        
        
        FluidGradient(
            blobs: [.purple, .cyan, .indigo],
            highlights: [.green.opacity(0.8)],
            speed: 0.1,
            blur: 0.75
        )
        .ignoresSafeArea()
        .overlay(
            BluetoothView()

//            CustomTabView {
//                CustomTab(title: "Home", image: "house", accentColor: .blue) {
//                    VStack {
//                        Text("Home View")
//                            .font(.largeTitle)
//                        Spacer()
//                    }
//                }
//                CustomTab(title: "Settings", image: "gear", accentColor: .purple) {
//                    VStack {
//                        Text("Settings View")
//                            .font(.largeTitle)
//                        Spacer()
//                    }
//                }
//                CustomTab(title: "Settings", image: "gear", accentColor: .indigo) {
//                    VStack {
//                        Text("Settings View")
//                            .font(.largeTitle)
//                        Spacer()
//                    }
//                }
//                CustomTab(title: "Settings", image: "gear", accentColor: .orange) {
//                    VStack {
//                        Text("Settings View")
//                            .font(.largeTitle)
//                        Spacer()
//                    }
//                }
//            }
                    )
    }
}

#Preview {
    ContentView()
}
