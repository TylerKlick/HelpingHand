//
//  QuickActions.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
import CoreBluetooth

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    let isScanning: Bool
    let bluetoothState: CBManagerState
    let hasConnectedDevices: Bool
    let onScanToggle: () -> Void
    let onDisconnectAll: () -> Void
    
    var body: some View {
        CardView {
            VStack(spacing: 12) {
                CardHeader(title: "Quick Actions")
                
                HStack(spacing: 12) {
                    ScanButton(
                        isScanning: isScanning,
                        bluetoothState: bluetoothState,
                        action: onScanToggle
                    )
                    
                    if hasConnectedDevices {
                        DisconnectAllButton(action: onDisconnectAll)
                    }
                }
            }
        }
    }
}

// MARK: - Scan Button
struct ScanButton: View {
    let isScanning: Bool
    let bluetoothState: CBManagerState
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ScanButtonIcon(isScanning: isScanning)
                ScanButtonText(isScanning: isScanning)
                Spacer()
            }
            .padding(12)
            .background(scanButtonBackground)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(bluetoothState != .poweredOn)
    }
    
    private var scanButtonBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isScanning ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isScanning ? Color.orange : Color.blue, lineWidth: 1)
            )
    }
}

// MARK: - Scan Button Components
struct ScanButtonIcon: View {
    let isScanning: Bool
    
    var body: some View {
        Group {
            if isScanning {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "wifi.circle.fill")
                    .font(.title3)
            }
        }
    }
}

struct ScanButtonText: View {
    let isScanning: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(isScanning ? "Stop Scanning" : "Start Scanning")
                .font(.caption)
                .fontWeight(.medium)
            
            Text(isScanning ? "Searching..." : "Find devices")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Disconnect All Button
struct DisconnectAllButton: View {
    let action: () -> Void
    
    var body: some View {
        Button("Disconnect All", action: action)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.red)
            )
            .buttonStyle(PlainButtonStyle())
    }
}
