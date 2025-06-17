//
//  CBManagerDelegate.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/17/25.
//

import Foundation
import CoreBluetooth
import os

extension ViewController: CBCentralManagerDelegate {
    
    /*
     * Called when central manager experiences status updates, indicating the availability
     * of the central manager
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                os_log("Scanning")
                startScanning()
            case .poweredOff:
                os_log("Bluetooth is powered off.")
            case .resetting:
                os_log("Bluetooth is resetting.")
            case .unauthorized:
                os_log("Bluetooth is unauthorized.")
            case .unsupported:
                os_log("Bluetooth is unsupported on this device.")
            case .unknown:
                os_log("Bluetooth state is unknown.")
            @unknown default:
                os_log("An unexpected error occured.")
        }
    }
    
    /*
     * A "didDiscover function" -- tells the delegate the central manager discovered a peripheral while
     * performing a scan for target devices
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {

        self.peripheral = peripheral
        self.peripheral.delegate = self

        os_log("Peripheral found: \(peripheral)")
        os_log("Peripheral name: \(peripheral.name ?? "NO NAME")")
        os_log("Advertisement Data : \(advertisementData)")
            
        connect()
    }
    
    /*
     * Handles connection to BLE device
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
          stopScanning()
          peripheral.discoverServices([CBUUIDs.BLEService_UUID])
      }
    
    /**
     * Reads the value of a characteristic
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

          var characteristicASCIIValue = NSString()

        guard characteristic == cbuuid.rxCharacteristic,

          let characteristicValue = characteristic.value,
          let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }

          characteristicASCIIValue = ASCIIstring

          print("Value Recieved: \((characteristicASCIIValue as String))")
    }
    
    // MARK - Helper Methods
    
    func startScanning() -> Void {
        os_log("Stating scan")
        centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    }
    
    func stopScanning() -> Void {
        os_log("Stopping scan")
        centralManager?.stopScan()
    }
    
    func connect() -> Void {
        os_log("Connecting to perihperal...")
        centralManager?.connect(self.peripheral!, options: nil)
    }
    
    func cleanup() -> Void {
        os_log("Performing cleanup...")
        
        if self.peripheral != nil {
            centralManager?.cancelPeripheralConnection(self.peripheral)
        }
        
        stopScanning()
        self.peripheral = nil
    }
    
}
