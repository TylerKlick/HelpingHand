//
//  QuickActionButtonText.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct QuickActionButtonText: View {
    let title: String
    let subtitle: String
    let isEnabled: Bool
    
    var body: some View {
        VStack(spacing: 1) {
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isEnabled ? .primary : .gray)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
