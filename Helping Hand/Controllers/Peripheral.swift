////
////  CBPeripheralDelegate.swift
////  Helping Hand
////
////  Created by Tyler Klick on 6/17/25.
////
//
//import Foundation
//import CoreBluetooth
//import os
//
///// https://learn.adafruit.com/build-a-bluetooth-app-using-swift-5?view=all
/////
///// https://github.com/AminPlusPlus/BLE-SiliconLab/tree/master
/////
///// https://github.com/adafruit/Basic-Chat/tree/master
/////
///// https://developer.apple.com/documentation/corebluetooth/transferring-data-between-bluetooth-low-energy-devices
/////
//class Peripheral: NSObject, CBPeripheralDelegate {
//    
//    private var peripheral: CBPeripheral!
//
//     init(peripheral: CBPeripheral) {
//         self.peripheral = peripheral
//         super.init()
//     }
//
//     func discoverServices() {
//         os_log("Discovering services...")
//         peripheral.discoverServices([CBUUIDs.BLEService_UUID])
//     }
//
//     func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//         if let error = error {
//             os_log("Error discovering services: %@", error.localizedDescription)
//             return
//         }
//         
//         guard let services = peripheral.services else { return }
//         
//         for service in services {
//             os_log("Service found: %@", service.uuid.uuidString)
//             peripheral.discoverCharacteristics(nil, for: service)
//         }
//     }
//
//     func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//         if let error = error {
//             os_log("Error discovering characteristics: %@", error.localizedDescription)
//             return
//         }
//         
//         guard let characteristics = service.characteristics else { return }
//
//         for characteristic in characteristics {
//             os_log("Characteristic found: %@", characteristic.uuid.uuidString)
//             // Automatically subscribe or read as needed
//         }
//     }
//
//     func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//         if let error = error {
//             os_log("Error reading value: %@", error.localizedDescription)
//             return
//         }
//
//         guard let value = characteristic.value,
//               let ascii = String(data: value, encoding: .utf8) else {
//             os_log("Received data is invalid")
//             return
//         }
//
//         os_log("Received value: %@", ascii)
//     }
//    
//}
