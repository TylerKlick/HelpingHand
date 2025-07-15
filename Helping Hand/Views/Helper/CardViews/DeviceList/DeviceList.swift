//
//  DeviceList.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
internal import SwiftUIVisualEffects

// MARK: - Device List
struct DeviceList: View {
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    let devices: [Device]
    let isPairedList: Bool
    let onDeviceSelect: ((Device) -> Void)?
    let connectionAction: (Device) -> Void
    let connectionState: (Device) -> ConnectionState
    
    var body: some View {
        LazyVStack(spacing: 8) {
            ForEach(devices, id: \.identifier) { device in
                DeviceCard(
                    device: device,
                    connectionState: bluetoothManager.getConnectionState(for: device),
                    isPaired: isPairedList,
                    onTap: onDeviceSelect != nil ? { onDeviceSelect?(device) } : nil,
                    onConnectionAction: { connectionAction(device) }
                )
            }
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
        title: "Populated List",
        devices: [Device(name: "Test Device", identifier: UUID(uuidString: "829AD7B6-F39A-4EE5-CF32-A3EE33E5EB75")!),
                  Device(name: "Test Device", identifier: UUID(uuidString: "829AD7B6-F39A-4EE5-CF32-A3EE33E5EB76")!),
                  Device(name: "Test Device", identifier: UUID(uuidString: "829AD7B6-F39A-4EE5-CF32-A3EE33E5EB77")!),
                  Device(name: "Test Device", identifier: UUID(uuidString: "829AD7B6-F39A-4EE5-CF32-A3EE33E5EB78")!)
                 ],
        emptyMessage: "Empty",
        emptySubtitle: "Empty",
        showCount: true,
        connectionAction: { _ in },
        connectionState: { _ in .disconnected }
    )
}
