
//
//  DeviceDetailView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/13/25.
//

import SwiftUI
internal import SwiftUIVisualEffects

struct DeviceDetailView: View {
    @ObservedObject var device: Device
    @Environment(\.dismiss) private var dismiss
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.red.opacity(0.3),
                    Color.cyan.opacity(0.4),
                    Color.purple.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header with drag indicator
                VStack(spacing: 12) {
                    // Drag indicator
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(0.3))
                        .frame(width: 40, height: 6)
                        .padding(.top, 8)
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Device Details")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(device.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Device info cards
                        VStack(spacing: 16) {
                            DeviceInfoCard(
                                icon: "tag.fill",
                                title: "Device Name",
                                value: device.name,
                                iconColor: .blue
                            )
                            
                            DeviceInfoCard(
                                icon: "number.circle.fill",
                                title: "Device ID",
                                value: device.identifier.uuidString,
                                iconColor: .green,
                                isMonospace: true
                            )
                            
                            DeviceInfoCard(
                                icon: connectionStateIcon(for: device.connectionState),
                                title: "Connection State",
                                value: device.connectionState.rawValue.capitalized,
                                iconColor: connectionStateColor(for: device.connectionState)
                            )
                        }
                        
                        // Placeholder for future features
                        VStack(spacing: 12) {
                            Image(systemName: "gear.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            
                            Text("More device details coming soon")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("Additional device information and controls will be available in a future update")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
        .offset(y: dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only allow downward dragging
                    if value.translation.height > 0 {
                        dragOffset = value.translation
                    }
                }
                .onEnded { value in
                    // Dismiss if dragged down enough
                    if value.translation.height > 100 {
                        dismiss()
                    } else {
                        // Snap back with animation
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dragOffset)
    }
    
    // Helper functions for connection state
    private func connectionStateIcon(for state: DeviceConnectionState) -> String {
        switch state.rawValue.lowercased() {
        case "connected":
            return "wifi.circle.fill"
        case "connecting":
            return "wifi.circle"
        case "disconnected":
            return "wifi.slash.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    private func connectionStateColor(for state: DeviceConnectionState) -> Color {
        switch state.rawValue.lowercased() {
        case "connected":
            return .green
        case "connecting":
            return .orange
        case "disconnected":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Device Info Card
struct DeviceInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    var isMonospace: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
                .frame(width: 30, height: 30)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(isMonospace ? .system(.body, design: .monospaced) : .body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // Copy button for long values
            if value.count > 20 {
                Button(action: {
                    UIPasteboard.general.string = value
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}
