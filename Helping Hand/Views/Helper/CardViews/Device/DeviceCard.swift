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
    let onTap: (() -> Void)?
    let onConnectionAction: () -> Void

    var body: some View {
        let content = HStack(spacing: 16) {
            DeviceIcon(
                connectionState: device.connectionState,
                isPaired: isPaired
            )

            DeviceInfo(
                device: device,
                isPaired: isPaired
            )

            Spacer()

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

        if let onTap = onTap {
            Button(action: onTap) {
                content
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            content
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
