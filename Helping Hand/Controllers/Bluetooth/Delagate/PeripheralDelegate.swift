////
////  PeripheralDelegate.swift
////  Helping Hand
////
////  Created by Tyler Klick on 7/9/25.
////
//
//import CoreBluetooth
//import os
//
//extension ViewController: CBPeripheralDelegate {
//    
//    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
//        
//        for service in invalidatedServices where CBUUIDs.serviceUUIDs.contains(service.uuid) {
//            os_log("Service is invalidated - rediscover services")
//            peripheral.discoverServices(CBUUIDs.serviceUUIDs)
//        }
//    }
//    
//    /*
//     *  The Transfer Service was discovered
//     */
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let error = error {
//            os_log("Error discovering services: %s", error.localizedDescription)
//            cleanup()
//            return
//        }
//        
//        // Discover the characteristic we want
//        guard let peripheralServices = peripheral.services else { return }
//        for service in peripheralServices {
//            peripheral.discoverCharacteristics(CBUUIDs.characteristicUUIDs(for: service.uuid) , for: service)
//        }
//    }
//    
//    /*
//     *  The Transfer characteristic was discovered.
//     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
//     */
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        // Deal with errors (if any).
//        if let error = error {
//            os_log("Error discovering characteristics: %s", error.localizedDescription)
//            cleanup()
//            return
//        }
//        
//        // Again, we loop through the array, just in case and check if it's the right one
//        guard let serviceCharacteristics = service.characteristics else { return }
//        for characteristic in serviceCharacteristics where CBUUIDs.characteristicUUIDs(for: service.uuid).contains(characteristic.uuid) {
//            
//            // Check if we have found a characteristic to subscribe to
//            if let props = CBUUIDs.characteristicSpec(for: characteristic.uuid)?.properties {
//                for characteristicMode in props {
//                    switch characteristicMode
//                    {
//                    case .notify:
//                        peripheral.setNotifyValue(true, for: characteristic)
//                        
//                    case .write:
//                        os_log("Found writable characteristic")
//                        
//                    case .read:
//                        peripheral.readValue(for: characteristic)
//                    }
//                }
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        
//        if let error = error {
//            os_log("Error discovering characteristics %s", error.localizedDescription)
//            cleanup()
//            return
//        }
//        
//        guard let characteristicData = characteristic.value,
//              let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
//        
//        os_log("Received %d bytes: %s", characteristicData.count, stringFromData)
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        if let error = error {
//            os_log("Error changing notification state: %s", error.localizedDescription)
//            return
//        }
//        
//        guard let props = CBUUIDs.characteristicSpec(for: characteristic.uuid)?.properties,
//              props.contains(.notify) else { return }
//        
//        if characteristic.isNotifying {
//            os_log("Notification began on %@", characteristic)
//        } else {
//            os_log("Notification stopped on %@. Disconnecting", characteristic)
//            cleanup()
//        }
//    }
//    
//    /*
//     *  This is called when peripheral is ready to accept more data when using write without response
//     */
//    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
//        os_log("Peripheral is ready, send data")
//    }
//}
