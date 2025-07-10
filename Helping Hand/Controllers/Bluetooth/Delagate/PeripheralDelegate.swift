//import CoreBluetooth
//import os
//
//// MARK: - CBPeripheralDelegate
//extension BluetoothManager: CBPeripheralDelegate {
//    
//    /// Handles service changes on peripheral
//    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
//        for service in invalidatedServices where CBUUIDs.serviceUUIDs.contains(service.uuid) {
//            os_log("Service is invalidated - rediscover services")
//            peripheral.discoverServices(CBUUIDs.serviceUUIDs)
//        }
//    }
//    
//    /// Handles Peripheral service discovery. If all services are not present, we will not look for their respective characteristics.
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let error = error {
//            os_log("Error discovering services: %s", error.localizedDescription)
//            
//            // Handle validation vs main connection
//            if let info = validationInfo[peripheral], info.validationState == .validating {
//                completeValidation(for: peripheral, isValid: false)
//            } else if peripheral == self.peripheral {
//                cleanup()
//            }
//            return
//        }
//        
//        guard let peripheralServices = peripheral.services else {
//            os_log("No services found on peripheral")
//            
//            // Handle validation vs main connection
//            if let info = validationInfo[peripheral], info.validationState == .validating {
//                completeValidation(for: peripheral, isValid: false)
//            } else if peripheral == self.peripheral {
//                cleanup()
//            }
//            return
//        }
//        
//        // Validate services
//        if !validateServices(for: peripheral) {
//            // Handle validation vs main connection
//            if let info = validationInfo[peripheral], info.validationState == .validating {
//                completeValidation(for: peripheral, isValid: false)
//            } else if peripheral == self.peripheral {
//                cleanup()
//            }
//            return
//        }
//        
//        // Update validation info if this is a validation connection
//        if var info = validationInfo[peripheral], info.validationState == .validating {
//            info.discoveredServices = peripheralServices
//            validationInfo[peripheral] = info
//        }
//        
//        os_log("All required services found, discovering characteristics")
//        
//        for service in peripheralServices {
//            peripheral.discoverCharacteristics(CBUUIDs.characteristicUUIDs(for: service.uuid), for: service)
//        }
//    }
//    
//    /// Handles the discovery of service characteristics.
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if let error = error {
//            os_log("Error discovering characteristics: %s", error.localizedDescription)
//            
//            // Handle validation vs main connection
//            if let info = validationInfo[peripheral], info.validationState == .validating {
//                completeValidation(for: peripheral, isValid: false)
//            } else if peripheral == self.peripheral {
//                cleanup()
//            }
//            return
//        }
//        
//        guard let serviceCharacteristics = service.characteristics else { return }
//        
//        // Validate characteristics
//        if !validateCharacteristics(for: peripheral, service: service) {
//            // Handle validation vs main connection
//            if let info = validationInfo[peripheral], info.validationState == .validating {
//                completeValidation(for: peripheral, isValid: false)
//            } else if peripheral == self.peripheral {
//                cleanup()
//            }
//            return
//        }
//        
//        // Update validation info if this is a validation connection
//        if var info = validationInfo[peripheral], info.validationState == .validating {
//            info.validatedCharacteristics[service.uuid] = serviceCharacteristics
//            validationInfo[peripheral] = info
//            
//            // Check if we've validated all services and characteristics
//            checkIfFullyValidated(peripheral: peripheral)
//            return
//        }
//        
//        // This is the main connection - proceed with normal operation
//        os_log("All required characteristics found for service %@", service.uuid.uuidString)
//        
//        let expectedCharacteristics = CBUUIDs.characteristicUUIDs(for: service.uuid)
//        
//        for characteristic in serviceCharacteristics where expectedCharacteristics.contains(characteristic.uuid) {
//            
//            if let props = CBUUIDs.characteristicSpec(for: characteristic.uuid)?.properties {
//                for characteristicMode in props {
//                    switch characteristicMode {
//                    case .notify:
//                        peripheral.setNotifyValue(true, for: characteristic)
//                        os_log("Subscribed to notifications for characteristic %@", characteristic.uuid.uuidString)
//                        
//                    case .write:
//                        os_log("Found writable characteristic %@", characteristic.uuid.uuidString)
//                        
//                    case .read:
//                        peripheral.readValue(for: characteristic)
//                        os_log("Reading value for characteristic %@", characteristic.uuid.uuidString)
//                    }
//                }
//            }
//        }
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        // Skip data processing for validation connections
//        if let info = validationInfo[peripheral], info.validationState == .validating {
//            return
//        }
//        
//        if let error = error {
//            os_log("Error updating characteristic value: %s", error.localizedDescription)
//            return
//        }
//        
//        guard let characteristicData = characteristic.value else {
//            os_log("No data received for characteristic %@", characteristic.uuid.uuidString)
//            return
//        }
//        
//        os_log("Received %d bytes from characteristic %@", characteristicData.count, characteristic.uuid.uuidString)
//        
//        // Try to decode as UTF-8 string
//        if let stringFromData = String(data: characteristicData, encoding: .utf8) {
//            os_log("Decoded string data: %s", stringFromData)
//            
//            // Update UI with received data on main thread
//            DispatchQueue.main.async {
//                let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
//                let dataEntry = "[\(timestamp)] \(stringFromData)"
//                self.receivedData.append(dataEntry)
//                
//                // Keep only last 50 entries to prevent memory issues
//                if self.receivedData.count > 50 {
//                    self.receivedData.removeFirst()
//                }
//            }
//        } else {
//            // Handle binary data
//            let hexString = characteristicData.map { String(format: "%02hhx", $0) }.joined()
//            os_log("Received binary data: %s", hexString)
//            
//            DispatchQueue.main.async {
//                let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
//                let dataEntry = "[\(timestamp)] HEX: \(hexString)"
//                self.receivedData.append(dataEntry)
//                
//                // Keep only last 50 entries to prevent memory issues
//                if self.receivedData.count > 50 {
//                    self.receivedData.removeFirst()
//                }
//            }
//        }
//    }
//    
//    /// Handles updates to subscribed Peripheral characteristic values
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        // Skip notification handling for validation connections
//        if let info = validationInfo[peripheral], info.validationState == .validating {
//            return
//        }
//        
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
//    /// Handles writing data to a characteristic without response
//    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
//        os_log("Peripheral is ready, send data")
//    }
//}
