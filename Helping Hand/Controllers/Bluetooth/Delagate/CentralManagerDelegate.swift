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
            if scannedPeripherals[peripheral]?.validationState == .validating {
                handleValidationResult(for: peripheral, isValid: false, reason: "disconnected during validation")
            }
        } else if peripheral == mainPeripheral {
            connectionState = .disconnected
            disconnect()
        }
    }
}
