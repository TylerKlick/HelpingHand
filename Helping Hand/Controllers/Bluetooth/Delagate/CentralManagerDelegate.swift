import CoreBluetooth
import os

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        bluetoothState = central.state
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard scannedPeripherals[peripheral] == nil else { return }
        
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
        
        // Check if this is the main connection (user-initiated)
        if peripheral == mainPeripheral {
            connectionState = .connected
            connectedPeripheral = peripheral
            stopScanning()
            
            // Set up the peripheral delegate and discover services
            peripheral.delegate = self
            peripheral.discoverServices(CBUUIDs.serviceUUIDs)
        } else {
            // This is a validation connection
            peripheral.delegate = self
            peripheral.discoverServices(CBUUIDs.serviceUUIDs)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("Disconnected from peripheral: %@", peripheral)
        
        if isValidationConnection(peripheral) {
            // Validation was interrupted - mark as invalid unless already validated
            if scannedPeripherals[peripheral]?.validationState == .validating {
                handleValidationResult(for: peripheral, isValid: false, reason: "disconnected during validation")
            }
        }
        
        // Handle main peripheral disconnect
        if peripheral == mainPeripheral {
            connectedPeripheral = nil
            connectionState = .disconnected
            mainPeripheral = nil
        }
        
        disconnect(peripheral)
    }
}
