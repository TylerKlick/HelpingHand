//
//  DeviceListHeader.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

// MARK: - Device List Header
struct DeviceListHeader: View {
    let title: String
    let deviceCount: Int
    let showCount: Bool
    let isScanning: Bool?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .opacity(0.95)
            
            Spacer()
            
            if showCount && deviceCount > 0 {
                DeviceCountBadge(count: deviceCount)
            } else if let isScanning = isScanning, isScanning {
                ScanningIndicator()
            }
        }
    }
}
