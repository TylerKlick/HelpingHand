//
//  DeviceList.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
import CoreBluetooth
internal import SwiftUIVisualEffects

// MARK: - Device List Card
struct DeviceListCard: View {
    let title: String
    let devices: [CBPeripheral]
    let emptyMessage: String
    let emptySubtitle: String
    let showCount: Bool
    let isScanning: Bool?
    let onDeviceSelect: ((CBPeripheral) -> Void)?
    let connectionAction: (CBPeripheral) -> Void
    let connectionState: (CBPeripheral) -> ConnectionState
    
    init(
        title: String,
        devices: [CBPeripheral],
        emptyMessage: String,
        emptySubtitle: String,
        showCount: Bool,
        isScanning: Bool? = nil,
        onDeviceSelect: ((CBPeripheral) -> Void)? = nil,
        connectionAction: @escaping (CBPeripheral) -> Void,
        connectionState: @escaping (CBPeripheral) -> ConnectionState
    ) {
        self.title = title
        self.devices = devices
        self.emptyMessage = emptyMessage
        self.emptySubtitle = emptySubtitle
        self.showCount = showCount
        self.isScanning = isScanning
        self.onDeviceSelect = onDeviceSelect
        self.connectionAction = connectionAction
        self.connectionState = connectionState
    }
    
    var body: some View {
        CardView {
            VStack(spacing: 12) {
                DeviceListHeader(
                    title: title,
                    deviceCount: devices.count,
                    showCount: showCount,
                    isScanning: isScanning
                )
                
                if devices.isEmpty {
                    EmptyStateView(
                        icon: iconForEmptyState,
                        title: emptyMessage,
                        subtitle: emptySubtitle
                    )
                } else {
                    DeviceList(
                        devices: devices,
                        isPairedList: title == "Paired Devices",
                        onDeviceSelect: onDeviceSelect,
                        connectionAction: connectionAction,
                        connectionState: connectionState
                    )
                }
            }
        }
    }
    
    private var iconForEmptyState: String {
        switch title {
        case "Connected Devices": return "antenna.radiowaves.left.and.right.slash"
        case "Paired Devices": return "link.badge.plus"
        case "Discovered Devices": return "magnifyingglass"
        default: return "magnifyingglass"
        }
    }
}

// MARK: - Device List Header
struct DeviceListHeader: View {
    let title: String
    let deviceCount: Int
    let showCount: Bool
    let isScanning: Bool?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .opacity(0.95)
            
            Spacer()
            
            if showCount && deviceCount > 0 {
                DeviceCountBadge(count: deviceCount)
            } else if let isScanning = isScanning, isScanning {
                ScanningIndicator()
            }
        }
    }
}

// MARK: - Device List
struct DeviceList: View {
    let devices: [CBPeripheral]
    let isPairedList: Bool
    let onDeviceSelect: ((CBPeripheral) -> Void)?
    let connectionAction: (CBPeripheral) -> Void
    let connectionState: (CBPeripheral) -> ConnectionState
    
    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(devices, id: \.identifier) { device in
                DeviceCard(
                    device: device,
                    connectionState: connectionState(device),
                    isPaired: isPairedList,
                    onTap: onDeviceSelect != nil ? { onDeviceSelect?(device) } : nil,
                    onConnectionAction: { connectionAction(device) }
                )
            }
        }
    }
}

struct DeviceCard: View {
    let device: CBPeripheral
    let connectionState: ConnectionState
    let isPaired: Bool
    let onTap: (() -> Void)?
    let onConnectionAction: () -> Void

    var body: some View {
        let content = HStack(spacing: 16) {
            DeviceIcon(
                connectionState: connectionState,
                isPaired: isPaired
            )

            DeviceInfo(
                device: device,
                isPaired: isPaired
            )

            Spacer()

            DeviceActions(
                connectionState: connectionState,
                onConnectionAction: onConnectionAction
            )
        }
        .padding(16)
//        .vibrancyEffect()
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )

        if let onTap = onTap {
            Button(action: onTap) {
                content
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            content
        }
    }

    private var borderColor: Color {
        switch connectionState {
        case .connected: return .green.opacity(0.3)
        case .connecting, .validating: return .orange.opacity(0.3)
        case .validationFailed: return .red.opacity(0.3)
        default: return isPaired ? .blue.opacity(0.2) : .clear
        }
    }
}

// MARK: - Device Icon
struct DeviceIcon: View {
    let connectionState: ConnectionState
    let isPaired: Bool
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title2)
            .foregroundColor(iconColor)
            .frame(width: 32, height: 32)
            .background(
                BlurEffect()
                    .blurEffectStyle(.systemUltraThinMaterial)
                    .clipShape(Circle())
            )
    }
    
    private var iconName: String {
        isPaired ? "link.badge.plus" : "antenna.radiowaves.left.and.right"
    }
    
    private var iconColor: Color {
        switch connectionState {
        case .connected: return .green
        case .connecting, .validating: return .orange
        case .validationFailed: return .red
        default: return isPaired ? .blue : .gray
        }
    }
}

// MARK: - Device Info
struct DeviceInfo: View {
    let device: CBPeripheral
    let isPaired: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(device.name ?? "Unknown Device")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if isPaired {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Text(device.identifier.uuidString.prefix(8) + "...")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Device Actions
struct DeviceActions: View {
    let connectionState: ConnectionState
    let onConnectionAction: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ConnectionStatusView(state: connectionState)
            ConnectionButton(
                state: connectionState,
                action: onConnectionAction
            )
        }
    }
}

#Preview("Empty"){
    DeviceListCard(
        title: "Empty List",
        devices: [],
        emptyMessage: "Empty",
        emptySubtitle: "Empty",
        showCount: true,
        connectionAction: { _ in },
        connectionState: { _ in .disconnected }
    )
}

struct MockPeripheral: Identifiable {
    let id = UUID()
    let name: String
}

#Preview ("Populated"){
    DeviceListCard(
        title: "Empty List",
        devices: [CBPeripheral(],
        emptyMessage: "Empty",
        emptySubtitle: "Empty",
        showCount: true,
        connectionAction: { _ in },
        connectionState: { _ in .disconnected }
    )
}
