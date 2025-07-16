//
//  BluetoothManager.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/10/25.
//

import CoreBluetooth
import os

class BluetoothManagerSingleton {
    static let shared = BluetoothManager()
}

// MARK: - Bluetooth Manager
class BluetoothManager: NSObject, ObservableObject {
    
    // MARK: - Internal API Management
    private var pairingManager = DevicePairingManager()
    private var centralManager: CBCentralManager!
    
    // MARK: - Published State
    @Published var bluetoothState: BluetoothManagerState = .unknown
    @Published var pairedDevices: [Device] = []
    @Published var peripheralInfo: [UUID: Device] = [:]
    var receivedData: [String] = []
    @Published var isScanning = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        isScanning = centralManager.isScanning
        loadPairedDevices()
    }
    
    func loadPairedDevices() {
        let pairedDevices = pairingManager.getPairedDevicesList()
        
        // Retrieve peripherals using their identifiers
        let identifiers = pairedDevices.map { $0.identifier }
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        
        for peripheral in peripherals {
            if peripheralInfo[peripheral.identifier] == nil {
                peripheralInfo[peripheral.identifier] = Device(peripheral)
            }
        }
        
        // Update the pairedDevices array with Device objects
        DispatchQueue.main.async {
            self.pairedDevices = []
            self.pairedDevices.append(contentsOf: pairedDevices)
            self.objectWillChange.send()
        }
        
        os_log("Loaded %d paired devices", pairedDevices.count)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard bluetoothState == .poweredOn else { return }
        
        // Clear discovered peripherals but keep paired devices
        let pairedIdentifiers = Set(pairedDevices.map { $0.identifier })
        peripheralInfo = peripheralInfo.filter { pairedIdentifiers.contains($0.key) }
        centralManager.scanForPeripherals(withServices: CBUUIDs.serviceUUIDs)
        
        DispatchQueue.main.async {
            self.isScanning = true
            self.objectWillChange.send()
        }
        
        os_log("Started scanning for peripherals")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        
        DispatchQueue.main.async {
            self.isScanning = false
            self.objectWillChange.send()
        }
        
        os_log("Stopped scanning")
    }
    
    func connect(withIdentifier identifier: UUID) {
        let discoveredPeripherals = centralManager.retrievePeripherals(withIdentifiers: [identifier])
        
        if let peripheral = discoveredPeripherals.first {
            peripheral.delegate = self
            connect(to: peripheral)
        } else {
            os_log("Peripheral with identifier %@ not found.", identifier.uuidString)
        }
    }
    
    /// Wrapper abstraction to allow a Device model object to be read and connected to.
    ///
    func connect(to device: Device) {
        connect(withIdentifier: device.identifier)
    }
    
    internal func connect(to peripheral: CBPeripheral) {
        let peripheralIdentifier = peripheral.identifier
        
        if peripheralInfo[peripheralIdentifier] == nil {
            peripheralInfo[peripheralIdentifier] = Device(peripheral)
        }
        
        // Force immediate UI update
        updateConnectionState(for: peripheral, state: .connecting)
        updateDeviceConnectionState(for: peripheralIdentifier, state: .validating)
        
        // Start validation timer
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.handleValidationTimeout(for: peripheral)
        }
        updateDeviceValidationTimer(for: peripheralIdentifier, timer: timer)
        
        centralManager.connect(peripheral, options: nil)
        os_log("Attempting to connect to %@", peripheral)
        pairingManager.pairDevice(peripheral)
        
        // Force UI update for hero card and quick actions
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func disconnect(_ device: Device) {
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [device.identifier])
        if let peripheral = peripherals.first {
            disconnect(peripheral)
        }
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        guard let info = peripheralInfo[peripheral.identifier],
              info.connectionState == .connected || info.connectionState == .validating else { return }
        
        updateConnectionState(for: peripheral, state: .disconnecting)
        
        // Unsubscribe from notifications
        for service in (peripheral.services ?? []) {
            for characteristic in (service.characteristics ?? []) {
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        os_log("Disconnecting from %@", peripheral)
        centralManager.cancelPeripheralConnection(peripheral)
        
        // Force UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func disconnectAll() {
        for device in pairedDevices {
            guard let info = peripheralInfo[device.identifier] else { continue }
            disconnect(info)
        }
    }
    
    func getPairedDeviceIdentifiers() -> Set<UUID> {
        return Set(pairedDevices.map{ $0.identifier })
    }
    
    // MARK: - Device Access Methods
    /// Get a device that can be observed for UI updates
    func getObservableDevice(for identifier: UUID) -> Device? {
        return peripheralInfo[identifier]
    }
    
    /// Get the current connection state for a device
    func getConnectionState(for identifier: UUID) -> DeviceConnectionState {
        return peripheralInfo[identifier]?.connectionState ?? .disconnected
    }
    
    /// Check if a device is currently connected
    func isDeviceConnected(_ identifier: UUID) -> Bool {
        return peripheralInfo[identifier]?.connectionState == .connected
    }
    
    /// Get all devices (both paired and discovered) for hero card
    func getAllDevices() -> [Device] {
        return Array(peripheralInfo.values)
    }
    
    /// Get connected devices for quick actions
    func getConnectedDevices() -> [Device] {
        return peripheralInfo.values.filter { $0.connectionState == .connected }
    }
    
    /// Get discovered devices (not paired)
    func getDiscoveredDevices() -> [Device] {
        let pairedIdentifiers = Set(pairedDevices.map { $0.identifier })
        return peripheralInfo.values.filter { !pairedIdentifiers.contains($0.identifier) }
    }
    
    // MARK: - Internal Helper Methods
    internal func addDiscoveredPeripheral(_ peripheral: CBPeripheral) {
        let peripheralIdentifier = peripheral.identifier
        guard peripheralInfo[peripheralIdentifier] == nil else { return }
        
        DispatchQueue.main.async {
            self.peripheralInfo[peripheralIdentifier] = Device(peripheral)
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Enhanced Update Methods
    private func updateDeviceInBothStructures(identifier: UUID, updateBlock: @escaping (inout Device) -> Void) {
        DispatchQueue.main.async {
            // Update peripheralInfo first
            if var device = self.peripheralInfo[identifier] {
                updateBlock(&device)
                self.peripheralInfo[identifier] = device
            }
            
            // Update pairedDevices array
            if let index = self.pairedDevices.firstIndex(where: { $0.identifier == identifier }) {
                var device = self.pairedDevices[index]
                updateBlock(&device)
                self.pairedDevices[index] = device
            }
            
            // Force UI update
            self.objectWillChange.send()
        }
    }
    
    internal func updateConnectionState(for peripheral: CBPeripheral, state: DeviceConnectionState) {
        let identifier = peripheral.identifier
        
        updateDeviceInBothStructures(identifier: identifier) { device in
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
    
    internal func updateDeviceValidationTimer(for identifier: UUID, timer: Timer) {
        updateDeviceInBothStructures(identifier: identifier) { device in
            device.validationTimer = timer
        }
    }
    
    internal func handleValidationTimeout(for peripheral: CBPeripheral) {
        os_log("Validation timeout for peripheral: %@", peripheral)
        handleValidationResult(for: peripheral, isValid: false, reason: "timeout")
    }
    
    internal func handleValidationResult(for peripheral: CBPeripheral, isValid: Bool, reason: String = "") {
        let identifier = peripheral.identifier
        guard var info = peripheralInfo[identifier] else { return }
        
        info.validationTimer?.invalidate()
        info.connectionState = isValid ? .validated : .validationFailed
        
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
        let dataEntry: String
        
        if let stringData = String(data: data, encoding: .utf8) {
            dataEntry = "[\(timestamp)] \(stringData)"
            os_log("Received string data: %@", stringData)
        } else {
            let hexString = data.map { String(format: "%02hhx", $0) }.joined()
            dataEntry = "[\(timestamp)] HEX: \(hexString)"
            os_log("Received binary data: %@", hexString)
        }
        
        DispatchQueue.main.async {
            self.receivedData.append(dataEntry)
            
            // Keep only last 50 entries
            if self.receivedData.count > 50 {
                self.receivedData.removeFirst()
            }
            
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Convenience Methods for UI
    /// Force refresh of all UI components
    func forceUIUpdate() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    /// Update last seen timestamp for a device
    func updateLastSeen(for identifier: UUID) {
        updateDeviceInBothStructures(identifier: identifier) { device in
            device.lastSeen = Date()
        }
    }
    
    /// Get devices by connection state
    func getDevices(byState state: DeviceConnectionState) -> [Device] {
        return peripheralInfo.values.filter { $0.connectionState == state }
    }
    
    /// Check if any device is connecting
    func hasConnectingDevices() -> Bool {
        return peripheralInfo.values.contains {
            $0.connectionState == .connecting || $0.connectionState == .validating
        }
    }
}
