//
//  TabItem.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/18/25.
//

import SwiftUI

struct TabItem: View {
    var isSelected: Bool
    var image: String
    var accentColor: Color
    var isAnimating: Bool = false
    let action: () -> Void
    private let selectedOffset: CGFloat = 11 // The Offset size of the selected
    private let unselectedOffset: CGFloat = 8 // Offset of unselected text

    private let itemSize: CGFloat = 50
    private let animation: Animation = .interpolatingSpring(mass: 0.3, stiffness: 120, damping: 8)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
                .frame(width: isSelected ? 85 : itemSize, height: isSelected ? 55 : itemSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .strokeBorder(
                            LinearGradient(colors: [
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.05)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.2
                        )
                )
                .background(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            isSelected ? accentColor.opacity(0.35) : Color.clear,
                            .clear
                        ]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 55
                    )
                    .blur(radius: 10)
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: isSelected ? accentColor.opacity(0.3) : .clear, radius: isSelected ? 10 : 0, x: 0, y: 4)
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(animation, value: isSelected)
            
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: itemSize / 2.2, height: itemSize / 2.2)
                .foregroundStyle(
                    LinearGradient(
                        colors: isSelected
                        ? [accentColor, accentColor.opacity(0.8)]
                        : [Color.gray.opacity(0.6), Color.gray.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isSelected ? accentColor.opacity(0.5) : .clear, radius: isSelected ? 5 : 0)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(animation, value: isSelected)
            
            Text("Label") // Customize this label based on your context
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: isSelected ? [accentColor, accentColor.opacity(0.8)] : [.primary, .primary.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(animation, value: isSelected)
                    .offset(y: itemSize / 2 + (isSelected ? selectedOffset : unselectedOffset))
                    .font( isSelected ? .system(size: 15) : .caption)
            
        }
        // Disable interaction during animation
        .disabled(isAnimating)
        .onTapGesture(perform: action)
    }
}

#Preview {
    Group {
        
        // Unselected view -- we expect to be circular
        TabItem(isSelected: false, image: "brain.fill", accentColor: .blue, action: {})
            .padding()
        
        
        // Selected view -- we expect larger and square for animation
        TabItem(isSelected: true, image: "brain.fill", accentColor: .blue, action: {})
    }
}
