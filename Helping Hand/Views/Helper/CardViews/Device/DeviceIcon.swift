//
//  DeviceIcon.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI
internal import SwiftUIVisualEffects

struct DeviceIcon: View {
    let connectionState: ConnectionState
    let isPaired: Bool
    
    var body: some View {
        Image(systemName: iconName)
            .font(.title2)
            .foregroundColor(iconColor)
            .frame(width: 32, height: 32)
            .background(
                BlurEffect()
                    .blurEffectStyle(.systemUltraThinMaterial)
                    .clipShape(Circle())
            )
    }
    
    private var iconName: String {
        isPaired ? "link.badge.plus" : "antenna.radiowaves.left.and.right"
    }
    
    private var iconColor: Color {
        switch connectionState {
        case .connected: return .green
        case .connecting, .validating: return .orange
        case .validationFailed: return .red
        default: return isPaired ? .blue : .gray
        }
    }
}
