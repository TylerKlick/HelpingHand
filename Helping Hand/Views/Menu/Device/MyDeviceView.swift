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
    @StateObject private var bluetoothManager = BluetoothManagerSingleton.shared
    @State private var selectedDevice: CBPeripheral?
    @State private var showingDeviceDetail = false
    
    var body: some View {
        ZStack {
            // Background layer - you can customize this
            Color.clear
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Header
                CustomNavigationHeader(title: "Helping Hand")
                
                // Main Content
                ScrollView {
                    VStack(spacing: 16) {
                        HeroStatusCard(
                            bluetoothState: bluetoothManager.bluetoothState,
                            connectedCount: connectedDevicesCount
                        )

                        
                        QuickActionsCard(
                            isScanning: true,
                            bluetoothState: .poweredOn,
                            hasConnectedDevices: true,
                            onScanToggle: { /* action */ },
                            onDisconnectAll: { /* action */ },
                            onPair: {},
                            onConnectAll: {},
                            onUpdateAll: {}
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
        .sheet(isPresented: $showingDeviceDetail) {
            if let device = selectedDevice {
                DeviceDetailView(device: device)
            }
        }
        .onAppear() {
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
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
            
            // Optional: Add navigation buttons here if needed
            // Button("Settings") { }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.clear)
    }
}
