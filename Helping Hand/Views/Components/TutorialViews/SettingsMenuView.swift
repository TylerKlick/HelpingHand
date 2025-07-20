//
//  SettingsMenuView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct SettingsMenuView: View {
    
    let highlightBluetooth: Bool
    let pulse: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            
            VStack(spacing: 1) {
                SettingsRowView(icon: "airplane", title: "Airplane Mode", color: .orange)
                SettingsRowView(icon: "wifi", title: "Wi-Fi", color: .blue)
                SettingsRowView(
                    icon: "bluetooth.fill",
                    title: "Bluetooth",
                    color: .blue,
                    isSystemImage: false,
                    isHighlighted: highlightBluetooth,
                    pulse: pulse
                )
                SettingsRowView(icon: "antenna.radiowaves.left.and.right", title: "Cellular", color: .green)
                SettingsRowView(icon: "personalhotspot", title: "Personal Hotspot", color: .green)
            }
            .background(Color(.systemBackground))
        }
        .frame(width: 300)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
