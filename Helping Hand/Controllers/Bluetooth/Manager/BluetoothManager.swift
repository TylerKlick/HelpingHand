////
////  BluetoothManager.swift
////  Helping Hand
////
////  Created by Tyler Klick on 7/10/25.
////
//
//import SwiftUI
//import CoreBluetooth
//import os
//
//// MARK: - Bluetooth Manager State
//enum ConnectionState {
//    case disconnected
//    case connecting
//    case connected
//    case disconnecting
//}
//
//// MARK: - Validation State
//enum ValidationState {
//    case pending
//    case validating
//    case valid
//    case invalid
//}
//
//// MARK: - Peripheral Validation Info
//struct PeripheralValidationInfo {
//    let peripheral: CBPeripheral
//    var validationState: ValidationState = .pending
//    var discoveredServices: [CBService] = []
//    var validatedCharacteristics: [CBUUID: [CBCharacteristic]] = [:]
//    
//    var isFullyValidated: Bool {
//        return validationState == .valid
//    }
//}
//
//// MARK: - Bluetooth Manager Observable Object
///// Wrapper class to handle the storage and state representation of Peripheral objects and their respective data transfers
//class BluetoothManager: NSObject, ObservableObject {
//    
//    @Published var bluetoothState: CBManagerState = .unknown
//    @Published var connectionState: ConnectionState = .disconnected
//    @Published var validatedPeripherals: [CBPeripheral] = []
//    @Published var connectedPeripheral: CBPeripheral?
//    @Published var receivedData: [String] = []
//    @Published var isScanning = false
//    
//    internal var centralManager: CBCentralManager!
//    internal var peripheral: CBPeripheral?
//    internal var likelyPeripheralArray: [CBPeripheral] = []
//    internal var rssiArray = [NSNumber]()
//    internal var timer = Timer()
//    
//    // Track validation state for discovered peripherals
//    private var validationInfo: [CBPeripheral: PeripheralValidationInfo] = [:]
//    private var validationTimeouts: [CBPeripheral: Timer] = [:]
//    
//    override init() {
//        super.init()
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//    }
//    
//    // MARK: - Public Methods
//    func startScanning() {
//        guard bluetoothState == .poweredOn else { return }
//        
//        likelyPeripheralArray.removeAll()
//        validatedPeripherals.removeAll()
//        validationInfo.removeAll()
//        clearValidationTimeouts()
//        isScanning = true
//        centralManager.scanForPeripherals(withServices: CBUUIDs.serviceUUIDs)
//        os_log("Started scanning for peripherals")
//    }
//    
//    func stopScanning() {
//        centralManager.stopScan()
//        isScanning = false
//        clearValidationTimeouts()
//        os_log("Stopped scanning")
//    }
//    
//    /// Initialtes connection to Peripheral
//    ///
//    /// - Parameters:
//    ///     - peripheral: Device to initiate connection with
//    func connect(to peripheral: CBPeripheral) {
//        connectionState = .connecting
//        self.peripheral = peripheral
//        centralManager.connect(peripheral, options: nil)
//        os_log("Attempting to connect to %@", peripheral)
//    }
//    
//    /// Disconnects from the currently connected peripheral and cleans up for a new connection.
//    func disconnect() {
//        cleanup()
//    }
//    
//    func retrieveConnectedPeripherals() {
//        let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: CBUUIDs.serviceUUIDs)
//        
//        os_log("Found connected Peripherals with required services: %@", connectedPeripherals)
//        
//        if let connectedPeripheral = connectedPeripherals.last {
//            os_log("Connecting to peripheral %@", connectedPeripheral)
//            self.peripheral = connectedPeripheral
//            connectedPeripheral.delegate = self
//            centralManager.connect(connectedPeripheral, options: nil)
//        } else {
//            startScanning()
//        }
//    }
//    
//    // MARK: - Helper Methods
//    internal func cleanup() {
//        guard let peripheral = self.peripheral,
//              case .connected = peripheral.state else {
//            connectionState = .disconnected
//            return
//        }
//        
//        connectionState = .disconnecting
//        
//        for service in (peripheral.services ?? [] as [CBService]) {
//            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
//                if characteristic.isNotifying {
//                    peripheral.setNotifyValue(false, for: characteristic)
//                }
//            }
//        }
//        
//        centralManager.cancelPeripheralConnection(peripheral)
//        self.peripheral = nil
//        connectedPeripheral = nil
//        connectionState = .disconnected
//    }
//    
//    internal func updateBluetoothState(from state: CBManagerState) {
//        self.bluetoothState = state
//    }
//    
//    // MARK: - Validation Methods
//    internal func startValidation(for peripheral: CBPeripheral) {
//        guard validationInfo[peripheral] == nil else { return }
//        
//        os_log("Starting validation for peripheral: %@", peripheral)
//        
//        var info = PeripheralValidationInfo(peripheral: peripheral)
//        info.validationState = .validating
//        validationInfo[peripheral] = info
//        
//        peripheral.delegate = self
//        
//        // Set a timeout for validation
//        let timeout = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
//            self?.validationTimeout(for: peripheral)
//        }
//        validationTimeouts[peripheral] = timeout
//        
//        // Connect temporarily for validation
//        centralManager.connect(peripheral, options: nil)
//    }
//    
//    internal func validationTimeout(for peripheral: CBPeripheral) {
//        os_log("Validation timeout for peripheral: %@", peripheral)
//        validationInfo[peripheral]?.validationState = .invalid
//        validationTimeouts[peripheral]?.invalidate()
//        validationTimeouts.removeValue(forKey: peripheral)
//        
//        // Disconnect if we're connected to this peripheral for validation
//        if peripheral.state == .connected && self.peripheral != peripheral {
//            centralManager.cancelPeripheralConnection(peripheral)
//        }
//    }
//    
//    internal func completeValidation(for peripheral: CBPeripheral, isValid: Bool) {
//        guard var info = validationInfo[peripheral] else { return }
//        
//        info.validationState = isValid ? .valid : .invalid
//        validationInfo[peripheral] = info
//        
//        // Cancel timeout
//        validationTimeouts[peripheral]?.invalidate()
//        validationTimeouts.removeValue(forKey: peripheral)
//        
//        if isValid {
//            os_log("Peripheral validation successful: %@", peripheral)
//            DispatchQueue.main.async {
//                if !self.validatedPeripherals.contains(peripheral) {
//                    self.validatedPeripherals.append(peripheral)
//                }
//            }
//        } else {
//            os_log("Peripheral validation failed: %@", peripheral)
//        }
//        
//        // Disconnect if we're connected to this peripheral for validation only
//        if peripheral.state == .connected && self.peripheral != peripheral {
//            centralManager.cancelPeripheralConnection(peripheral)
//        }
//    }
//    
//    internal func clearValidationTimeouts() {
//        validationTimeouts.values.forEach { $0.invalidate() }
//        validationTimeouts.removeAll()
//    }
//    
//    internal func validateServices(for peripheral: CBPeripheral) -> Bool {
//        guard let peripheralServices = peripheral.services else { return false }
//        
//        let expectedServices = CBUUIDs.serviceUUIDs
//        let foundServices = peripheralServices.map { $0.uuid }
//        
//        // Check if all expected services are present
//        let missingServices = expectedServices.filter { !foundServices.contains($0) }
//        
//        if !missingServices.isEmpty {
//            os_log("Peripheral missing required services: %@", missingServices.map { $0.uuidString })
//            return false
//        }
//        
//        return true
//    }
//    
//    internal func validateCharacteristics(for peripheral: CBPeripheral, service: CBService) -> Bool {
//        guard let serviceCharacteristics = service.characteristics else { return false }
//        
//        let expectedCharacteristics = CBUUIDs.characteristicUUIDs(for: service.uuid)
//        let foundCharacteristics = serviceCharacteristics.map { $0.uuid }
//        
//        // Check if all expected characteristics are present
//        let missingCharacteristics = expectedCharacteristics.filter { !foundCharacteristics.contains($0) }
//        
//        if !missingCharacteristics.isEmpty {
//            os_log("Service %@ missing required characteristics: %@", service.uuid.uuidString, missingCharacteristics.map { $0.uuidString })
//            return false
//        }
//        
//        return true
//    }
//    
//    internal func checkIfFullyValidated(peripheral: CBPeripheral) {
//        guard let info = validationInfo[peripheral] else { return }
//        
//        // Check if we have all required services
//        let expectedServices = CBUUIDs.serviceUUIDs
//        let discoveredServiceUUIDs = info.discoveredServices.map { $0.uuid }
//        
//        let hasAllServices = expectedServices.allSatisfy { discoveredServiceUUIDs.contains($0) }
//        
//        if !hasAllServices {
//            completeValidation(for: peripheral, isValid: false)
//            return
//        }
//        
//        // Check if we have validated all characteristics for all services
//        let hasAllCharacteristics = info.discoveredServices.allSatisfy { service in
//            let expectedCharacteristics = CBUUIDs.characteristicUUIDs(for: service.uuid)
//            guard let validatedCharacteristics = info.validatedCharacteristics[service.uuid] else { return false }
//            let validatedCharacteristicUUIDs = validatedCharacteristics.map { $0.uuid }
//            return expectedCharacteristics.allSatisfy { validatedCharacteristicUUIDs.contains($0) }
//        }
//        
//        completeValidation(for: peripheral, isValid: hasAllCharacteristics)
//    }
//}

