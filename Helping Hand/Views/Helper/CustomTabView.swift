//
//  TabView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/18/25.
//

import Foundation
import SwiftUI

struct CustomTabView: View {
    
    @State private var selectedIndex = 0
    @State private var navColor: Color = .clear
    @State private var isAnimating = false
    private let cornerRadius: CGFloat = 38 // Corner radius size
    private let itemSize: CGFloat =  2.2 // Size of the background and shadow rectangles on menu

    let tabs: [TabInfo]

    var body: some View {
        
        ZStack(alignment: .bottom) {
            navColor
                .opacity(0.1)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: navColor)

            TabView(selection: $selectedIndex) {
                ForEach(tabs.indices, id: \.self) { index in
                    ZStack {
                        Color.clear
                        Text(tabs[index].title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 14) {
                ForEach(tabs.indices, id: \.self) { (i: Int) in
                    TabItem(
                        title: tabs[i].title,
                        image: tabs[i].imagePath,
                        accentColor: tabs[i].accentColor,
                        isSelected: selectedIndex == i,
                        onTap: {
                            // Cancel any running animations if another is trying to play
                            withAnimation(nil) {}
                            
                            // Small delay to ensure animation cancellation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.002) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedIndex = i
                                    navColor = tabs[i].accentColor
                                }
                            }
                            
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    )
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), navColor.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: itemSize
                            )
                    )
                    .shadow(color: navColor.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 25)
            .animation(.easeInOut(duration: 0.4), value: navColor)
        }
        .ignoresSafeArea(.keyboard)
    }
}

fileprivate struct TabItem: View {
    
    var title: String
    var image: String
    var accentColor: Color
    
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var isAnimating: Bool = false
    
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
            
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: isSelected ? [accentColor, accentColor.opacity(0.8)] : [.primary.opacity(0.9), .primary.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .offset(y: itemSize / 2 + (isSelected ? selectedOffset : unselectedOffset))
                    .font(.caption)
                    .scaleEffect(isSelected ? 1.05 : 0.95)
            
        }
        
        // Disable interaction during animation
        .animation(animation, value: isSelected)
        .disabled(isAnimating)
        .onTapGesture(perform: onTap)
    }
}
