//
//  DevicePairingManager.swift
//  Helping Hand
//
//  Device pairing and persistence manager
//

import Foundation
import CoreBluetooth
import os

// MARK: - Device Pairing Manager
class DevicePairingManager: ObservableObject {
    
    // MARK: - Logging
    private let logger = Logger(subsystem: "com.helpinghand.app", category: "DevicePairingManager")
    
    @Published var pairedDevices: [Device] = []
    
    private let userDefaults = UserDefaults.standard
    private let pairedDevicesKey = "PairedBluetoothDevices"
    
    init() {
        logger.info("Initializing DevicePairingManager")
        loadPairedDevices()
    }
    
    // MARK: - Persistence
    private func loadPairedDevices() {
        logger.debug("Loading paired devices from UserDefaults")
        
        if let data = userDefaults.data(forKey: pairedDevicesKey),
           let decoded = try? JSONDecoder().decode([Device].self, from: data) {
            pairedDevices = decoded
            logger.info("Successfully loaded \(decoded.count) paired devices from storage")
            
            // Log each loaded device
            for device in decoded {
                logger.debug("Loaded paired device: \(device.name) (ID: \(device.identifier.uuidString))")
            }
        } else {
            logger.info("No paired devices found in storage or failed to decode")
        }
    }
    
    private func savePairedDevices() {
        logger.debug("Saving \(self.pairedDevices.count) paired devices to UserDefaults")
        
        if let encoded = try? JSONEncoder().encode(pairedDevices) {
            userDefaults.set(encoded, forKey: pairedDevicesKey)
            logger.info("Successfully saved paired devices to storage")
        } else {
            logger.error("Failed to encode paired devices for storage")
        }
    }
    
    // MARK: - Pairing Management
    func pairDevice(_ peripheral: CBPeripheral) {
        let deviceName = peripheral.name ?? "Unknown Device"
        let deviceId = peripheral.identifier.uuidString
        
        logger.info("Attempting to pair device: \(deviceName) (ID: \(deviceId))")
        
        // Check if device is already paired
        if isPaired(peripheral) {
            logger.warning("Device \(deviceName) is already paired, skipping pairing")
            return
        }
        
        let pairedDevice = Device(peripheral: peripheral)
        pairedDevices.append(pairedDevice)
        savePairedDevices()
        
        logger.info("Successfully paired device: \(deviceName) (Internal ID: \(pairedDevice.id.uuidString))")
    }
    
    func unpairDevice(_ deviceId: UUID) {
        logger.info("Attempting to unpair device with internal ID: \(deviceId.uuidString)")
        
        if let deviceIndex = self.pairedDevices.firstIndex(where: { $0.id == deviceId }) {
            let deviceName = self.pairedDevices[deviceIndex].name
            self.pairedDevices.removeAll { $0.id == deviceId }
            savePairedDevices()
            logger.info("Successfully unpaired device: \(deviceName)")
        } else {
            logger.warning("Could not find device with internal ID \(deviceId.uuidString) to unpair")
        }
    }
    
    func unpairDevice(withIdentifier identifier: UUID) {
        logger.info("Attempting to unpair device with peripheral ID: \(identifier.uuidString)")
        
        if let deviceIndex = self.pairedDevices.firstIndex(where: { $0.identifier == identifier }) {
            let deviceName = self.pairedDevices[deviceIndex].name
            self.pairedDevices.removeAll { $0.identifier == identifier }
            savePairedDevices()
            logger.info("Successfully unpaired device: \(deviceName)")
        } else {
            logger.warning("Could not find device with peripheral ID \(identifier.uuidString) to unpair")
        }
    }
    
    func isPaired(_ peripheral: CBPeripheral) -> Bool {
        let deviceName = peripheral.name ?? "Unknown Device"
        let deviceId = peripheral.identifier.uuidString
        let paired = self.pairedDevices.contains { $0.identifier == peripheral.identifier }
        
        logger.debug("Checking if device \(deviceName) (ID: \(deviceId)) is paired: \(paired)")
        
        return paired
    }
    
    func getPairedDevice(for peripheral: CBPeripheral) -> Device? {
        let deviceName = peripheral.name ?? "Unknown Device"
        let deviceId = peripheral.identifier.uuidString
        let pairedDevice = self.pairedDevices.first { $0.identifier == peripheral.identifier }
        
        if let device = pairedDevice {
            logger.debug("Found paired device for \(deviceName): \(device.name)")
        } else {
            logger.debug("No paired device found for \(deviceName) (ID: \(deviceId))")
        }
        
        return pairedDevice
    }
    
    // MARK: - Status Updates
    func updateConnectionStatus(_ peripheral: CBPeripheral, isConnected: Bool) {
        let deviceName = peripheral.name ?? "Unknown Device"
        let deviceId = peripheral.identifier.uuidString
        
        logger.info("Updating connection status for device \(deviceName) (ID: \(deviceId)): \(isConnected ? "connected" : "disconnected")")
        
        if let index = self.pairedDevices.firstIndex(where: { $0.identifier == peripheral.identifier }) {
            self.pairedDevices[index].lastSeen = Date()
            savePairedDevices()
            logger.debug("Updated last seen timestamp for device \(deviceName)")
        } else {
            logger.warning("Could not find paired device \(deviceName) to update connection status")
        }
    }
    
    func updateLastSeen(_ peripheral: CBPeripheral) {
        let deviceName = peripheral.name ?? "Unknown Device"
        let deviceId = peripheral.identifier.uuidString
        
        logger.debug("Updating last seen timestamp for device \(deviceName) (ID: \(deviceId))")
        
        if let index = self.pairedDevices.firstIndex(where: { $0.identifier == peripheral.identifier }) {
            self.pairedDevices[index].lastSeen = Date()
            savePairedDevices()
            logger.debug("Successfully updated last seen timestamp for device \(deviceName)")
        } else {
            logger.warning("Could not find paired device \(deviceName) to update last seen timestamp")
        }
    }
    
    // MARK: - Utility
    func getPairedDevicesList() -> [Device] {
        let sortedDevices = self.pairedDevices.sorted { $0.lastSeen > $1.lastSeen }
        
        logger.debug("Returning list of \(sortedDevices.count) paired devices sorted by last seen")
        
        return sortedDevices
    }
}
