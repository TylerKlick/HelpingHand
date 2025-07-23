//
//  BluetoothManager.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/10/25.
//

import CoreBluetooth
import os

// MARK: - Bluetooth Manager
@Observable
internal class BluetoothManager: NSObject, ObservableObject {
    
    /// Singleton instance to be shared among all utilizing views and classes
    static let singleton = BluetoothManager()
    
    // MARK: - Properties
    private var pairingManager = DevicePairingManager()
    private var centralManager: CBCentralManager!
    
    var bluetoothState: BluetoothManagerState = .unknown
    var pairedDevices: [Device] = []
    var peripheralInfo: [UUID: Device] = [:]
    var isScanning = false
    
    var receivedData: [String] = []
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        isScanning = centralManager.isScanning
        loadPairedDevices()
    }
    
    // MARK: - Device Management
    func loadPairedDevices() {
        let pairedDevices = pairingManager.getPairedDevicesList()
        let identifiers = pairedDevices.map { $0.identifier }
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        
        for peripheral in peripherals {
            peripheralInfo[peripheral.identifier] = peripheralInfo[peripheral.identifier] ?? Device(peripheral)
        }
        
        DispatchQueue.main.async {
            self.pairedDevices = pairedDevices
        }
        
        os_log("Loaded %d paired devices", pairedDevices.count)
    }
    
    // MARK: - Scanning
    func startScanning() {
        guard bluetoothState == .poweredOn else { return }
        
        let pairedIdentifiers = Set(pairedDevices.map { $0.identifier })
        peripheralInfo = peripheralInfo.filter { pairedIdentifiers.contains($0.key) }
        centralManager.scanForPeripherals(withServices: CBUUIDs.serviceUUIDs)
        
        DispatchQueue.main.async { self.isScanning = true }
        os_log("Started scanning for peripherals")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        DispatchQueue.main.async { self.isScanning = false }
        os_log("Stopped scanning")
    }
    
    // MARK: - Connection Management
    func connect(withIdentifier identifier: UUID) {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [identifier]).first else {
            os_log("Peripheral with identifier %@ not found.", identifier.uuidString)
            return
        }
        
        peripheral.delegate = self
        connect(to: peripheral)
    }
    
    func connect(to device: Device) {
        connect(withIdentifier: device.identifier)
    }
    
    internal func connect(to peripheral: CBPeripheral) {
        let identifier = peripheral.identifier
        
        peripheralInfo[identifier] = peripheralInfo[identifier] ?? Device(peripheral)
        
        updateConnectionState(for: peripheral, state: .connecting)
        
        startValidationTimer(for: peripheral)
        
        centralManager.connect(peripheral, options: nil)
        pairingManager.pairDevice(peripheral)
        
        os_log("Attempting to connect to %@", peripheral)
    }
    
    func disconnect(_ device: Device) {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [device.identifier]).first else { return }
        disconnect(peripheral)
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        guard let info = peripheralInfo[peripheral.identifier],
              info.connectionState != .disconnected else { return }
        
        os_log("Disconnecting from %@", peripheral)
        updateConnectionState(for: peripheral, state: .disconnecting)
        unsubscribeFromNotifications(peripheral)
        centralManager.cancelPeripheralConnection(peripheral)
        updateConnectionState(for: peripheral, state: .disconnected)
    }
    
    func disconnectAll() {
        pairedDevices.forEach { device in
            guard peripheralInfo[device.identifier] != nil else { return }
            disconnect(device)
        }
    }
    
    // MARK: - Internal Helpers
    internal func addDiscoveredPeripheral(_ peripheral: CBPeripheral) {
        guard peripheralInfo[peripheral.identifier] == nil else { return }
        
        DispatchQueue.main.async {
            self.peripheralInfo[peripheral.identifier] = Device(peripheral)
        }
    }
    
    /// Helper block to reduce boilerplate operations and ensure dependent Views receive an update signal
    private func updateDeviceInBothStructures(identifier: UUID, updateBlock: @escaping (inout Device) -> Void) {
        DispatchQueue.main.async {
            if var device = self.peripheralInfo[identifier] {
                updateBlock(&device)
                self.peripheralInfo[identifier] = device
            }
            
            if let index = self.pairedDevices.firstIndex(where: { $0.identifier == identifier }) {
                updateBlock(&self.pairedDevices[index])
            }
        }
    }
    
    internal func updateConnectionState(for peripheral: CBPeripheral, state: DeviceConnectionState) {
        updateDeviceInBothStructures(identifier: peripheral.identifier) { device in
            device.connectionState = state
        }
        os_log("Updated connection state for %@ to %@", peripheral, String(describing: state))
    }
    
    internal func updateDeviceConnectionState(for identifier: UUID, state: DeviceConnectionState) {
        updateDeviceInBothStructures(identifier: identifier) { device in
            device.connectionState = state
        }
        os_log("Updated connection state for device %@ to %@", identifier.uuidString, String(describing: state))
    }
    
    private func startValidationTimer(for peripheral: CBPeripheral) {
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.handleValidationTimeout(for: peripheral)
        }
        
        updateDeviceInBothStructures(identifier: peripheral.identifier) { device in
            device.validationTimer = timer
        }
    }
    
    private func handleValidationTimeout(for peripheral: CBPeripheral) {
        os_log("Validation timeout for peripheral: %@", peripheral)
        handleValidationResult(for: peripheral, isValid: false, reason: "timeout")
    }
    
    internal func handleValidationResult(for peripheral: CBPeripheral, isValid: Bool, reason: String = "") {
        let identifier = peripheral.identifier
        
        updateDeviceInBothStructures(identifier: identifier) { device in
            device.validationTimer?.invalidate()
            device.validationTimer = nil
            device.connectionState = isValid ? .validated : .validationFailed
        }
        
        let resultText = isValid ? "successful" : "failed"
        os_log("Peripheral validation %@: %@ %@", resultText, peripheral, reason)
        
        if isValid {
            updateConnectionState(for: peripheral, state: .connected)
        } else {
            updateConnectionState(for: peripheral, state: .validationFailed)
            disconnect(peripheral)
        }
    }
    
    internal func processReceivedData(_ data: Data, from characteristic: CBCharacteristic) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let dataEntry = createDataEntry(data, timestamp: timestamp)
        
        DispatchQueue.main.async {
            self.receivedData.append(dataEntry)
            if self.receivedData.count > 50 {
                self.receivedData.removeFirst()
            }
        }
    }
    
    private func createDataEntry(_ data: Data, timestamp: String) -> String {
        if let stringData = String(data: data, encoding: .utf8) {
            os_log("Received string data: %@", stringData)
            return "[\(timestamp)] \(stringData)"
        } else {
            let hexString = data.map { String(format: "%02hhx", $0) }.joined()
            os_log("Received binary data: %@", hexString)
            return "[\(timestamp)] HEX: \(hexString)"
        }
    }
    
    private func unsubscribeFromNotifications(_ peripheral: CBPeripheral) {
        peripheral.services?.forEach { service in
            service.characteristics?.forEach { characteristic in
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
    }
}
