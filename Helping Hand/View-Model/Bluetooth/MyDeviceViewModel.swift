//
//  MyDeviceViewModel.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/22/25.
//

import Foundation

extension MyDeviceView {
    
    @MainActor
    @Observable
    class ViewModel {
        
        let bluetoothManager = BluetoothManager.singleton
        
        // MARK: - State Variables
        var pairedDevices: [Device] {
            bluetoothManager.pairedDevices
        }
        
        var bluetoothState: BluetoothManagerState {
            bluetoothManager.bluetoothState
        }
        
        var isScanning: Bool {
            bluetoothManager.isScanning
        }
        
        var connectedDevices: [Device] {
            pairedDevices.filter { $0.connectionState == .connected }
        }
        
        var connectedDevicesCount: Int {
            connectedDevices.count
        }
        
        var connectAllEnabled: Bool {
            !pairedDevices.isEmpty && bluetoothState == .poweredOn
        }
        
        var disconnectAllEnabled: Bool {
            !connectedDevices.isEmpty && bluetoothState == .poweredOn
        }
        
        var pairEnabled: Bool {
            bluetoothState == .poweredOn
        }
        
        var updateAllEnabled: Bool {
            !connectedDevices.isEmpty && bluetoothState == .poweredOn
        }
        
        var hasConnectedDevices: Bool {
            connectedDevices.count > 0
        }
        
        var isConnectedAndPowered: Bool {
            hasConnectedDevices && bluetoothState == .poweredOn
        }
        
        var hasPairedAndPowered: Bool {
            pairedDevices.count > 0 && bluetoothState == .poweredOn
        }
        
        var hasActiveAndPowered: Bool {
            pairedDevices.filter{ $0.connectionState != .disconnected }.count > 0 && bluetoothState == .poweredOn
        }
        
        var receivedData: [String] {
            bluetoothManager.receivedData
        }
        
        // MARK: - Actions
        func toggleScanning() {
            bluetoothManager.isScanning ? bluetoothManager.stopScanning() : bluetoothManager.startScanning()
        }
        
        func loadPairedDevices() {
            Task {
                await bluetoothManager.loadPairedDevices()
            }
        }
        
        func connect(to device: Device) {
            bluetoothManager.connect(to: device)
        }
        
        func connectAllDevices() {
            for device in pairedDevices where device.connectionState == .disconnected {
                bluetoothManager.connect(to: device)
            }
        }
        
        func disconnectAll() {
            bluetoothManager.disconnectAll()
        }
        
        func getConnectionAction(for device: Device) -> () -> Void {
            switch(device.connectionState) {
            case .disconnected, .validationFailed:
                return {
                    self.connect(to: device)
                }
            case .connected, .connecting, .validating, .validated, .disconnecting:
                return {
                    self.bluetoothManager.disconnect(device)
                }
            }
        }
    }
}
