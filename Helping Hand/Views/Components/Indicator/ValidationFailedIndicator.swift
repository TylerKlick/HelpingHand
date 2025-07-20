//
//  ValidationFailedIndicator.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI
internal import SwiftUIVisualEffects

struct ValidationFailedIndicator: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(.red)
            Text("Failed")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            BlurEffect()
                .blurEffectStyle(.systemUltraThinMaterial)
        )
        .cornerRadius(12)
    }
}
