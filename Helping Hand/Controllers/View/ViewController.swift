import CoreBluetooth
import SwiftUI

// MARK: - SwiftUI View
struct BluetoothView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var selectedDevice: CBPeripheral?
    @State private var showingDeviceDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HeroStatusCard(
                        bluetoothState: bluetoothManager.bluetoothState,
                        connectedCount: connectedDevicesCount
                    )
                    
                    QuickActionsCard(
                        isScanning: bluetoothManager.isScanning,
                        bluetoothState: bluetoothManager.bluetoothState,
                        hasConnectedDevices: connectedDevicesCount > 0,
                        onScanToggle: toggleScanning,
                        onDisconnectAll: bluetoothManager.disconnectAll
                    )
                    
                    DeviceListCard(
                        title: "Connected Devices",
                        devices: connectedDevices,
                        emptyMessage: "No Connected Devices",
                        emptySubtitle: "Connect to paired devices or discover new ones",
                        showCount: true,
                        onDeviceSelect: nil,
                        connectionAction: bluetoothManager.disconnect,
                        connectionState: bluetoothManager.getConnectionState
                    )
                    
                    DeviceListCard(
                        title: "Paired Devices",
                        devices: pairedDevices,
                        emptyMessage: "No Paired Devices",
                        emptySubtitle: "Previously connected devices will appear here",
                        showCount: false,
                        onDeviceSelect: { device in
                            selectedDevice = device
                            showingDeviceDetail = true
                        },
                        connectionAction: bluetoothManager.connect,
                        connectionState: bluetoothManager.getConnectionState
                    )
                    
                    DeviceListCard(
                        title: "Discovered Devices",
                        devices: discoveredDevices,
                        emptyMessage: "No Devices Found",
                        emptySubtitle: bluetoothManager.isScanning ? "Searching for devices..." : "Tap 'Start Scanning' to discover devices",
                        showCount: false,
                        isScanning: bluetoothManager.isScanning,
                        onDeviceSelect: { device in
                            selectedDevice = device
                            showingDeviceDetail = true
                        },
                        connectionAction: bluetoothManager.connect,
                        connectionState: bluetoothManager.getConnectionState
                    )
                    
                    DataStreamCard(
                        data: bluetoothManager.receivedData,
                        onClear: { bluetoothManager.receivedData.removeAll() }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(backgroundGradient)
            .navigationTitle("Helping Hand")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingDeviceDetail) {
            if let device = selectedDevice {
                DeviceDetailView(device: device)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func toggleScanning() {
        bluetoothManager.isScanning ? bluetoothManager.stopScanning() : bluetoothManager.startScanning()
    }
    
    private var connectedDevices: [CBPeripheral] {
        bluetoothManager.discoveredPeripherals.filter(bluetoothManager.isConnected)
    }
    
    private var pairedDevices: [CBPeripheral] {
        let pairedDeviceIds = bluetoothManager.getPairedDeviceIdentifiers()
        return bluetoothManager.discoveredPeripherals.filter { peripheral in
            pairedDeviceIds.contains(peripheral.identifier) && !bluetoothManager.isConnected(peripheral)
        }
    }
    
    private var discoveredDevices: [CBPeripheral] {
        let pairedDeviceIds = bluetoothManager.getPairedDeviceIdentifiers()
        return bluetoothManager.discoveredPeripherals.filter { peripheral in
            !pairedDeviceIds.contains(peripheral.identifier) && !bluetoothManager.isConnected(peripheral)
        }
    }
    
    private var connectedDevicesCount: Int {
        connectedDevices.count
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Hero Status Card
struct HeroStatusCard: View {
    let bluetoothState: CBManagerState
    let connectedCount: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bluetooth Status")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack {
                Text("\(connectedCount)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Connected")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(connectedCount > 0 ? Color.green : Color.gray)
            )
        }
        .padding(16)
        .background(cardBackground)
    }
    
    private var statusColor: Color {
        switch bluetoothState {
        case .poweredOn: return .green
        case .poweredOff: return .red
        case .unauthorized: return .orange
        case .unsupported: return .red
        default: return .gray
        }
    }
    
    private var statusText: String {
        switch bluetoothState {
        case .unknown: return "Unknown"
        case .poweredOff: return "Bluetooth is turned off"
        case .poweredOn: return "Ready to connect"
        case .unauthorized: return "Access denied"
        case .unsupported: return "Not supported"
        case .resetting: return "Resetting..."
        @unknown default: return "Unknown state"
        }
    }
}

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    let isScanning: Bool
    let bluetoothState: CBManagerState
    let hasConnectedDevices: Bool
    let onScanToggle: () -> Void
    let onDisconnectAll: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quick Actions")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Scan Button
                Button(action: onScanToggle) {
                    HStack(spacing: 8) {
                        Group {
                            if isScanning {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .frame(width: 16, height: 16)
                            } else {
                                Image(systemName: "wifi.circle.fill")
                                    .font(.title3)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isScanning ? "Stop Scanning" : "Start Scanning")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Text(isScanning ? "Searching..." : "Find devices")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(actionButtonBackground(isScanning: isScanning))
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(bluetoothState != .poweredOn)
                
                // Disconnect All Button
                if hasConnectedDevices {
                    Button("Disconnect All", action: onDisconnectAll)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red)
                        )
                        .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }
    
    private func actionButtonBackground(isScanning: Bool) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isScanning ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isScanning ? Color.orange : Color.blue, lineWidth: 1)
            )
    }
}

