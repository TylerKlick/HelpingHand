//
//  TabView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/18/25.
//

import SwiftUI

struct CustomTabView: View {
    
    @State private var selectedIndex = 0
    @State private var navColor: Color = .blue
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
                ForEach(tabs.indices, id: \.self) { i in
                    TabItem(
                        isSelected: selectedIndex == i,
                        image: tabs[i].icon,
                        accentColor: tabs[i].color,
                        isAnimating: isAnimating
                    ) {
                        // Cancel any running animations if another is trying to play
                        withAnimation(nil) {
                        }
                        
                        // Small delay to ensure animation cancellation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.002) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                selectedIndex = i
                                navColor = tabs[i].color
                            }
                        }
                        
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
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

//struct GlassTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomTabView([])
//    }
//}
