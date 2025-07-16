//
//  MyDeviceView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/16/25.
//

import SwiftUI
import CoreBluetooth
internal import SwiftUIVisualEffects

// MARK: - Main Bluetooth View
struct BluetoothView: View {
    
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    @State private var selectedDevice: Device?
    @State private var showingDeviceDetail = false
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomNavigationHeader(title: "Helping Hand")
                
                ScrollView {
                    VStack(spacing: 16) {
                        HeroStatusCard(
                            bluetoothState: bluetoothManager.bluetoothState,
                            connectedCount: connectedDevicesCount
                        )
                        
                        QuickActionsCard(
                            hasConnectedDevices: connectedDevicesCount > 0,
                            onScanToggle: { bluetoothManager.loadPairedDevices()},
                            onDisconnectAll: { bluetoothManager.disconnectAll() },
                            onPair: { bluetoothManager.loadPairedDevices()},
                            onConnectAll: { connectAllDevices() },
                            onUpdateAll: { /* TODO: Implement update all */ },
                            connectAllEnabled: pairedDevices.count > 0 && bluetoothManager.bluetoothState == .poweredOn,
                            disconnectAllEnabled: connectedDevices.count > 0 && bluetoothManager.bluetoothState == .poweredOn,
                            pairEnabled: bluetoothManager.bluetoothState == .poweredOn,
                            updateAllEnabled: connectedDevices.count > 0 && bluetoothManager.bluetoothState == .poweredOn
                        )
                        
                        DeviceListCard(
                            title: "Paired Devices",
                            devices: pairedDevices,
                            emptyMessage: "No Paired Devices",
                            emptySubtitle: "Previously connected devices will appear here",
                            showCount: false,
                            isScanning: bluetoothManager.isScanning,
                            onDeviceSelect: { device in
                                selectedDevice = device
                                showingDeviceDetail = true
                            },
                            connectionAction: { device in
                                bluetoothManager.connect(to: device)
                            },
                            connectionState: { device in
                                return device.connectionState
                            }
                        )
                        
                        DataStreamCard(
                            data: bluetoothManager.receivedData,
                            onClear: { bluetoothManager.receivedData.removeAll() }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func toggleScanning() {
        bluetoothManager.isScanning ? bluetoothManager.stopScanning() : bluetoothManager.startScanning()
    }
    
    private func connectAllDevices() {
        for device in pairedDevices {
            if device.connectionState == .disconnected {
                bluetoothManager.connect(to: device)
            }
        }
    }
    
    private var connectedDevices: [Device] {
        return pairedDevices.filter { $0.connectionState == .connected }
    }
    
    private var pairedDevices: [Device] {
        return bluetoothManager.pairedDevices.compactMap { uuid in
            bluetoothManager.peripheralInfo[uuid]
        }
    }
    
    private var discoveredDevices: [Device] {
        let pairedDeviceIds = Set(bluetoothManager.pairedDevices)
        return bluetoothManager.peripheralInfo.values.filter { device in
            !pairedDeviceIds.contains(device.identifier) && device.connectionState == .disconnected
        }
    }
    
    private var connectedDevicesCount: Int {
        connectedDevices.count
    }
}

// MARK: - Custom Navigation Header
struct CustomNavigationHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.clear)
    }
}
