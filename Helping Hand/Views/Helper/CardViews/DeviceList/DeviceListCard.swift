//
//  DeviceListCard.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct DeviceListCard: View {
    let title: String
    let devices: [Device]
    let emptyMessage: String
    let emptySubtitle: String
    let showCount: Bool
    let isScanning: Bool?
    let onDeviceSelect: ((Device) -> Void)?
    let connectionAction: (Device) -> Void
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    init(
        title: String,
        devices: [Device],
        emptyMessage: String,
        emptySubtitle: String,
        showCount: Bool,
        isScanning: Bool? = nil,
        onDeviceSelect: ((Device) -> Void)? = nil,
        connectionAction: @escaping (Device) -> Void
    ) {
        self.title = title
        self.devices = devices
        self.emptyMessage = emptyMessage
        self.emptySubtitle = emptySubtitle
        self.showCount = showCount
        self.isScanning = isScanning
        self.onDeviceSelect = onDeviceSelect
        self.connectionAction = connectionAction
    }
    
    var body: some View {
        
        let _ = Self._printChanges()

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
                        isPairedList: title == "Paired Devices",
                        onDeviceSelect: onDeviceSelect,
                        connectionAction: connectionAction,
                        devices: devices
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
