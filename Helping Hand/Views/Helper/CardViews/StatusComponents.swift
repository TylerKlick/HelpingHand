//
//  StatusComponents.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
import CoreBluetooth
internal import SwiftUIVisualEffects

// MARK: - Hero Status Card
struct HeroStatusCard: View {
    let bluetoothState: CBManagerState
    let connectedCount: Int
    
    var body: some View {
        CardView {
            HStack {
                BluetoothStatusView(state: bluetoothState)
                Spacer()
                ConnectedDevicesBadge(count: connectedCount)
            }
        }
        .blurEffectStyle(.systemChromeMaterialLight)
        .vibrancyEffectStyle(.fill)
    }
}

// MARK: - Bluetooth Status View
struct BluetoothStatusView: View {
    let state: CBManagerState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Bluetooth Status")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var statusColor: Color {
        switch state {
        case .poweredOn: return .green
        case .poweredOff: return .red
        case .unauthorized: return .orange
        case .unsupported: return .red
        default: return .gray
        }
    }
    
    private var statusText: String {
        switch state {
        case .unknown: return "Unknown"
        case .poweredOff: return "Bluetooth is turned off"
        case .poweredOn: return "Ready to connect"
        case .unauthorized: return "Access denied"
        case .unsupported: return "Not supported"
        case .resetting: return "Resetting..."
        @unknown default: return "Unknown state"
        }
    }
}

// MARK: - Connected Devices Badge
struct ConnectedDevicesBadge: View {
    let count: Int
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .vibrancyEffect()
                .vibrancyEffectStyle(.label
                )
            
            Text("Connected")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            BlurEffect()
                .blurEffectStyle(count > 0 ? .systemMaterialLight : .systemMaterialDark)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        )
    }
}

// MARK: - Device Count Badge
struct DeviceCountBadge: View {
    let count: Int
    
    var body: some View {
        Text("\(count) active")
            .font(.caption2)
            .foregroundColor(.green)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                BlurEffect()
                    .blurEffectStyle(.systemUltraThinMaterial)
            )
            .cornerRadius(4)
    }
}

// MARK: - Scanning Indicator
struct ScanningIndicator: View {
    var body: some View {
        HStack(spacing: 4) {
            ProgressView()
                .scaleEffect(0.6)
                .frame(width: 12, height: 12)
            Text("Scanning...")
                .font(.caption2)
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            BlurEffect()
                .blurEffectStyle(.systemUltraThinMaterial)
        )
        .cornerRadius(4)
    }
}