//
//  BluetoothManager.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/10/25.
//

import SwiftUI
import CoreBluetooth
import os

// MARK: - States
enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

enum ValidationState {
    case validating
    case valid
    case invalid
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
}

// MARK: - Bluetooth Manager
class BluetoothManager: NSObject, ObservableObject {
    
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var connectionState: ConnectionState = .disconnected
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var receivedData: [String] = []
    @Published var isScanning = false
    
    private var centralManager: CBCentralManager!
    private var peripheralInfo: [CBPeripheral: PeripheralInfo] = [:]
    private var mainPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard bluetoothState == .poweredOn else { return }
        
        discoveredPeripherals.removeAll()
        clearPeripheralInfo()
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
        mainPeripheral = peripheral
        peripheralInfo[peripheral]?.isMainConnection = true
        centralManager.connect(peripheral, options: nil)
        os_log("Attempting to connect to %@", peripheral)
    }
    
    func disconnect() {
        cleanup()
    }
    
    func retrieveConnectedPeripherals() {
        let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: CBUUIDs.serviceUUIDs)
        
        if let connectedPeripheral = connectedPeripherals.last {
            os_log("Connecting to existing peripheral %@", connectedPeripheral)
            connect(to: connectedPeripheral)
        } else {
            startScanning()
        }
    }
    
    // MARK: - Private Methods
    private func cleanup() {
        guard let peripheral = mainPeripheral,
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
    
    private func clearPeripheralInfo() {
        peripheralInfo.values.forEach { $0.validationTimer?.invalidate() }
        peripheralInfo.removeAll()
    }
    
    private func startValidation(for peripheral: CBPeripheral) {
        guard peripheralInfo[peripheral] == nil else { return }
        
        os_log("Starting validation for peripheral: %@", peripheral)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.handleValidationResult(for: peripheral, isValid: false, reason: "timeout")
        }
        
        peripheralInfo[peripheral] = PeripheralInfo(
            peripheral: peripheral,
            validationState: .validating,
            validationTimer: timer
        )
        
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    private func handleValidationResult(for peripheral: CBPeripheral, isValid: Bool, reason: String = "") {
        guard var info = peripheralInfo[peripheral] else { return }
        
        info.validationTimer?.invalidate()
        info.validationState = isValid ? .valid : .invalid
        peripheralInfo[peripheral] = info
        
        let resultText = isValid ? "successful" : "failed"
        os_log("Peripheral validation %@: %@ %@", resultText, peripheral, reason)
        
        if isValid {
            DispatchQueue.main.async {
                if !self.discoveredPeripherals.contains(peripheral) {
                    self.discoveredPeripherals.append(peripheral)
                }
            }
        }
        
        // Disconnect validation connections
        if !info.isMainConnection && peripheral.state == .connected {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    private func isValidationConnection(_ peripheral: CBPeripheral) -> Bool {
        return peripheralInfo[peripheral]?.isMainConnection == false
    }
    
    private func handleConnectionError(for peripheral: CBPeripheral, error: Error? = nil) {
        if let error = error {
            os_log("Connection error for %@: %@", peripheral, error.localizedDescription)
        }
        
        if isValidationConnection(peripheral) {
            handleValidationResult(for: peripheral, isValid: false, reason: "connection failed")
        } else if peripheral == mainPeripheral {
            connectionState = .disconnected
            cleanup()
        }
    }
    
    private func handleServiceDiscoveryError(for peripheral: CBPeripheral, error: Error? = nil) {
        if let error = error {
            os_log("Service discovery error: %@", error.localizedDescription)
        }
        
        if isValidationConnection(peripheral) {
            handleValidationResult(for: peripheral, isValid: false, reason: "service discovery failed")
        } else if peripheral == mainPeripheral {
            cleanup()
        }
    }
    
    private func validateServicesAndCharacteristics(for peripheral: CBPeripheral) -> Bool {
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
    
    private func processReceivedData(_ data: Data, from characteristic: CBCharacteristic) {
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
    
    private func setupCharacteristics(for peripheral: CBPeripheral) {
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

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard peripheralInfo[peripheral] == nil else { return }
        
        // Pre-filter: skip devices that don't advertise any services
        guard advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil else { return }
        
        os_log("Discovered peripheral: %@ - starting validation", peripheral)
        startValidation(for: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        handleConnectionError(for: peripheral, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("Connected to peripheral: %@", peripheral)
        
        if peripheral == mainPeripheral {
            connectionState = .connected
            connectedPeripheral = peripheral
            stopScanning()
        }
        
        peripheral.delegate = self
        peripheral.discoverServices(CBUUIDs.serviceUUIDs)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("Disconnected from peripheral: %@", peripheral)
        
        if isValidationConnection(peripheral) {
            // Validation was interrupted - mark as invalid unless already validated
            if peripheralInfo[peripheral]?.validationState == .validating {
                handleValidationResult(for: peripheral, isValid: false, reason: "disconnected during validation")
            }
        } else if peripheral == mainPeripheral {
            connectionState = .disconnected
            connectedPeripheral = nil
            cleanup()
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where CBUUIDs.serviceUUIDs.contains(service.uuid) {
            os_log("Service invalidated - rediscovering services")
            peripheral.discoverServices(CBUUIDs.serviceUUIDs)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            handleServiceDiscoveryError(for: peripheral, error: error)
            return
        }
        
        guard peripheral.services != nil else {
            handleServiceDiscoveryError(for: peripheral)
            return
        }
        
        os_log("Discovered services, finding characteristics")
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(CBUUIDs.characteristicUUIDs(for: service.uuid), for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            handleServiceDiscoveryError(for: peripheral, error: error)
            return
        }
        
        guard service.characteristics != nil else {
            handleServiceDiscoveryError(for: peripheral)
            return
        }
        
        // Check if we've discovered all characteristics for all services
        let allCharacteristicsDiscovered = peripheral.services?.allSatisfy { service in
            service.characteristics != nil
        } ?? false
        
        if allCharacteristicsDiscovered {
            let isValid = validateServicesAndCharacteristics(for: peripheral)
            
            if isValidationConnection(peripheral) {
                handleValidationResult(for: peripheral, isValid: isValid)
            } else if peripheral == mainPeripheral {
                if isValid {
                    os_log("Main connection validated - setting up characteristics")
                    setupCharacteristics(for: peripheral)
                } else {
                    os_log("Main connection validation failed - disconnecting")
                    cleanup()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Skip data processing for validation connections
        guard !isValidationConnection(peripheral) else { return }
        
        if let error = error {
            os_log("Error updating characteristic value: %@", error.localizedDescription)
            return
        }
        
        guard let data = characteristic.value, !data.isEmpty else {
            os_log("No data received for characteristic %@", characteristic.uuid.uuidString)
            return
        }
        
        processReceivedData(data, from: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // Skip notification handling for validation connections
        guard !isValidationConnection(peripheral) else { return }
        
        if let error = error {
            os_log("Error changing notification state: %@", error.localizedDescription)
            return
        }
        
        if characteristic.isNotifying {
            os_log("Notification began on %@", characteristic.uuid.uuidString)
        } else {
            os_log("Notification stopped on %@ - disconnecting", characteristic.uuid.uuidString)
            cleanup()
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        os_log("Peripheral ready to send data")
    }
}
