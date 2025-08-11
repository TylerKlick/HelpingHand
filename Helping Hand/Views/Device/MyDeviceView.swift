//
//  MyDeviceView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/16/25.
//

import SwiftUI
import CoreBluetooth
internal import SwiftUIVisualEffects
import AccessorySetupKit

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
                            onPair: {
                                let session = viewModel.bluetoothManager.session
                                let descriptor = ASDiscoveryDescriptor()
                                descriptor.bluetoothServiceUUID = CBUUID(string: "640DBB7A-D541-4AF3-90FA-4FAA92FBA231")
                                
                                let pickerItem = ASPickerDisplayItem(
                                    name: "My Device",
                                    productImage: UIImage(named: "arduino")!,
                                    descriptor: descriptor
                                )
                                pickerItem.setupOptions = [.confirmAuthorization]
                                
                                session?.showPicker(for: [pickerItem]) { error in
                                    if let err = error {
                                        print("Failed to show picker: \(err)")
                                    }
                                }
                            },
                            onConnectAll: { viewModel.connectAllDevices() },
                            onUpdateAll: {

                            },
                            connectAllEnabled: viewModel.hasPairedAndPowered,
                            disconnectAllEnabled: viewModel.hasActiveAndPowered,
                            pairEnabled: true,
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
                        
                        DataStreamCard(
                            data: viewModel.receivedData,
                            onClear: { }
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
