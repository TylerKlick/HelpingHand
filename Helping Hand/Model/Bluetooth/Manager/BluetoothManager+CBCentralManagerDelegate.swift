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
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        handleConnectionError(for: peripheral, error: error)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("Connected to peripheral: %@", peripheral.name ?? "unknown")
        
        updateConnectionState(for: peripheral, state: .validating)
        
        peripheral.delegate = self
        peripheral.discoverServices(CBUUIDs.serviceUUIDs)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("Disconnected from peripheral: %@", peripheral.name ?? "unknown")
        
        handleDisconnection(for: peripheral, error: error)
    }
    
    // MARK: - Helper Methods
    private func handleConnectionError(for peripheral: CBPeripheral, error: Error?) {
                
        if let error = error {
            os_log("Connection error for %@: %@", peripheral.name ?? "unknown", error.localizedDescription)
        }
        
        updateConnectionState(for: peripheral, state: .disconnected)
        handleValidationResult(for: peripheral, isValid: false, reason: "connection failed")
    }
    
    private func handleDisconnection(for peripheral: CBPeripheral, error: Error?) {
        
        guard let device = pairedDevices.first(where: { $0.identifier == peripheral.identifier }) else { return }

        device.validationTimer?.invalidate()
        updateConnectionState(for: peripheral, state: .disconnected)
        
        if let error = error {
            os_log("Disconnection error for %@: %@", peripheral.name ?? "unknown", error.localizedDescription)
        }
        
        // If peripheral was validating and disconnected unexpectedly, mark as invalid
        if device.connectionState == .validating {
            handleValidationResult(for: peripheral, isValid: false, reason: "disconnected during validation")
        }
    }
}
