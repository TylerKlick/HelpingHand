//
//  SettingsView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/8/25.
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

struct BluetoothToggleView: View {
    let isEnabled: Bool
    let pulse: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
                Text("Bluetooth")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bluetooth")
                            .font(.body)
                            .fontWeight(.medium)
                        if !isEnabled {
                            Text("Off")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isEnabled ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 55, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isEnabled ? Color.green.opacity(0.5) : Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .offset(x: isEnabled ? 11 : -11)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
                    }
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
                }
                .padding(.horizontal)
                
                if isEnabled {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "bluetooth.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 16))
                            Text("Bluetooth is ON")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        
                        Text("Ready to connect devices")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isEnabled)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(width: 320)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let color: Color
    var isHighlighted: Bool = false
    var pulse: Bool = false
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 26, height: 26)
                    .shadow(color: color.opacity(0.3), radius: 1, x: 0, y: 1)
                
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(isHighlighted && pulse ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulse)
            
            Text(title)
                .font(.body)
                .fontWeight(isHighlighted ? .medium : .regular)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            isHighlighted ?
            LinearGradient(
                colors: [Color.blue.opacity(0.15), Color.blue.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            ) :
            LinearGradient(colors: [Color.clear], startPoint: .leading, endPoint: .trailing)
        )
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 0.5)
                .offset(y: 24)
        )
    }
}

#Preview {
    SettingsView()
}
