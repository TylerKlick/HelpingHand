//
//  DeviceActions.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

// MARK: - Device Actions
struct DeviceActions: View {
    let connectionState: ConnectionState
    let onConnectionAction: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ConnectionStatusView(state: connectionState)
            ConnectionButton(
                state: connectionState,
                action: onConnectionAction
            )
        }
    }
}
