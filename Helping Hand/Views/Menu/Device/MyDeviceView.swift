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
                            hasConnectedDevices: true,
                            onScanToggle: { bluetoothManager.loadPairedDevices()},
                            onDisconnectAll: { /* action */ },
                            onPair: { bluetoothManager.loadPairedDevices()},
                            onConnectAll: {},
                            onUpdateAll: {},
                            connectAllEnabled: bluetoothManager.pairedDevices.count > 0 && bluetoothManager.bluetoothState == .poweredOn,
                            disconnectAllEnabled: bluetoothManager.pairedDevices.contains(where: { bluetoothManager.isConnected($0) }) && bluetoothManager.bluetoothState == .poweredOn,
                            pairEnabled: bluetoothManager.bluetoothState == .poweredOn,
                            updateAllEnabled: bluetoothManager.pairedDevices.contains(where: { bluetoothManager.isConnected($0) }) && bluetoothManager.bluetoothState == .poweredOn
                            
                        )
                        
                        DeviceListCard(
                            title: "Paired Devices",
                            devices: bluetoothManager.pairedDevices,
                            emptyMessage: "No Paired Devices",
                            emptySubtitle: "Previously connected devices will appear here",
                            showCount: false,
                            onDeviceSelect: { device in
                                selectedDevice = device
                            },
                            connectionAction: bluetoothManager.connect,
                            connectionState: bluetoothManager.getConnectionState
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
    
    private var connectedDevices: [Device] {
        bluetoothManager.pairedDevices.filter(bluetoothManager.isConnected)
    }
    
    private var pairedDevices: [Device] {
        return bluetoothManager.pairedDevices
    }
    
    private var discoveredDevices: [Device] {
        let pairedDeviceIds = bluetoothManager.getPairedDeviceIdentifiers()
        return bluetoothManager.pairedDevices.filter { peripheral in
            !pairedDeviceIds.contains(peripheral.identifier) && !bluetoothManager.isConnected(peripheral)
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
