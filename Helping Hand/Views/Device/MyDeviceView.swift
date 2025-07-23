//
//  MyDeviceView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/16/25.
//

import SwiftUI
import CoreBluetooth
internal import SwiftUIVisualEffects

// MARK: - Main Bluetooth View
struct MyDeviceView: View {
    
    @State private var viewModel = ViewModel()
    @State private var selectedDevice: Device?
    @State var showingDeviceDetail: Bool = false

    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomNavigationHeader(title: "Helping Hand")
                
                ScrollView {
                    VStack(spacing: 16) {
                        HeroStatusCard(
                            bluetoothState: viewModel.bluetoothState,
                            connectedCount: viewModel.connectedDevicesCount
                        )
                        
                        QuickActionsCard(
                            hasConnectedDevices: viewModel.hasConnectedDevices,
                            onScanToggle: { viewModel.loadPairedDevices() },
                            onDisconnectAll: { viewModel.disconnectAll() },
                            onPair: { viewModel.loadPairedDevices()},
                            onConnectAll: { viewModel.connectAllDevices() },
                            onUpdateAll: { /* TODO: Implement update all */ },
                            connectAllEnabled: viewModel.hasPairedAndPowered,
                            disconnectAllEnabled: viewModel.hasActiveAndPowered,
                            pairEnabled: viewModel.bluetoothState == .poweredOn,
                            updateAllEnabled: viewModel.isConnectedAndPowered
                        )
                        
                        DeviceListCard(
                            title: "Paired Devices",
                            devices: viewModel.pairedDevices,
                            emptyMessage: "No Paired Devices",
                            emptySubtitle: "Previously connected devices will appear here",
                            showCount: false,
                            isScanning: viewModel.isScanning,
                            onDeviceSelect: { device in
                                self.selectedDevice = device
                                self.showingDeviceDetail = true
                            },
                            connectionAction: { device in
                                viewModel.getConnectionAction(for: device)()
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - Custom Navigation Header
struct CustomNavigationHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.clear)
    }
}
