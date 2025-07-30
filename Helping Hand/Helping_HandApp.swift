//
//  Helping_HandApp.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/12/25.
//

import SwiftUI

@main
struct Helping_HandApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Session.self, DataFrame.self, SessionSettings.self])

//                .environmentObject(BluetoothManagerSingleton.shared)
        }
    }
}
