//
//  QuickActions.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    
    let hasConnectedDevices: Bool
    let onScanToggle: () -> Void
    let onDisconnectAll: () -> Void
    let onPair: () -> Void
    let onConnectAll: () -> Void
    let onUpdateAll: () -> Void
    
    // Section enabled status
    var connectAllEnabled: Bool = true
    var disconnectAllEnabled: Bool = false
    var pairEnabled: Bool = true
    var updateAllEnabled: Bool = true
    
    var body: some View {
        
        let _ = Self._printChanges()

        CardView {
            VStack(spacing: 12) {
                CardHeader(title: "Quick Actions")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 2), spacing: 6) {
                    ConnectAllButton(
                        action: onConnectAll,
                        isEnabled: connectAllEnabled
                    )
                    
                    DisconnectAllButton(
                        hasConnectedDevices: hasConnectedDevices,
                        action: onDisconnectAll,
                        isEnabled: disconnectAllEnabled
                    )
                    
                    PairDeviceButton(
                        action: onPair,
                        isEnabled: pairEnabled
                    )
                    
                    UpdateAllButton(
                        hasConnectedDevices: hasConnectedDevices,
                        action: onUpdateAll,
                        isEnabled: updateAllEnabled
                    )
                }
            }
        }
    }
}

// MARK: - Connect All Button
struct ConnectAllButton: View {
    let action: () -> Void
    var isEnabled: Bool = true

    
    var body: some View {
        QuickActionButton(
            icon: "wifi.circle.fill",
            iconColor: .blue,
            title: "Connect All",
            subtitle: "Link devices",
            borderColor: .blue,
            isEnabled: isEnabled,
            action: action
        )
    }
}

// MARK: - Disconnect All Button
struct DisconnectAllButton: View {
    let hasConnectedDevices: Bool
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        QuickActionButton(
            icon: "xmark.circle.fill",
            iconColor: .red,
            title: "Disconnect All",
            subtitle: "Remove all",
            borderColor: .red,
            isEnabled: isEnabled && hasConnectedDevices,
            action: action
        )
    }
}

// MARK: - Pair Device Button
struct PairDeviceButton: View {
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        QuickActionButton(
            icon: "link.circle.fill",
            iconColor: .green,
            title: "Pair Device",
            subtitle: "Connect new",
            borderColor: .green,
            isEnabled: isEnabled,
            action: action
        )
    }
}

// MARK: - Update All Button
struct UpdateAllButton: View {
    let hasConnectedDevices: Bool
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        QuickActionButton(
            icon: "arrow.clockwise.circle.fill",
            iconColor: .orange,
            title: "Update All",
            subtitle: "Refresh data",
            borderColor: .orange,
            isEnabled: isEnabled && hasConnectedDevices,
            action: action
        )
    }
}
