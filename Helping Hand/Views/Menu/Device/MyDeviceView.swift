//
//  MyDeviceView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/16/25.
//

import SwiftUI

import CoreBluetooth
import SwiftUI

// MARK: - Main Bluetooth View
struct BluetoothView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var selectedDevice: CBPeripheral?
    @State private var showingDeviceDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HeroStatusCard(
                        bluetoothState: bluetoothManager.bluetoothState,
                        connectedCount: connectedDevicesCount
                    )
                    
                    QuickActionsCard(
                        isScanning: bluetoothManager.isScanning,
                        bluetoothState: bluetoothManager.bluetoothState,
                        hasConnectedDevices: connectedDevicesCount > 0,
                        onScanToggle: toggleScanning,
                        onDisconnectAll: bluetoothManager.disconnectAll
                    )
                    
                    DeviceListCard(
                        title: "Connected Devices",
                        devices: connectedDevices,
                        emptyMessage: "No Connected Devices",
                        emptySubtitle: "Connect to paired devices or discover new ones",
                        showCount: true,
                        onDeviceSelect: nil,
                        connectionAction: bluetoothManager.disconnect,
                        connectionState: bluetoothManager.getConnectionState
                    )
                    
                    DeviceListCard(
                        title: "Paired Devices",
                        devices: pairedDevices,
                        emptyMessage: "No Paired Devices",
                        emptySubtitle: "Previously connected devices will appear here",
                        showCount: false,
                        onDeviceSelect: { device in
                            selectedDevice = device
                            showingDeviceDetail = true
                        },
                        connectionAction: bluetoothManager.connect,
                        connectionState: bluetoothManager.getConnectionState
                    )
                    
                    DeviceListCard(
                        title: "Discovered Devices",
                        devices: discoveredDevices,
                        emptyMessage: "No Devices Found",
                        emptySubtitle: bluetoothManager.isScanning ? "Searching for devices..." : "Tap 'Start Scanning' to discover devices",
                        showCount: false,
                        isScanning: bluetoothManager.isScanning,
                        onDeviceSelect: { device in
                            selectedDevice = device
                            showingDeviceDetail = true
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
            .background(AppStyle.backgroundGradient)
            .navigationTitle("Helping Hand")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingDeviceDetail) {
            if let device = selectedDevice {
                DeviceDetailView(device: device)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func toggleScanning() {
        bluetoothManager.isScanning ? bluetoothManager.stopScanning() : bluetoothManager.startScanning()
    }
    
    private var connectedDevices: [CBPeripheral] {
        bluetoothManager.discoveredPeripherals.filter(bluetoothManager.isConnected)
    }
    
    private var pairedDevices: [CBPeripheral] {
        let pairedDeviceIds = bluetoothManager.getPairedDeviceIdentifiers()
        return bluetoothManager.discoveredPeripherals.filter { peripheral in
            pairedDeviceIds.contains(peripheral.identifier)
        }
    }
    
    private var discoveredDevices: [CBPeripheral] {
        let pairedDeviceIds = bluetoothManager.getPairedDeviceIdentifiers()
        return bluetoothManager.discoveredPeripherals.filter { peripheral in
            !pairedDeviceIds.contains(peripheral.identifier) && !bluetoothManager.isConnected(peripheral)
        }
    }
    
    private var connectedDevicesCount: Int {
        connectedDevices.count
    }
}
