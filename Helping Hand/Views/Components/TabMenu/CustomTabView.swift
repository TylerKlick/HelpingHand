import SwiftUI

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

