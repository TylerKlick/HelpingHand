//
//  DeviceDetailView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
import CoreBluetooth

// MARK: - Device Detail View
struct DeviceDetailView: View {
    let device: CBPeripheral
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Device Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name: \(device.name ?? "Unknown")")
                    Text("UUID: \(device.identifier.uuidString)")
                    Text("State: \(device.state.rawValue)")
                }
                .font(.body)
                .padding()
                .background(AppStyle.cardBackground)
                
                Text("Details will be implemented here")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Device Info")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") { dismiss() }
            )
        }
    }
}

// MARK: - App Style
struct AppStyle {
    static var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    static var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

