import Foundation
import CoreBluetooth

class CentralManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheralName: String?
    @Published var characteristics: [CBCharacteristic] = []
    @Published var isBluetoothOn: Bool = false
    @Published var isConnected: Bool = false

    // Example UUIDs
    private let serviceUUID = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    private let txUUID = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    private let rxUUID = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func startScan() {
        discoveredPeripherals.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        connectedPeripheral = peripheral
        peripheral.delegate = self // MUST set delegate before connecting
        centralManager.connect(peripheral, options: nil)
    }

    func write(value: Data, to characteristic: CBCharacteristic) {
        guard let peripheral = connectedPeripheral else { return }
        peripheral.writeValue(value, for: characteristic, type: .withResponse)
    }

    func read(from characteristic: CBCharacteristic) {
        connectedPeripheral?.readValue(for: characteristic)
    }
}

extension CentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothOn = true
            startScan()
        case .poweredOff, .unauthorized, .unsupported:
            isBluetoothOn = false
        case .resetting, .unknown:
            isBluetoothOn = false
        @unknown default:
            isBluetoothOn = false
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            DispatchQueue.main.async {
                self.discoveredPeripherals.append(peripheral)
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        connectedPeripheralName = peripheral.name ?? "Unnamed Device"
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        connectedPeripheral = nil
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        connectedPeripheral = nil
        characteristics = []
        connectedPeripheralName = nil
        startScan()
    }
}

//extension CentralManager: CBPeripheralDelegate {
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        guard let services = peripheral.services else { return }
//        for service in services {
//            peripheral.discoverCharacteristics([txUUID, rxUUID], for: service)
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if let chars = service.characteristics {
//            DispatchQueue.main.async {
//                self.characteristics.append(contentsOf: chars)
//            }
//        }
//    }
//
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if let data = characteristic.value {
//            print("Read from \(characteristic.uuid): \(data)")
//        }
//    }
//}
