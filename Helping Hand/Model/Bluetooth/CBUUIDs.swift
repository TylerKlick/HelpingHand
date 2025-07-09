/// Static Service and Characteristic UUIDs used when scanning for and interfacing with
/// the interface device

import Foundation
import CoreBluetooth

struct CBUUIDs {
    
    // MARK: - Add Services and Characteristics HERE
    
    static let healthService = BLEServiceSpec(
        uuid: CBUUID(string: "640dbb7a-d541-4af3-90fa-4faa92fba231"),
        name: "Health Service",
        characteristics: [
            BLECharacteristicSpec(
                uuid: CBUUID(string: "fd4745de-c1cd-40e2-9bf9-7affb1fedb21"),
                name: "IMU RX",
                properties: [.notify]
            ),
            BLECharacteristicSpec(
                uuid: CBUUID(string: "3611f07f-13b2-413e-81bc-ab5c3bcd2737"),
                name: "sEMG RX",
                properties: [.notify]
            )
        ]
    )

    static let otaService = BLEServiceSpec(
        uuid: CBUUID(string: "6e400010-b5a3-f393-e0a9-e50e24dcca9e"),
        name: "OTA Update Service",
        characteristics: [
            BLECharacteristicSpec(
                uuid: CBUUID(string: "6e400011-b5a3-f393-e0a9-e50e24dcca9e"),
                name: "OTA Write",
                properties: [.write]
            ),
            BLECharacteristicSpec(
                uuid: CBUUID(string: "6e400012-b5a3-f393-e0a9-e50e24dcca9e"),
                name: "OTA Notify",
                properties: [.notify]
            )
        ]
    )
    
    // List all services for Peripheral discovery
    static let allServices: [BLEServiceSpec] = [healthService]
    
    // MARK: - Data lookup and format functions
    
    // Easily get all UUID values
    static var serviceUUIDs: [CBUUID] {
        allServices.map { $0.uuid }
    }
    
    // Get all characteristics for a given service
    static func characteristicUUIDs(for service: CBUUID) -> [CBUUID] {
        allServices.first(where: { $0.uuid == service })?.characteristics.map { $0.uuid } ?? []
    }
    
    // Lookup any characteristic by name and get it's relevant information
    static func characteristicSpec(for uuid: CBUUID) -> BLECharacteristicSpec? {
        for service in allServices {
            if let spec = service.characteristics.first(where: { $0.uuid == uuid }) {
                return spec
            }
        }
        return nil
    }
}

// MARK: - CCBUID Internal Structure
enum CharacteristicProperty {
    case notify
    case write
    case read
}

struct BLECharacteristicSpec {
    let uuid: CBUUID
    let name: String
    let properties: [CharacteristicProperty]
}

struct BLEServiceSpec {
    let uuid: CBUUID
    let name: String
    let characteristics: [BLECharacteristicSpec]
}


