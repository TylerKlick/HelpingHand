//
//  DeviceCard.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct DeviceCard: View {
    
    @ObservedObject var device: Device
    let isPaired: Bool
    let onConnectionAction: () -> Void
    @State private var displayDetails: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 16) {
                DeviceIcon(
                    connectionState: device.connectionState,
                    isPaired: isPaired
                )
                
                DeviceInfo(
                    device: device,
                    isPaired: isPaired
                )

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.displayDetails.toggle()
            }

            DeviceActions(
                connectionState: device.connectionState,
                onConnectionAction: onConnectionAction
            )
        }
        .padding(16)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .fullScreenCover(isPresented: $displayDetails) {
            DeviceDetailView(device: device)
        }
    }

    private var borderColor: Color {
        switch device.connectionState {
        case .connected: return .green.opacity(0.3)
        case .connecting, .validating: return .orange.opacity(0.3)
        case .validationFailed: return .red.opacity(0.3)
        default: return isPaired ? .blue.opacity(0.2) : .clear
        }
    }
}

#Preview {
    DeviceCard(device: Device(name: "testing", identifier: UUID()), isPaired: true, onConnectionAction: {} )
}
