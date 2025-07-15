//
//  ConnectionComponents.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
internal import SwiftUIVisualEffects

// MARK: - Connection State Typealias
typealias ConnectionState = BluetoothManager.DeviceConnectionState


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
            .background(
                BlurEffect()
                    .blurEffectStyle(blurEffectStyle)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
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
    
    private var blurEffectStyle: UIBlurEffect.Style {
        switch state {
        case .disconnected, .validationFailed: return .systemMaterialDark
        case .connecting, .validating, .disconnecting: return .systemUltraThinMaterial
        case .connected: return .systemMaterialDark
        }
    }
}
