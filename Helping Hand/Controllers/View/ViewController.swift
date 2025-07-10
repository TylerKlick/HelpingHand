//
//  BluetoothManager.swift
//  Helping Hand
//
//  SwiftUI implementation of Bluetooth LE management
//

import SwiftUI

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
            
            if bluetoothManager.validatedPeripherals.isEmpty {
                Text("No peripherals discovered")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(bluetoothManager.validatedPeripherals, id: \.identifier) { peripheral in
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
