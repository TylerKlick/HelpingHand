//
//  ConnectionComponents.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI

// MARK: - Connection State Typealias
typealias ConnectionState = BluetoothManager.ConnectionState

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
                ValidationFailedIndicator()
            case .disconnected:
                StatusIndicator(color: .gray, text: "Disconnected", showSpinner: false)
            }
        }
    }
}

// MARK: - Validation Failed Indicator
struct ValidationFailedIndicator: View {
    var body: some View {
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
