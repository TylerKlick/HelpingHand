/////  CoreBluetooth Manager Delegate API implementation. Handles scanning, exploring, and connecting to BLE devices as well as the data transfer protocol
/////  used in Helping Hand
//import CoreBluetooth
//import os
//
//extension ViewController: CBCentralManagerDelegate {
//
//    // Mark: Manager Status Checking
//    /// Handles views and alert actions upon the Bluetooth system updating status
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        updateUIOnBluetoothState(state: central.state)
//    }
//    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
//        
//        self.peripheral = peripheral
//        if !likelyPeripheralArray.contains(self.peripheral)
//        {
//            os_log("Likely peripheral discovered: %@ ...Attempting connection", peripheral)
//            likelyPeripheralArray.append(self.peripheral)
//            centralManager.connect(self.peripheral, options: nil)
//        }
//    }
//    
//    /*
//     *  If the connection fails for whatever reason, we need to deal with it.
//     */
//    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
//        os_log("Failed to connect to %@. %s", peripheral, String(describing: error))
//        cleanup()
//    }
//    
//    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        os_log("Peripheral Connected")
//        stopScanning()
//        os_log("Scanning Stopped")
//        
//        peripheral.delegate = self
//        peripheral.discoverServices(CBUUIDs.serviceUUIDs)
//    }
//    
//    /*
//     *  Once the disconnection happens, we need to clean up our local copy of the peripheral
//     */
//    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        os_log("Perhiperal Disconnected")
//        cleanup()
//    }
//}
