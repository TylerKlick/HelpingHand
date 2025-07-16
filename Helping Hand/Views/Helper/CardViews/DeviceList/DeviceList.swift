//
//  DeviceList.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI

struct DeviceList: View {
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    let isPairedList: Bool
    let onDeviceSelect: ((Device) -> Void)?
    let connectionAction: (Device) -> Void
    let devices: [Device]
    
    var body: some View {
        ForEach(devices, id: \.identifier) { device in
            DeviceCard(
                device: device,
                isPaired: isPairedList,
                onTap: onDeviceSelect != nil ? { onDeviceSelect?(device) } : nil,
                onConnectionAction: { connectionAction(device) }
            )
            .environmentObject(device) // Pass device as environment object
        }
    }
}
