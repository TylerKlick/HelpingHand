//
//  CBUUIDs.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/16/25.
//

import Foundation
import CoreBluetooth

struct CBUUIDs {

    static let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"
    static let KBLE_Characteristic_uuid_Rx_IMU = "6e400004-b5a3-f393-e0a9-e50e24dcca9e"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)
    static let BLE_Characteristic_uuid_RX_IMU = CBUUID(string: KBLE_Characteristic_uuid_Rx_IMU)

    static let characteristicsList : [CBUUID] = [
        BLE_Characteristic_uuid_Tx,
        BLE_Characteristic_uuid_Rx,
        BLE_Characteristic_uuid_RX_IMU
    ]
    
    
    static let characteristics: Set<CBUUID> = .init(characteristicsList)
}

