import CoreBluetooth
import os

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where CBUUIDs.serviceUUIDs.contains(service.uuid) {
            os_log("Service invalidated - rediscovering services")
            peripheral.discoverServices(CBUUIDs.serviceUUIDs)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error, peripheral.services != nil {
            handleServiceDiscoveryError(for: peripheral, error: error)
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
                    disconnect()
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
            disconnect()
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        os_log("Peripheral ready to send data")
    }
}
