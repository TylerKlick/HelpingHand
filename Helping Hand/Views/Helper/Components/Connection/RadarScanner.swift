import SwiftUI

struct Marker: Identifiable, Hashable {
    let id: UUID
    let offset: CGFloat
    let degrees: Double
}

struct Radar: View {
    @State private var rotation: Double = 0
    @State private var markers: [Marker] = []

    private var scannerTailColor: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [color.opacity(0), color.opacity(1)]),
            center: .center
        )
    }

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            // Background circle
            Circle()
                .fill(Color.white)
                .frame(width: scannerSize, height: scannerSize)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 10, y: 10)
                .shadow(color: .white.opacity(0.7), radius: 10, x: -5, y: -5)

            // MARK: - Markers with self-animating opacity
            ForEach(markers, id: \.id) { m in
                RadarMarker(marker: m, color: color, markerSize: markerSize, scannerSpeed: scannerSpeed)
            }

            // Scanner tail
            Circle()
                .trim(from: 0, to: 0.375)
                .stroke(lineWidth: scannerSize / 2)
                .fill(scannerTailColor)
                .frame(width: scannerSize / 2, height: scannerSize / 2)
                .rotationEffect(.degrees(135 + rotation))

            // Scanner line
            Rectangle()
                .frame(width: 4, height: scannerSize / 2)
                .offset(x: 0, y: -scannerSize / 4)
                .rotationEffect(.degrees(rotation))
                .foregroundColor(color)

            // Center dot
            Circle()
                .frame(width: middlePointSize, height: middlePointSize)
                .foregroundColor(color)

            // Controls
            VStack {
                Spacer()
                HStack {
                    Button("Add Marker") {
                        addMarker()
                    }
                    .padding(.horizontal)

                    Button("Reset Markers") {
                        markers.removeAll()
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: scannerSpeed).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }

    func addMarker() {
        let randomOffset = CGFloat.random(in: markerSize...(scannerSize / 2 - markerSize))
        let randomDegree = Double.random(in: 0...360)
        let newMarker = Marker(id: UUID(), offset: randomOffset, degrees: randomDegree)
        markers.append(newMarker)
    }

    // MARK: - Constants
    let middlePointSize: CGFloat = 15
    let scannerSize: CGFloat = 250
    let markerSize: CGFloat = 10
    let scannerSpeed: Double = 1.5
    let color: Color = .green
}

// MARK: - Radar Marker View (self-animating)

struct RadarMarker: View {
    let marker: Marker
    let color: Color
    let markerSize: CGFloat
    let scannerSpeed: Double

    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .frame(width: markerSize, height: markerSize)
            .foregroundColor(color)
            .opacity(opacity)
            .onAppear {
                // Calculate delay based on marker position relative to scanner start
                let normalizedDegrees = (marker.degrees + 45).truncatingRemainder(dividingBy: 360)
                let delay = scannerSpeed * (normalizedDegrees / 360)
                
                withAnimation(
                    Animation
                        .linear(duration: scannerSpeed / 2)
                        .delay(delay)
                        .repeatForever(autoreverses: false)
                ) {
                    opacity = 0.8
                }
            }
            .frame(width: self.markerSize, height: self.markerSize)
            .offset(x: marker.offset, y: 0)
            .rotationEffect(.degrees(marker.degrees))
            .blur(radius: 2)
    }
}

#Preview {
    Radar()
}
