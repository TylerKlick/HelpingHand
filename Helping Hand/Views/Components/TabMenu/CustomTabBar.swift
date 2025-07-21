//
//  CustomTabBar.swift
//  Helping Hand
//
//  Created by Tyler Klick on 7/15/25.
//

import SwiftUI

struct CustomTabBar: View {
    let items: [CustomTabItem]
    @Binding var selectedIndex: Int
    let animation: Namespace.ID
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Spacer()
                    
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.prepare()
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedIndex = index
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(item.backgroundGradient)
                                .frame(width: 60, height: 60)
                                .opacity(selectedIndex == index ? 1 : 0)
                                .matchedGeometryEffect(
                                    id: "background",
                                    in: animation,
                                    isSource: selectedIndex == index
                                )
                            
                            Image(systemName: selectedIndex == index ? "\(item.systemImageName).fill" : item.systemImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                                .foregroundColor(selectedIndex == index ? .white : .gray)
                        }
                        .frame(width: 60, height: 60)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 80)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
}
