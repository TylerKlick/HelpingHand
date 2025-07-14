//
//  ContentView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI
internal import FluidGradient
internal import SwiftUIVisualEffects

struct ContentView: View {
    
    var body: some View {
        
        
//        FluidGradient(
//            blobs: [.purple, .cyan, .indigo],
//            highlights: [.green.opacity(0.8)],
//            speed: 0.1,
//            blur: 0.9
//        )
//        .ignoresSafeArea()
//        .overlay(
//         )
        
        let tabItems = [
            CustomTabItem(
                systemImageName: "house",
                title: "Home",
                backgroundGradient: LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
            ) {
                
                MeshGradientBackground()
                .ignoresSafeArea()
                .overlay(
                    BluetoothView()
                ) 
            }, CustomTabItem(
                systemImageName: "house",
                title: "Home",
                backgroundGradient: LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
            ) {
                
                FluidGradient(
                    blobs: [.purple, .cyan, .indigo],
                    highlights: [.green.opacity(0.8)],
                    speed: 0.1,
                    blur: 0.9
                )
                .ignoresSafeArea()
                .overlay(
                    BluetoothView()
                )
            },
            CustomTabItem(
                systemImageName: "house",
                title: "Home",
                backgroundGradient: LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
            ) {
                
                FluidGradient(
                    blobs: [.purple, .cyan, .indigo],
                    highlights: [.green.opacity(0.8)],
                    speed: 0.1,
                    blur: 0.9
                )
                .ignoresSafeArea()
                .overlay(
                    BluetoothView()
                )
            },
            CustomTabItem(
                systemImageName: "house",
                title: "Home",
                backgroundGradient: LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
            ) {
                
                FluidGradient(
                    blobs: [.purple, .cyan, .indigo],
                    highlights: [.green.opacity(0.8)],
                    speed: 0.1,
                    blur: 0.9
                )
                .ignoresSafeArea()
                .overlay(
                    BluetoothView()
                )
            }
        ]
        
        CustomTabView(items: tabItems)
            
    }
}

#Preview {
    ContentView()
}
