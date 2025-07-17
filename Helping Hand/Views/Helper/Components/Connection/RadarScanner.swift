import SwiftUI
internal import SwiftUIVisualEffects

struct RadarMarker: Identifiable {
    let id = UUID()
    let offset: CGFloat
    let degrees: Double
}

class RadarViewModel: ObservableObject {
    @Published var markers: [RadarMarker] = []

    func addMarker() {
       var temp: [RadarMarker] = []
        for _ in 0...10000 {
            temp.append(RadarMarker(
                offset: CGFloat.random(in: 15...100),
                degrees: Double.random(in: 0...360)
            ))
        }
        
        markers.append(contentsOf: temp)
    }

    func removeMarker() {
        guard !markers.isEmpty else { return }
        markers.removeLast()
    }
    
    func clearMarkers() {
        markers.removeAll()
    }
}

struct Radar: View {
    @ObservedObject var viewModel: RadarViewModel
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Background
            BlurEffect()
                .blurEffectStyle(.systemUltraThinMaterial)
                .clipShape(Circle())
                .frame(width: 200, height: 200)
            
            // Markers
            ForEach(viewModel.markers) { marker in
                MarkerView(marker: marker, rotation: rotation)
            }
            
            // Scanner tail
            Circle()
                .trim(from: 0, to: 0.375)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.green.opacity(0), .green]),
                        center: .center
                    ),
                    lineWidth: 100
                )
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(135 + rotation))
            
            // Scanner line
            Rectangle()
                .frame(width: 2, height: 100)
                .offset(y: -50)
                .rotationEffect(.degrees(rotation))
                .foregroundColor(.green)
            
            // Center point
            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(.green)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct MarkerView: View {
    let marker: RadarMarker
    let rotation: Double
    @State private var opacity: Double = 1
    
    var body: some View {
        Circle()
            .frame(width: 8, height: 8)
            .foregroundColor(.green)
            .opacity(opacity)
            .offset(x: marker.offset)
            .rotationEffect(.degrees(marker.degrees))
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false).delay(1.5 / 360 * marker.degrees)) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    let radarViewModel = RadarViewModel()

    VStack {
        Radar(viewModel: radarViewModel)
        
        
        HStack {
            Button("Add Marker") {
                radarViewModel.addMarker()
            }
            Button("Remove Marker") {
                radarViewModel.removeMarker()
            }
        }
        .padding()
    }
}
