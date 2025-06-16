//
//  ViewController.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/16/25.
//

import CoreBluetooth
import SwiftUI

class BluetoothViewController: UIViewController, CBCentralManagerDelegate {
    
    private var centralManager: CBCentralManager!
    private var targetPeriphral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .resetting:
            print("Bluetooth is resetting.")
        case .unauthorized:
            print("Bluetooth is unauthorized.")
        case .unsupported:
            print("Bluetooth is unsupported on this device.")
        case .unknown:
            print("Bluetooth state is unknown.")
        @unknown default:
            print("An unexpected error occured.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        targetPeriphral = peripheral
//        peripheral.delegate = self
        centralManager?.stopScan()
    }
}
