//
//  CustomTabView.swift
//  Helping Hand
//
//  Created by Tyler Klick on 6/18/25.
//

import SwiftUI
import Foundation

// MARK: - Main View

struct CustomTabView<Content: View>: View {
    @State private var selectedIndex = 0
    @State private var navColor: Color = .clear

    private let cornerRadius: CGFloat = 38
    private let itemSize: CGFloat = 2.2
    private let tabs: [CustomTab<Content>]

    init(@CustomTabBuilder content: () -> [CustomTab<Content>]) {
        self.tabs = content()
        _navColor = State(initialValue: tabs.first?.accentColor ?? .clear)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            navColor.opacity(0.08)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: navColor)

            TabView(selection: $selectedIndex) {
                ForEach(tabs.indices, id: \.self) { index in
                    tabs[index].content
                        .tag(index)
                        .transition(.opacity)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 14) {
                ForEach(tabs.indices, id: \.self) { i in
                    TabItem(
                        title: tabs[i].title,
                        image: tabs[i].image,
                        accentColor: tabs[i].accentColor,
                        isSelected: selectedIndex == i,
                        onTap: {
                            withAnimation(nil) {}
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.002) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedIndex = i
                                    navColor = tabs[i].accentColor
                                }
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        },
                        content: { EmptyView() }
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

// MARK: - Result Builder

@resultBuilder
struct CustomTabBuilder {
    static func buildBlock<T>(_ components: CustomTab<T>...) -> [CustomTab<T>] {
        components
    }
}

// MARK: - Tab Item View

fileprivate struct TabItem<Content: View>: View {
    var title: String
    var image: String
    var accentColor: Color
    let isSelected: Bool
    let onTap: () -> Void
    let content: () -> Content

    @State private var isAnimating: Bool = false

    private let selectedOffset: CGFloat = 14
    private let unselectedOffset: CGFloat = 10
    private let itemSize: CGFloat = 50
    private let animation: Animation = .interpolatingSpring(mass: 0.3, stiffness: 120, damping: 8)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .opacity(0.65)
                .frame(width: isSelected ? 90 : itemSize, height: isSelected ? 58 : itemSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .strokeBorder(
                            LinearGradient(colors: [
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.05)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.4
                        )
                )
                .background(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            isSelected ? accentColor.opacity(0.4) : Color.clear,
                            .clear
                        ]),
                        center: .center,
                        startRadius: 4,
                        endRadius: 60
                    )
                    .blur(radius: 8)
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: isSelected ? accentColor.opacity(0.4) : .clear, radius: isSelected ? 12 : 0, x: 0, y: 5)
                .scaleEffect(isSelected ? 1.08 : 1.0)

            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: itemSize / 2.2, height: itemSize / 2.2)
                .foregroundStyle(
                    LinearGradient(
                        colors: isSelected
                        ? [accentColor, accentColor.opacity(0.85)]
                        : [Color.gray.opacity(0.65), Color.gray.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: isSelected ? accentColor.opacity(0.6) : .clear, radius: isSelected ? 6 : 0)
                .scaleEffect(isSelected ? 1.15 : 1.0)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: isSelected
                        ? [accentColor, accentColor.opacity(0.9)]
                        : [.primary.opacity(0.9), .primary.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .offset(y: itemSize / 2 + (isSelected ? selectedOffset : unselectedOffset))
                .scaleEffect(isSelected ? 0.95 : 1.05)
                .shadow(color: isSelected ? Color.black.opacity(0.15) : .clear, radius: 1, y: 1)
        }
        .animation(animation, value: isSelected)
        .disabled(isAnimating)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Custom Tab
struct CustomTab<Content: View>: Identifiable {
    let id = UUID()
    let title: String
    let image: String
    let accentColor: Color
    let content: Content

    init(title: String, image: String, accentColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.image = image
        self.accentColor = accentColor
        self.content = content()
    }
}
