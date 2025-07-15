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
internal class BluetoothManager: NSObject, ObservableObject {
    
    // MARK: - Bluetooth Central Connection States
    public enum BluetoothManagerState {
        case unknown
        case resetting
        case unsupported
        case unauthorized
        case poweredOff
        case poweredOn
    }
    
    public enum DeviceConnectionState {
        case disconnected
        case connecting
        case connected
        case disconnecting
        case validating
        case validationFailed
    }
    
    // MARK: - Peripheral Info
    
    /// Internal data structure used to encapsulate runtime meta information about a Device
    /// and it's current state within the manager
    struct PeripheralInfo {
        let peripheral: CBPeripheral
        var connectionState: DeviceConnectionState = .disconnected
        var isValidated: Bool = false
        var validationTimer: Timer?
        var validationState: ValidationState = .pending
        
        enum ValidationState {
            case pending
            case validating
            case valid
            case invalid
        }
    }
    
    // MARK: - Internal API Management
    private var pairingManager = DevicePairingManager()
    private var centralManager: CBCentralManager!
    internal var peripheralInfo: [UUID: PeripheralInfo] = [:]
    
    // MARK: - Published State
    @Published var bluetoothState: BluetoothManagerState = .unknown
    @Published var pairedDevices: [Device] = []
    @Published var receivedData: [String] = []
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
                peripheralInfo[peripheral.identifier] = PeripheralInfo(peripheral: peripheral)
            }
        }
        
        // Update the pairedDevices array with Device objects
        DispatchQueue.main.async {
            self.pairedDevices = pairedDevices
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
        os_log("Started scanning for peripherals")
    }
    
    func stopScanning() {
        centralManager.stopScan()
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
            peripheralInfo[peripheralIdentifier] = PeripheralInfo(peripheral: peripheral)
        }
        
        updateConnectionState(for: peripheral, state: .connecting)
        peripheralInfo[peripheralIdentifier]?.validationState = .validating
        
        // Start validation timer
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.handleValidationTimeout(for: peripheral)
        }
        peripheralInfo[peripheralIdentifier]?.validationTimer = timer
        
        centralManager.connect(peripheral, options: nil)
        os_log("Attempting to connect to %@", peripheral)
        pairingManager.pairDevice(peripheral)
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
    }
    
    func disconnectAll() {
        for device in pairedDevices {
            if getConnectionState(for: device) == .connected || getConnectionState(for: device) == .validating {
                disconnect(device)
            }
        }
    }
    
    func getPairedDeviceIdentifiers() -> Set<UUID> {
        return Set(pairedDevices.map { $0.identifier })
    }
    
    // MARK: - Connection State Management
    func getConnectionState(for device: Device) -> DeviceConnectionState {
        return peripheralInfo[device.identifier]?.connectionState ?? .disconnected
    }
    
    func getConnectionState(for peripheral: CBPeripheral) -> DeviceConnectionState {
        return peripheralInfo[peripheral.identifier]?.connectionState ?? .disconnected
    }
    
    func isConnected(_ device: Device) -> Bool {
        return getConnectionState(for: device) == .connected
    }
    
    func isConnected(_ peripheral: CBPeripheral) -> Bool {
        return getConnectionState(for: peripheral) == .connected
    }
    
    func isConnecting(_ device: Device) -> Bool {
        let state = getConnectionState(for: device)
        return state == .connecting || state == .validating
    }
    
    func isConnecting(_ peripheral: CBPeripheral) -> Bool {
        let state = getConnectionState(for: peripheral)
        return state == .connecting || state == .validating
    }
    
    // MARK: - Internal Helper Methods
    internal func addDiscoveredPeripheral(_ peripheral: CBPeripheral) {
        let peripheralIdentifier = peripheral.identifier
        guard peripheralInfo[peripheralIdentifier] == nil else { return }
        peripheralInfo[peripheralIdentifier] = PeripheralInfo(peripheral: peripheral)
    }
    
    internal func updateConnectionState(for peripheral: CBPeripheral, state: DeviceConnectionState) {
        DispatchQueue.main.async {
            self.peripheralInfo[peripheral.identifier]?.connectionState = state
        }
    }
    
    internal func handleValidationTimeout(for peripheral: CBPeripheral) {
        os_log("Validation timeout for peripheral: %@", peripheral)
        handleValidationResult(for: peripheral, isValid: false, reason: "timeout")
    }
    
    internal func handleValidationResult(for peripheral: CBPeripheral, isValid: Bool, reason: String = "") {
        guard var info = peripheralInfo[peripheral.identifier] else { return }
        
        info.validationTimer?.invalidate()
        info.validationState = isValid ? .valid : .invalid
        info.isValidated = isValid
        peripheralInfo[peripheral.identifier] = info
        
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
        }
    }
}
