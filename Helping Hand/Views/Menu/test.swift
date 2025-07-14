import SwiftUI
internal import SwiftUIVisualEffects

struct MeshGradientBackground: View {
    var body: some View {
        MeshGradient(
            width: 2, height: 2,
            points: [
                [0, 0], [1, 0],
                [0, 1], [1, 1]
            ],
            colors: [
                .indigo, .cyan,
                .purple, .pink
            ]
        )
        .ignoresSafeArea()
    }
}

struct TestView: View {
    @State private var isFavorite = false

    var body: some View {
        VStack {
            Button {
                withAnimation {
                    isFavorite.toggle()
                }
            } label: {
                Label("Toggle Favorite", systemImage: isFavorite ? "checkmark": "heart")
            }
            .contentTransition(.symbolEffect(.replace))
        }
        .font(.largeTitle)
    }
}

struct VibrantCardView: View {
    var body: some View {
        ZStack {
            // Any background content (color, image, etc.)
            MeshGradientBackground()
            
            // Centered card
            VStack(spacing: 8) {
                Image("bluetooth.fill")
                    .font(.system(size: 80))
                    .vibrancyEffect()
                
                Text("Hello, World")
                    .font(.title3.bold())
                    .vibrancyEffect()
                
                Text("Greetings from SwiftUI")
                    .font(.subheadline)
                    .vibrancyEffect()
            }
            .padding(20)
            .frame(maxWidth: 320)
            .background(.ultraThinMaterial)        // Base material under card
            .cornerRadius(20)
            .blurEffectStyle(.systemUltraThinMaterial)
            .vibrancyEffectStyle(.fill)
        }
    }
}


#Preview {
    VibrantCardView()
}