// MARK: - Device List Card
struct DeviceListCard: View {
    let title: String
    let devices: [CBPeripheral]
    let emptyMessage: String
    let emptySubtitle: String
    let showCount: Bool
    let isScanning: Bool?
    let onDeviceSelect: ((CBPeripheral) -> Void)?
    let connectionAction: (CBPeripheral) -> Void
    let connectionState: (CBPeripheral) -> ConnectionState
    
    init(
        title: String,
        devices: [CBPeripheral],
        emptyMessage: String,
        emptySubtitle: String,
        showCount: Bool,
        isScanning: Bool? = nil,
        onDeviceSelect: ((CBPeripheral) -> Void)? = nil,
        connectionAction: @escaping (CBPeripheral) -> Void,
        connectionState: @escaping (CBPeripheral) -> ConnectionState
    ) {
        self.title = title
        self.devices = devices
        self.emptyMessage = emptyMessage
        self.emptySubtitle = emptySubtitle
        self.showCount = showCount
        self.isScanning = isScanning
        self.onDeviceSelect = onDeviceSelect
        self.connectionAction = connectionAction
        self.connectionState = connectionState
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if showCount && !devices.isEmpty {
                    Text("\(devices.count) active")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                } else if let isScanning = isScanning, isScanning {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.6)
                            .frame(width: 12, height: 12)
                        Text("Scanning...")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            
            if devices.isEmpty {
                EmptyStateView(
                    icon: iconForEmptyState,
                    title: emptyMessage,
                    subtitle: emptySubtitle
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(devices, id: \.identifier) { device in
                        DeviceCard(
                            device: device,
                            connectionState: connectionState(device),
                            isPaired: title == "Paired Devices",
                            onTap: onDeviceSelect != nil ? { onDeviceSelect!(device) } : nil,
                            onConnectionAction: { connectionAction(device) }
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }
    
    private var iconForEmptyState: String {
        switch title {
        case "Connected Devices": return "antenna.radiowaves.left.and.right.slash"
        case "Paired Devices": return "link.badge.plus"
        case "Discovered Devices": return "magnifyingglass"
        default: return "magnifyingglass"
        }
    }
}

// MARK: - Device Card
struct DeviceCard: View {
    let device: CBPeripheral
    let connectionState: ConnectionState
    let isPaired: Bool
    let onTap: (() -> Void)?
    let onConnectionAction: () -> Void
    
    var body: some View {
        let content = HStack(spacing: 16) {
            Image(systemName: deviceIcon)
                .font(.title2)
                .foregroundColor(deviceIconColor)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(deviceIconColor.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(device.name ?? "Unknown Device")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    if isPaired {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Text(device.identifier.uuidString.prefix(8) + "...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                ConnectionStatusView(state: connectionState)
                ConnectionButton(
                    state: connectionState,
                    action: onConnectionAction
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
        
        if let onTap = onTap {
            Button(action: onTap) {
                content
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            content
        }
    }
    
    private var deviceIcon: String {
        if isPaired {
            return "link.badge.plus"
        } else {
            return "antenna.radiowaves.left.and.right"
        }
    }
    
    private var deviceIconColor: Color {
        switch connectionState {
        case .connected: return .green
        case .connecting, .validating: return .orange
        case .validationFailed: return .red
        default: return isPaired ? .blue : .gray
        }
    }
    
    private var borderColor: Color {
        switch connectionState {
        case .connected: return .green.opacity(0.3)
        case .connecting, .validating: return .orange.opacity(0.3)
        case .validationFailed: return .red.opacity(0.3)
        default: return isPaired ? .blue.opacity(0.2) : .clear
        }
    }
}

// MARK: - Connection Status View
struct ConnectionStatusView: View {
    let state: ConnectionState
    
    var body: some View {
        Group {
            switch state {
            case .connected:
                StatusIndicator(color: .green, text: "Connected", showSpinner: false)
            case .connecting:
                StatusIndicator(color: .orange, text: "Connecting", showSpinner: true)
            case .validating:
                StatusIndicator(color: .blue, text: "Validating", showSpinner: true)
            case .disconnecting:
                StatusIndicator(color: .gray, text: "Disconnecting", showSpinner: true)
            case .validationFailed:
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    Text("Failed")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            case .disconnected:
                StatusIndicator(color: .gray, text: "Disconnected", showSpinner: false)
            }
        }
    }
}

// MARK: - Status Indicator
struct StatusIndicator: View {
    let color: Color
    let text: String
    let showSpinner: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            if showSpinner {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 10, height: 10)
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, showSpinner ? 6 : 8)
        .padding(.vertical, showSpinner ? 2 : 4)
        .background(color.opacity(0.1))
        .cornerRadius(showSpinner ? 8 : 12)
    }
}

// MARK: - Connection Button
struct ConnectionButton: View {
    let state: ConnectionState
    let action: () -> Void
    
    var body: some View {
        Button(buttonText, action: action)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(buttonTextColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(buttonBackgroundColor)
            .cornerRadius(8)
            .buttonStyle(PlainButtonStyle())
    }
    
    private var buttonText: String {
        switch state {
        case .disconnected: return "Connect"
        case .connecting, .validating, .disconnecting: return "Cancel"
        case .connected: return "Disconnect"
        case .validationFailed: return "Retry"
        }
    }
    
    private var buttonTextColor: Color {
        switch state {
        case .disconnected, .validationFailed: return .white
        case .connecting, .validating, .disconnecting: return .orange
        case .connected: return .white
        }
    }
    
    private var buttonBackgroundColor: Color {
        switch state {
        case .disconnected, .validationFailed: return .blue
        case .connecting, .validating, .disconnecting: return .orange.opacity(0.1)
        case .connected: return .red
        }
    }
}

// MARK: - Data Stream Card
struct DataStreamCard: View {
    let data: [String]
    let onClear: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Data Stream")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if !data.isEmpty {
                    Button("Clear", action: onClear)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(4)
                        .buttonStyle(PlainButtonStyle())
                }
            }
            
            if data.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Data Received",
                    subtitle: "Data from connected devices will appear here"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
                        ForEach(Array(data.enumerated().reversed()), id: \.offset) { _, dataItem in
                            HStack {
                                Text(dataItem)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("Now")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray6))
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .frame(maxHeight: 150)
            }
        }
        .padding(16)
        .background(cardBackground)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Device Detail View (Placeholder)
struct DeviceDetailView: View {
    let device: CBPeripheral
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Device Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name: \(device.name ?? "Unknown")")
                    Text("UUID: \(device.identifier.uuidString)")
                    Text("State: \(device.state.rawValue)")
                }
                .font(.body)
                .padding()
                .background(cardBackground)
                
                Text("Details will be implemented here")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Device Info")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") { dismiss() }
            )
        }
    }
}

// MARK: - Shared Components
private var cardBackground: some View {
    RoundedRectangle(cornerRadius: 12)
        .fill(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
}

// MARK: - Connection State Typealias
typealias ConnectionState = BluetoothManager.ConnectionState

// MARK: - Preview
struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothView()
    }
}
