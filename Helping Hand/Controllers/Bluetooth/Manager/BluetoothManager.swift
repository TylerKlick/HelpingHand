//
//  BluetoothManager.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/10/25.
//

import SwiftUI
import CoreBluetooth
import os

// MARK: - Bluetooth Manager
class BluetoothManager: NSObject, ObservableObject {
    
    // MARK: - States
    enum ConnectionState {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }
    
    // MARK: - Peripheral Info
    struct PeripheralInfo {
        let peripheral: CBPeripheral
        var validationState: ValidationState = .validating
        var validationTimer: Timer?
        var isMainConnection: Bool = false
        
        var isValidated: Bool {
            return validationState == .valid
        }
        
        /// Current phase of asynchronous validation
        enum ValidationState {
            case validating
            case valid
            case invalid
        }
    }
    
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var connectionState: ConnectionState = .disconnected
    @Published var validatedPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var receivedData: [String] = []
    @Published var isScanning = false
    
    private var centralManager: CBCentralManager!
    internal var scannedPeripherals: [CBPeripheral: PeripheralInfo] = [:]
    internal var mainPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard bluetoothState == .poweredOn else { return }
    
        clearPeripheralInfo(true)
        isScanning = true
        centralManager.scanForPeripherals(withServices: CBUUIDs.serviceUUIDs)
        os_log("Started scanning for peripherals")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        clearPeripheralInfo()
        os_log("Stopped scanning")
    }
    
    func connect(to peripheral: CBPeripheral) {
        connectionState = .connecting
        centralManager.connect(peripheral, options: nil)
        mainPeripheral = peripheral
        scannedPeripherals[peripheral]?.isMainConnection = true
        os_log("Attempting to connect to %@", peripheral)
    }
    
    // MARK: - Private Methods
    
    /// Cleans current connection state, unsubscribing from all characteristics and disconnecting.
    internal func disconnect(_ peripheral: CBPeripheral? = nil) {
        let targetPeripheral = peripheral ?? mainPeripheral
        guard let peripheral = targetPeripheral,
              case .connected = peripheral.state else {
            connectionState = .disconnected
            return
        }
        
        connectionState = .disconnecting
        
        // Unsubscribe from notifications
        for service in (peripheral.services ?? []) {
            for characteristic in (service.characteristics ?? []) {
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        centralManager.cancelPeripheralConnection(peripheral)
        mainPeripheral = nil
        connectedPeripheral = nil
        connectionState = .disconnected
    }
    
    internal func clearPeripheralInfo(_ clearAll: Bool = false) {
        if clearAll { validatedPeripherals.removeAll() }
        scannedPeripherals.values.forEach { $0.validationTimer?.invalidate() }
        scannedPeripherals.removeAll()
    }
    
    internal func startValidation(for peripheral: CBPeripheral) {
        guard scannedPeripherals[peripheral] == nil else { return }
        
        os_log("Starting validation for peripheral: %@", peripheral)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.handleValidationResult(for: peripheral, isValid: false, reason: "timeout")
        }
        
        scannedPeripherals[peripheral] = PeripheralInfo(
            peripheral: peripheral,
            validationState: .validating,
            validationTimer: timer
        )
        
        // Start looking at characteristics by initiating connection
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    internal func handleValidationResult(for peripheral: CBPeripheral, isValid: Bool, reason: String = "") {
        guard var info = scannedPeripherals[peripheral] else { return }
        
        info.validationTimer?.invalidate()
        info.validationState = isValid ? .valid : .invalid
        scannedPeripherals[peripheral] = info
        
        let resultText = isValid ? "successful" : "failed"
        os_log("Peripheral validation %@: %@ %@", resultText, peripheral, reason)
        
        if isValid {
            DispatchQueue.main.async {
                if !self.validatedPeripherals.contains(peripheral) {
                    self.validatedPeripherals.append(peripheral)
                }
            }
        }
        
        // Disconnect validation connections
        disconnect(peripheral)
    }
    
    internal func isValidationConnection(_ peripheral: CBPeripheral) -> Bool {
        return scannedPeripherals[peripheral]?.isMainConnection == false
    }
    
    internal func handleConnectionError(for peripheral: CBPeripheral, error: Error? = nil) {
        if let error = error {
            os_log("Connection error for %@: %@", peripheral, error.localizedDescription)
        }
        
        if isValidationConnection(peripheral) {
            handleValidationResult(for: peripheral, isValid: false, reason: "connection failed")
        } else if peripheral == mainPeripheral {
            disconnect()
            connectionState = .disconnected
        }
    }
    
    internal func handleServiceDiscoveryError(for peripheral: CBPeripheral, error: Error? = nil) {
        if let error = error {
            os_log("Service discovery error: %@", error.localizedDescription)
        }
        
        if isValidationConnection(peripheral) {
            handleValidationResult(for: peripheral, isValid: false, reason: "service discovery failed")
        } else if peripheral == mainPeripheral {
            disconnect()
        }
    }
    
    internal func validateServicesAndCharacteristics(for peripheral: CBPeripheral) -> Bool {
        guard let services = peripheral.services else { return false }
        
        let expectedServices = CBUUIDs.serviceUUIDs
        let foundServices = services.map { $0.uuid }
        
        // Check all required services are present
        guard expectedServices.allSatisfy({ foundServices.contains($0) }) else {
            return false
        }
        
        // Check all required characteristics are present
        for service in services {
            guard let characteristics = service.characteristics else { return false }
            
            let expectedCharacteristics = CBUUIDs.characteristicUUIDs(for: service.uuid)
            let foundCharacteristics = characteristics.map { $0.uuid }
            
            guard expectedCharacteristics.allSatisfy({ foundCharacteristics.contains($0) }) else {
                return false
            }
        }
        
        return true
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
    
    internal func setupCharacteristics(for peripheral: CBPeripheral) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            guard let characteristics = service.characteristics else { continue }
            
            for characteristic in characteristics {
                guard let spec = CBUUIDs.characteristicSpec(for: characteristic.uuid) else { continue }
                
                for property in spec.properties {
                    switch property {
                    case .notify:
                        peripheral.setNotifyValue(true, for: characteristic)
                        os_log("Subscribed to notifications for %@", characteristic.uuid.uuidString)
                    case .read:
                        peripheral.readValue(for: characteristic)
                        os_log("Reading value for %@", characteristic.uuid.uuidString)
                    case .write:
                        os_log("Found writable characteristic %@", characteristic.uuid.uuidString)
                    }
                }
            }
        }
    }
}
