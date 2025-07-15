//
//  ConnectionStatusView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

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
