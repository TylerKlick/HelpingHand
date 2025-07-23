import CoreBluetooth
import os

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state) {
            case .poweredOn:
                bluetoothState = .poweredOn
            case .poweredOff:
                bluetoothState = .poweredOff
            case .unauthorized:
                bluetoothState = .unauthorized
            case .resetting:
                bluetoothState = .resetting
            case .unsupported:
                bluetoothState = .unsupported
            default:
                bluetoothState = .unknown
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        // Pre-filter: skip devices that don't advertise any services
        guard advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil else { return }
        
        os_log("Discovered peripheral: %@", peripheral)
        addDiscoveredPeripheral(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        handleConnectionError(for: peripheral, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("Connected to peripheral: %@", peripheral)
        
        updateConnectionState(for: peripheral, state: .validating)
        
        peripheral.delegate = self
        peripheral.discoverServices(CBUUIDs.serviceUUIDs)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("Disconnected from peripheral: %@", peripheral)
        
        handleDisconnection(for: peripheral, error: error)
    }
    
    // MARK: - Helper Methods
    private func handleConnectionError(for peripheral: CBPeripheral, error: Error?) {
                
        if let error = error {
            os_log("Connection error for %@: %@", peripheral, error.localizedDescription)
        }
        
        updateConnectionState(for: peripheral, state: .disconnected)
        handleValidationResult(for: peripheral, isValid: false, reason: "connection failed")
    }
    
    private func handleDisconnection(for peripheral: CBPeripheral, error: Error?) {
        
        let peripheralIdentifier = peripheral.identifier

        peripheralInfo[peripheralIdentifier]?.validationTimer?.invalidate()
        updateConnectionState(for: peripheral, state: .disconnected)
        
        if let error = error {
            os_log("Disconnection error for %@: %@", peripheral, error.localizedDescription)
        }
        
        // If peripheral was validating and disconnected unexpectedly, mark as invalid
        if let info = peripheralInfo[peripheralIdentifier],
           info.connectionState == .validating {
            handleValidationResult(for: peripheral, isValid: false, reason: "disconnected during validation")
        }
    }
}
