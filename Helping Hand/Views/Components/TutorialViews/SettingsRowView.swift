//
//  SettingsView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/8/25.
//

import SwiftUI

struct SettingsRowView: View {
    let icon: String
    let title: String
    let color: Color
    var isSystemImage: Bool = true
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
                
                (isSystemImage ? Image(systemName: icon) : Image(icon))
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
