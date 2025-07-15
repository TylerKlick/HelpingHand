//
//  StatusIndicator.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI
internal import SwiftUIVisualEffects

struct StatusIndicator: View {
    let color: Color
    let text: String
    let showSpinner: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            if showSpinner {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 10, height: 10)
            } else {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            }
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, showSpinner ? 6 : 8)
        .padding(.vertical, showSpinner ? 2 : 4)
        .background(
            BlurEffect()
                .blurEffectStyle(.systemUltraThinMaterial)
        )
        .cornerRadius(showSpinner ? 8 : 12)
    }
}
