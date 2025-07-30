//
//  DeviceInfo.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct DeviceInfo: View {
    let device: Device
    let isPaired: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(device.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if isPaired {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Text(device.identifier.uuidString.prefix(8) + "...")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}
