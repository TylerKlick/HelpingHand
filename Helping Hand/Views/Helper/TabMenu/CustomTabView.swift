import SwiftUI

// MARK: - Tab Item Model

struct CustomTabItem: Identifiable, Hashable {
    let id = UUID()
    let systemImageName: String
    let title: String
    let backgroundGradient: LinearGradient
    let content: AnyView
    
    init(systemImageName: String, title: String, backgroundGradient: LinearGradient, @ViewBuilder content: @escaping () -> some View) {
        self.systemImageName = systemImageName
        self.title = title
        self.backgroundGradient = backgroundGradient
        self.content = AnyView(content())
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CustomTabItem, rhs: CustomTabItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Custom TabView

struct CustomTabView: View {
    @State private var selectedIndex: Int = 0
    @Namespace private var animation
    
    private let items: [CustomTabItem]
    
    init(items: [CustomTabItem]) {
        self.items = items
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Content area - takes full screen
                if !items.isEmpty {
                    items[selectedIndex].content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Tab bar - overlaid at bottom
                CustomTabBar(
                    items: items,
                    selectedIndex: $selectedIndex,
                    animation: animation
                )
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 10)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Custom TabBar

private struct CustomTabBar: View {
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


#Preview {
    let tabItems = [
        CustomTabItem(
            systemImageName: "house",
            title: "Home",
            backgroundGradient: LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
        ) {
            Text("test")
        },
        CustomTabItem(
            systemImageName: "message",
            title: "Messages",
            backgroundGradient: LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        ) {
            Text("test")
        },
        CustomTabItem(
            systemImageName: "person",
            title: "Profile",
            backgroundGradient: LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
        ) {
            Text("test")
        },
        CustomTabItem(
            systemImageName: "gearshape",
            title: "Settings",
            backgroundGradient: LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        ) {
            Text("test")
        }
    ]
    
    CustomTabView(items: tabItems)
}

