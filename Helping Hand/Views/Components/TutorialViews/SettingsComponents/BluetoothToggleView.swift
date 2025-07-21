//
//  BluetoothMenuView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

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
                            Image("bluetooth.fill")
                                .foregroundColor(.white)
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
