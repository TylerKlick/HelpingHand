//
//  BluetoothManager.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/10/25.
//

import Foundation
@preconcurrency import CoreBluetoothMock
import os
import AccessorySetupKit
import SwiftUICore

// MARK: - Bluetooth Manager
@Observable
final class BluetoothManager: NSObject, Sendable {
    
    /// Singleton instance to be shared among all utilizing views and classes
    static let singleton = BluetoothManager()
    
    // MARK: - Properties
    private var centralManager: CBCentralManager!
    private(set) var session: ASAccessorySession?
    var viewModelSpectra = SpectrogramViewModel()

    
    var bluetoothState: BluetoothManagerState = .unknown
    var pairedDevices: [Device] = []
    
    var receivedData: [String] = []
    
    private override init() {
        super.init()
        centralManager = CBCentralManagerFactory.instance(delegate: self,
                                                          queue: nil,
                                                          forceMock: false)
        session = ASAccessorySession()
        session?.activate(on: DispatchQueue.main) { [weak self] event in
            Task { @MainActor in
                await self?.handleSessionEvent(event: event)
            }
        }
        
        pairedDevices = session?.accessories.compactMap { accessory in
            guard let identifier = accessory.bluetoothIdentifier else { return nil }
            return Device(name: accessory.displayName, identifier: identifier)
        } ?? []
    }
    
    @MainActor
    private func handleSessionEvent( event: ASAccessoryEvent ) async
    {
        switch event.eventType {
        case .activated:
            pairedDevices = session?.accessories.compactMap { accessory in
                guard let identifier = accessory.bluetoothIdentifier else { return nil }
                return Device(name: accessory.displayName, identifier: identifier)
            } ?? []
            
        case .accessoryAdded:
            os_log("added!")
            
            guard let accessory = event.accessory else {
                os_log("⚠️ No accessory found in event.")
                return
            }
            
            guard let identifier = accessory.bluetoothIdentifier else {
                return
            }
            let peripherals = centralManager.retrievePeripherals(withIdentifiers: [identifier])
            
            guard let peripheral = peripherals.first else {
                return
            }


            let device = Device(name: peripheral.name, identifier: peripheral.identifier)
            pairedDevices.append(device)
            connect(withIdentifier: device.identifier)
            do { try await session?.finishAuthorization(for: accessory, settings: .default)
            } catch {
                
            }
            
        default:   break
        }
        
    }
    
    private func getPairedDevices() -> [Device] {
        return session?.accessories.compactMap { accessory in
            guard let identifier = accessory.bluetoothIdentifier else { return nil }
            return Device(name: accessory.displayName, identifier: identifier)
        } ?? []
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
        updateConnectionState(for: peripheral, state: .connecting)
        
        startValidationTimer(for: peripheral)
        
        centralManager.connect(peripheral, options: nil)
        
        os_log("Attempting to connect to %@", peripheral.name ?? "unknown")
    }
    
    func disconnect(_ device: Device) {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [device.identifier]).first else { return }
        disconnect(peripheral)
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        guard let device = pairedDevices.first(where: { $0.identifier == peripheral.identifier }),
              device.connectionState != .disconnected else { return }
        
        os_log("Disconnecting from %@", peripheral.name ?? "unknown")
        updateConnectionState(for: peripheral, state: .disconnecting)
        unsubscribeFromNotifications(peripheral)
        centralManager.cancelPeripheralConnection(peripheral)
        updateConnectionState(for: peripheral, state: .disconnected)
    }
    
    func disconnectAll() {
        pairedDevices.forEach { device in
            guard pairedDevices.contains(where: { $0.identifier == device.identifier }) else { return }
            disconnect(device)
        }
    }
    
    // MARK: - Internal Helpers
    
    /// Helper block to reduce boilerplate operations and ensure dependent Views receive an update signal
    internal func updateConnectionState(for peripheral: CBPeripheral, state: DeviceConnectionState) {
        guard let device = pairedDevices.first(where: { $0.identifier == peripheral.identifier }) else { return }
        device.connectionState = state
        os_log("Updated connection state for %@ to %@", device.name, String(describing: state))
    }
    
    internal func updateDeviceConnectionState(for identifier: UUID, state: DeviceConnectionState) {
        guard let device = pairedDevices.first(where: { $0.identifier == identifier }) else { return }
        device.connectionState = state
        os_log("Updated connection state for device %@ to %@", identifier.uuidString, String(describing: state))
    }
    
    private func startValidationTimer(for peripheral: CBPeripheral) {
        guard let device = pairedDevices.first(where: { $0.identifier == peripheral.identifier }) else { return }
        let timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.handleValidationTimeout(for: peripheral)
        }
        device.validationTimer = timer
    }
    
    private func handleValidationTimeout(for peripheral: CBPeripheral) {
        os_log("Validation timeout for peripheral: %@", peripheral.name ?? "unknown")
        handleValidationResult(for: peripheral, isValid: false, reason: "timeout")
    }
    
    internal func handleValidationResult(for peripheral: CBPeripheral, isValid: Bool, reason: String = "") {
//        let identifier = peripheral.identifier
        
        guard let device = pairedDevices.first(where: { $0.identifier == peripheral.identifier }) else { return }
        device.validationTimer?.invalidate()
        device.validationTimer = nil
        device.connectionState = isValid ? .validated : .validationFailed
        
        let resultText = isValid ? "successful" : "failed"
        os_log("Peripheral validation %@: %@ %@", resultText, peripheral.name ?? "unknown", reason)
        
        if isValid {
            updateConnectionState(for: peripheral, state: .connected)
        } else {
            disconnect(peripheral)
            updateConnectionState(for: peripheral, state: .validationFailed)
        }
    }
    
    internal func processReceivedData(_ data: Data, from characteristic: CBCharacteristic) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let dataEntry = createDataEntry(data, timestamp: timestamp)
        
//        DispatchQueue.main.async {
//            self.receivedData.append(dataEntry)
//            if self.receivedData.count > 50 {
//                self.receivedData.removeFirst()
//            }
//        }
    }
    
    // TODO - Add support for int32 format to not remove the 4096 noise pattern from data
    private func createDataEntry(_ data: Data, timestamp: String) -> String {
        guard let int32Value = data.first.map({ Int32(bitPattern: UInt32($0)) }) else {
            let hexString = data.map { String(format: "%02hhx", $0)}.joined()
            os_log("Received binary data: %@", hexString)
            return "[\(timestamp)] HEX: \(hexString)"
        }
        
        os_log("Received Int32 data: %d", int32Value)
        viewModelSpectra.pushSample(Float(int32Value))

        return "[\(timestamp)] Int32: \(int32Value)"
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
    
    
    static func validateServicesAndCharacteristics(for peripheral: CBPeripheral) -> Bool {
        guard let services = peripheral.services else { return false }
        
        let expectedServices = CBUUIDs.serviceUUIDs
        let foundServices = services.map { $0.uuid }
        
        // Check all required services are present
        guard expectedServices.allSatisfy({ foundServices.contains($0) }) else {
            os_log("Missing required services")
            return false
        }
        
        // Check all required characteristics are present
        for service in services {
            guard let characteristics = service.characteristics else { return false }
            
            let expectedCharacteristics = CBUUIDs.characteristicUUIDs(for: service.uuid)
            let foundCharacteristics = characteristics.map { $0.uuid }
            
            guard expectedCharacteristics.allSatisfy({ foundCharacteristics.contains($0) }) else {
                os_log("Missing required characteristics for service %@", service.uuid.uuidString)
                return false
            }
        }
        
        return true
    }
}
