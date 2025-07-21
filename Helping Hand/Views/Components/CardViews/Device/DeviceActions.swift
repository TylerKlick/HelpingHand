//
//  DeviceActions.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct DeviceActions: View {
    let connectionState: DeviceConnectionState
    let onConnectionAction: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            ConnectionStatusView(state: connectionState)
            ConnectionButton(
                state: connectionState,
                action: onConnectionAction
            )
        }
        .animation(.easeInOut(duration: 0.2), value: connectionState)
    }
}

#Preview {
    DeviceActions(connectionState: .connected, onConnectionAction: {})
}
