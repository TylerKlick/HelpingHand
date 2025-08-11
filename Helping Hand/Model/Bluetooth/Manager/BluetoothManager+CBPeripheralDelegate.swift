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
        if let error = error {
            handleServiceDiscoveryError(for: peripheral, error: error)
            return
        }
        
        guard let services = peripheral.services, !services.isEmpty else {
            handleServiceDiscoveryError(for: peripheral, error: nil)
            return
        }
        
        os_log("Discovered services, finding characteristics")
        
        for service in services {
            peripheral.discoverCharacteristics(CBUUIDs.characteristicUUIDs(for: service.uuid), for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            handleServiceDiscoveryError(for: peripheral, error: error)
            return
        }
        
        guard service.characteristics != nil else {
            handleServiceDiscoveryError(for: peripheral, error: nil)
            return
        }
        
        // Check if we've discovered all characteristics for all services
        if hasDiscoveredAllCharacteristics(for: peripheral) {
            let isValid = BluetoothManager.validateServicesAndCharacteristics(for: peripheral)
            handleValidationResult(for: peripheral, isValid: isValid)
            
            if isValid {
                os_log("Peripheral validation successful - setting up characteristics")
                setupCharacteristics(for: peripheral)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
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
        if let error = error {
            os_log("Error changing notification state: %@", error.localizedDescription)
            return
        }
        
        if characteristic.isNotifying {
            os_log("Notification began on %@", characteristic.uuid.uuidString)
        } else {
            os_log("Notification stopped on %@", characteristic.uuid.uuidString)
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        os_log("Peripheral ready to send data")
    }
    
    // MARK: - Helper Methods
    private func handleServiceDiscoveryError(for peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            os_log("Service discovery error: %@", error.localizedDescription)
        }
        
        handleValidationResult(for: peripheral, isValid: false, reason: "service discovery failed")
    }
    
    private func hasDiscoveredAllCharacteristics(for peripheral: CBPeripheral) -> Bool {
        return peripheral.services?.allSatisfy { service in
            service.characteristics != nil
        } ?? false
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
