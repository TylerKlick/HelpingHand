//
//  BluetoothManager.swift
//  Helping Hand
//
//  SwiftUI implementation of Bluetooth LE management
//

import SwiftUI
import CoreBluetooth
import os

// MARK: - Bluetooth Manager State
enum BluetoothState {
    case unknown
    case poweredOff
    case poweredOn
    case unauthorized
    case unsupported
    case resetting
}

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

// MARK: - Bluetooth Manager Observable Object
class BluetoothManager: NSObject, ObservableObject {
    
    @Published var bluetoothState: BluetoothState = .unknown
    @Published var connectionState: ConnectionState = .disconnected
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var receivedData: [String] = []
    @Published var isScanning = false
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var likelyPeripheralArray: [CBPeripheral] = []
    private var rssiArray = [NSNumber]()
    private var timer = Timer()
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard bluetoothState == .poweredOn else { return }
        
        likelyPeripheralArray.removeAll()
        discoveredPeripherals.removeAll()
        isScanning = true
        centralManager.scanForPeripherals(withServices: CBUUIDs.serviceUUIDs)
        os_log("Started scanning for peripherals")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        os_log("Stopped scanning")
    }
    
    func connect(to peripheral: CBPeripheral) {
        connectionState = .connecting
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
        os_log("Attempting to connect to %@", peripheral)
    }
    
    func disconnect() {
        cleanup()
    }
    
    func retrieveConnectedPeripherals() {
        let connectedPeripherals = centralManager.retrieveConnectedPeripherals(withServices: CBUUIDs.serviceUUIDs)
        
        os_log("Found connected Peripherals with transfer service: %@", connectedPeripherals)
        
        if let connectedPeripheral = connectedPeripherals.last {
            os_log("Connecting to peripheral %@", connectedPeripheral)
            self.peripheral = connectedPeripheral
            connectedPeripheral.delegate = self
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            startScanning()
        }
    }
    
    // MARK: - Private Methods
    private func cleanup() {
        guard let peripheral = self.peripheral,
              case .connected = peripheral.state else {
            connectionState = .disconnected
            return
        }
        
        connectionState = .disconnecting
        
        for service in (peripheral.services ?? [] as [CBService]) {
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]) {
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        centralManager.cancelPeripheralConnection(peripheral)
        self.peripheral = nil
        connectedPeripheral = nil
        connectionState = .disconnected
    }
    
    private func updateBluetoothState(from state: CBManagerState) {
        switch state {
        case .unknown:
            bluetoothState = .unknown
        case .resetting:
            bluetoothState = .resetting
        case .unsupported:
            bluetoothState = .unsupported
        case .unauthorized:
            bluetoothState = .unauthorized
        case .poweredOff:
            bluetoothState = .poweredOff
        case .poweredOn:
            bluetoothState = .poweredOn
        @unknown default:
            bluetoothState = .unknown
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        updateBluetoothState(from: central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        if !likelyPeripheralArray.contains(peripheral) {
            os_log("Peripheral discovered: %@ - validating services", peripheral)
            likelyPeripheralArray.append(peripheral)
            
            // Add to discovered peripherals for UI
            DispatchQueue.main.async {
                if !self.discoveredPeripherals.contains(peripheral) {
                    self.discoveredPeripherals.append(peripheral)
                }
            }
            
            // Don't auto-connect - let user choose or validate first
            // connect(to: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        os_log("Failed to connect to %@. %s", peripheral, String(describing: error))
        connectionState = .disconnected
        cleanup()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("Peripheral Connected")
        connectionState = .connected
        connectedPeripheral = peripheral
        stopScanning()
        
        peripheral.delegate = self
        peripheral.discoverServices(CBUUIDs.serviceUUIDs)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("Peripheral Disconnected")
        connectionState = .disconnected
        connectedPeripheral = nil
        cleanup()
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where CBUUIDs.serviceUUIDs.contains(service.uuid) {
            os_log("Service is invalidated - rediscover services")
            peripheral.discoverServices(CBUUIDs.serviceUUIDs)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            os_log("Error discovering services: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard let peripheralServices = peripheral.services else {
            os_log("No services found on peripheral")
            cleanup()
            return
        }
        
        let expectedServices = CBUUIDs.serviceUUIDs
        let foundServices = peripheralServices.map { $0.uuid }
        
        // Check if all expected services are present
        let missingServices = expectedServices.filter { !foundServices.contains($0) }
        
        if !missingServices.isEmpty {
            os_log("Peripheral missing required services: %@", missingServices.map { $0.uuidString })
            cleanup()
            return
        }
        
        os_log("All required services found, discovering characteristics")
        
        for service in peripheralServices {
            peripheral.discoverCharacteristics(CBUUIDs.characteristicUUIDs(for: service.uuid), for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard let serviceCharacteristics = service.characteristics else { return }
        let expectedCharacteristics = CBUUIDs.characteristicUUIDs(for: service.uuid)
        let foundCharacteristics = serviceCharacteristics.map { $0.uuid }
        
        // Check if all expected characteristics are present
        let missingCharacteristics = expectedCharacteristics.filter { !foundCharacteristics.contains($0) }
        
        if !missingCharacteristics.isEmpty {
            os_log("Service %@ missing required characteristics: %@", service.uuid.uuidString, missingCharacteristics.map { $0.uuidString })
            cleanup()
            return
        }
        
        os_log("All required characteristics found for service %@", service.uuid.uuidString)
        
        for characteristic in serviceCharacteristics where expectedCharacteristics.contains(characteristic.uuid) {
            
            if let props = CBUUIDs.characteristicSpec(for: characteristic.uuid)?.properties {
                for characteristicMode in props {
                    switch characteristicMode {
                    case .notify:
                        peripheral.setNotifyValue(true, for: characteristic)
                        os_log("Subscribed to notifications for characteristic %@", characteristic.uuid.uuidString)
                        
                    case .write:
                        os_log("Found writable characteristic %@", characteristic.uuid.uuidString)
                        
                    case .read:
                        peripheral.readValue(for: characteristic)
                        os_log("Reading value for characteristic %@", characteristic.uuid.uuidString)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            os_log("Error updating characteristic value: %s", error.localizedDescription)
            return
        }
        
        guard let characteristicData = characteristic.value else {
            os_log("No data received for characteristic %@", characteristic.uuid.uuidString)
            return
        }
        
        os_log("Received %d bytes from characteristic %@", characteristicData.count, characteristic.uuid.uuidString)
        
        // Try to decode as UTF-8 string
        if let stringFromData = String(data: characteristicData, encoding: .utf8) {
            os_log("Decoded string data: %s", stringFromData)
            
            // Update UI with received data on main thread
            DispatchQueue.main.async {
                let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
                let dataEntry = "[\(timestamp)] \(stringFromData)"
                self.receivedData.append(dataEntry)
                
                // Keep only last 50 entries to prevent memory issues
                if self.receivedData.count > 50 {
                    self.receivedData.removeFirst()
                }
            }
        } else {
            // Handle binary data
            let hexString = characteristicData.map { String(format: "%02hhx", $0) }.joined()
            os_log("Received binary data: %s", hexString)
            
            DispatchQueue.main.async {
                let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
                let dataEntry = "[\(timestamp)] HEX: \(hexString)"
                self.receivedData.append(dataEntry)
                
                // Keep only last 50 entries to prevent memory issues
                if self.receivedData.count > 50 {
                    self.receivedData.removeFirst()
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            os_log("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        guard let props = CBUUIDs.characteristicSpec(for: characteristic.uuid)?.properties,
              props.contains(.notify) else { return }
        
        if characteristic.isNotifying {
            os_log("Notification began on %@", characteristic)
        } else {
            os_log("Notification stopped on %@. Disconnecting", characteristic)
            cleanup()
        }
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        os_log("Peripheral is ready, send data")
    }
}

// MARK: - SwiftUI View
struct BluetoothView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Bluetooth Status
                statusSection
                
                // Connection Controls
                controlsSection
                
                // Discovered Peripherals
                peripheralsSection
                
                // Received Data
                dataSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("Helping Hand")
            .onAppear {
                bluetoothManager.retrieveConnectedPeripherals()
            }
        }
    }
    
    // MARK: - View Components
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Bluetooth Status:")
                    .font(.headline)
                
                Spacer()
                
                Circle()
                    .fill(bluetoothStatusColor)
                    .frame(width: 12, height: 12)
            }
            
            Text(bluetoothStatusText)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Connection:")
                    .font(.headline)
                
                Spacer()
                
                Text(connectionStatusText)
                    .font(.subheadline)
                    .foregroundColor(connectionStatusColor)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var controlsSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                if bluetoothManager.isScanning {
                    bluetoothManager.stopScanning()
                } else {
                    bluetoothManager.startScanning()
                }
            }) {
                Text(bluetoothManager.isScanning ? "Stop Scanning" : "Start Scanning")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(bluetoothManager.bluetoothState != .poweredOn)
            
            if bluetoothManager.connectionState == .connected {
                Button("Disconnect") {
                    bluetoothManager.disconnect()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
    }
    
    private var peripheralsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Discovered Peripherals")
                .font(.headline)
            
            if bluetoothManager.discoveredPeripherals.isEmpty {
                Text("No peripherals discovered")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(peripheral.name ?? "Unknown Device")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(peripheral.identifier.uuidString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if bluetoothManager.connectedPeripheral?.identifier == peripheral.identifier {
                            Text("Connected")
                                .font(.caption)
                                .foregroundColor(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        } else {
                            Button("Connect") {
                                bluetoothManager.connect(to: peripheral)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Received Data")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear Data") {
                    bluetoothManager.receivedData.removeAll()
                }
                .buttonStyle(.bordered)
                .font(.caption)
                .disabled(bluetoothManager.receivedData.isEmpty)
            }
            
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        if bluetoothManager.receivedData.isEmpty {
                            Text("No data received")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(Array(bluetoothManager.receivedData.enumerated().reversed()), id: \.offset) { index, data in
                                Text(data)
                                    .font(.system(.caption, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(maxHeight: 200)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // MARK: - Computed Properties
    private var bluetoothStatusColor: Color {
        switch bluetoothManager.bluetoothState {
        case .poweredOn:
            return .green
        case .poweredOff:
            return .red
        case .unauthorized:
            return .orange
        case .unsupported:
            return .red
        default:
            return .gray
        }
    }
    
    private var bluetoothStatusText: String {
        switch bluetoothManager.bluetoothState {
        case .unknown:
            return "Unknown"
        case .poweredOff:
            return "Bluetooth is turned off"
        case .poweredOn:
            return "Bluetooth is ready"
        case .unauthorized:
            return "Bluetooth access denied"
        case .unsupported:
            return "Bluetooth not supported"
        case .resetting:
            return "Bluetooth is resetting"
        }
    }
    
    private var connectionStatusText: String {
        switch bluetoothManager.connectionState {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .disconnecting:
            return "Disconnecting..."
        }
    }
    
    private var connectionStatusColor: Color {
        switch bluetoothManager.connectionState {
        case .disconnected:
            return .secondary
        case .connecting, .disconnecting:
            return .orange
        case .connected:
            return .green
        }
    }
}

// MARK: - Preview
struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothView()
    }
}
