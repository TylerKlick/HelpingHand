//
//  QuickActions.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
import CoreBluetooth
internal import SwiftUIVisualEffects

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    let isScanning: Bool
    let bluetoothState: CBManagerState
    let hasConnectedDevices: Bool
    let onScanToggle: () -> Void
    let onDisconnectAll: () -> Void
    let onPair: () -> Void
    let onConnectAll: () -> Void
    let onUpdateAll: () -> Void
    
    var body: some View {
        CardView {
            VStack(spacing: 12) {
                CardHeader(title: "Quick Actions")
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 2), spacing: 6) {
                    ConnectAllButton(
                        bluetoothState: bluetoothState,
                        action: onConnectAll
                    )
                    
                    DisconnectAllButton(
                        hasConnectedDevices: hasConnectedDevices,
                        action: onDisconnectAll
                    )
                    
                    PairDeviceButton(
                        bluetoothState: bluetoothState,
                        action: onPair
                    )
                    
                    UpdateAllButton(
                        hasConnectedDevices: hasConnectedDevices,
                        action: onUpdateAll
                    )
                }
            }
        }
    }
}

// MARK: - Connect All Button
struct ConnectAllButton: View {
    let bluetoothState: CBManagerState
    let isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        QuickActionButton(
            icon: "wifi.circle.fill",
            iconColor: .blue,
            title: "Connect All",
            subtitle: "Link devices",
            borderColor: .blue,
            isEnabled: isEnabled && bluetoothState == .poweredOn,
            action: action
        )
    }
}

// MARK: - Disconnect All Button
struct DisconnectAllButton: View {
    let hasConnectedDevices: Bool
    let isEnabled: Bool = true
    let action: () -> Void
    
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
    let bluetoothState: CBManagerState
    let isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        QuickActionButton(
            icon: "link.circle.fill",
            iconColor: .green,
            title: "Pair Device",
            subtitle: "Connect new",
            borderColor: .green,
            isEnabled: isEnabled && bluetoothState == .poweredOn,
            action: action
        )
    }
}

// MARK: - Update All Button
struct UpdateAllButton: View {
    let hasConnectedDevices: Bool
    let isEnabled: Bool = true
    let action: () -> Void
    
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

// MARK: - Quick Action Button Component
struct QuickActionButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let borderColor: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                QuickActionButtonIcon(
                    icon: icon,
                    iconColor: iconColor,
                    isEnabled: isEnabled
                )
                
                QuickActionButtonText(
                    title: title,
                    subtitle: subtitle,
                    isEnabled: isEnabled
                )
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(
                BlurEffect()
                    .blurEffectStyle(.systemUltraThinMaterialDark)
                    .opacity(isEnabled ? 1.0 : 0.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isEnabled ? borderColor : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
    
    // MARK: - Quick Action Button Components
    struct QuickActionButtonIcon: View {
        let icon: String
        let iconColor: Color
        let isEnabled: Bool
        
        var body: some View {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isEnabled ? iconColor : .gray)
        }
    }
    
    struct QuickActionButtonText: View {
        let title: String
        let subtitle: String
        let isEnabled: Bool
        
        var body: some View {
            VStack(spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isEnabled ? .primary : .gray)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
