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
    
    // MARK: - States
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case disconnecting
        case validating
        case validationFailed
    }
    
    // MARK: - Peripheral Info
    struct PeripheralInfo {
        let peripheral: CBPeripheral
        var connectionState: ConnectionState = .disconnected
        var isValidated: Bool = false
        var validationTimer: Timer?
        
        enum ValidationState {
            case pending
            case validating
            case valid
            case invalid
        }
        var validationState: ValidationState = .pending
    }
    
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var peripheralConnectionStates: [CBPeripheral: ConnectionState] = [:]
    @Published var receivedData: [String] = []
    @Published var isScanning = false
    
    private var pairingManager = DevicePairingManager()
    private var centralManager: CBCentralManager!
    internal var peripheralInfo: [CBPeripheral: PeripheralInfo] = [:]
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        loadPairedDevices()
    }
    
    func loadPairedDevices() {
        guard bluetoothState == .poweredOn else { return }
        
        let pairedDevices = pairingManager.getPairedDevicesList()
        
        // Retrieve peripherals using their identifiers
        let identifiers = pairedDevices.map { $0.identifier }
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: identifiers)
        
        for peripheral in peripherals {
            // Set up peripheral info
            if peripheralInfo[peripheral] == nil {
                peripheralInfo[peripheral] = PeripheralInfo(peripheral: peripheral)
                updateConnectionState(for: peripheral, state: .disconnected)
            }
            
            // Update last seen for paired device
            pairingManager.updateLastSeen(peripheral)
            
            // Add to discovered peripherals if not already there
            DispatchQueue.main.async {
                if !self.discoveredPeripherals.contains(peripheral) {
                    self.discoveredPeripherals.append(peripheral)
                }
            }
        }
        
        os_log("Loaded %d paired devices", peripherals.count)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard bluetoothState == .poweredOn else { return }
        
        discoveredPeripherals.removeAll()
        peripheralInfo.removeAll()
        peripheralConnectionStates.removeAll()
        isScanning = true
        centralManager.scanForPeripherals(withServices: CBUUIDs.serviceUUIDs)
        os_log("Started scanning for peripherals")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        os_log("Stopped scanning")
    }
    
    func connect(to peripheral: CBPeripheral) {
        guard peripheralInfo[peripheral] != nil else { return }
        
        updateConnectionState(for: peripheral, state: .connecting)
        peripheralInfo[peripheral]?.validationState = .validating
        
        // Start validation timer
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.handleValidationTimeout(for: peripheral)
        }
        peripheralInfo[peripheral]?.validationTimer = timer
        
        centralManager.connect(peripheral, options: nil)
        os_log("Attempting to connect to %@", peripheral)
        
        pairingManager.pairDevice(peripheral)
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        guard let info = peripheralInfo[peripheral],
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
        for (peripheral, state) in peripheralConnectionStates {
            if state == .connected || state == .validating {
                disconnect(peripheral)
            }
        }
    }
    
    func getPairedDeviceIdentifiers() -> Set<UUID> {
        let pairedDevices = pairingManager.getPairedDevicesList()
        return Set(pairedDevices.map { $0.identifier })
    }
    
    // MARK: - Connection State Management
    func getConnectionState(for peripheral: CBPeripheral) -> ConnectionState {
        return peripheralConnectionStates[peripheral] ?? .disconnected
    }
    
    func isConnected(_ peripheral: CBPeripheral) -> Bool {
        return getConnectionState(for: peripheral) == .connected
    }
    
    func isConnecting(_ peripheral: CBPeripheral) -> Bool {
        let state = getConnectionState(for: peripheral)
        return state == .connecting || state == .validating
    }
    
    // MARK: - Internal Helper Methods
    internal func addDiscoveredPeripheral(_ peripheral: CBPeripheral) {
        guard peripheralInfo[peripheral] == nil else { return }
        
        peripheralInfo[peripheral] = PeripheralInfo(peripheral: peripheral)
        updateConnectionState(for: peripheral, state: .disconnected)
        
        DispatchQueue.main.async {
            if !self.discoveredPeripherals.contains(peripheral) {
                self.discoveredPeripherals.append(peripheral)
            }
        }
    }
    
    internal func updateConnectionState(for peripheral: CBPeripheral, state: ConnectionState) {
        peripheralInfo[peripheral]?.connectionState = state
        
        DispatchQueue.main.async {
            self.peripheralConnectionStates[peripheral] = state
        }
    }
    
    internal func handleValidationTimeout(for peripheral: CBPeripheral) {
        os_log("Validation timeout for peripheral: %@", peripheral)
        handleValidationResult(for: peripheral, isValid: false, reason: "timeout")
    }
    
    internal func handleValidationResult(for peripheral: CBPeripheral, isValid: Bool, reason: String = "") {
        guard var info = peripheralInfo[peripheral] else { return }
        
        info.validationTimer?.invalidate()
        info.validationState = isValid ? .valid : .invalid
        info.isValidated = isValid
        peripheralInfo[peripheral] = info
        
        let resultText = isValid ? "successful" : "failed"
        os_log("Peripheral validation %@: %@ %@", resultText, peripheral, reason)
        
        if isValid {
            updateConnectionState(for: peripheral, state: .connected)
        } else {
            updateConnectionState(for: peripheral, state: .validationFailed)
            // Disconnect invalid peripheral
            centralManager.cancelPeripheralConnection(peripheral)
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
