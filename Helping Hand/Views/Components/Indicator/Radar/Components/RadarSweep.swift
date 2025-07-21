import SwiftUI

struct RadarSweep: View, Animatable {
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let scannerSize: CGFloat
    
    // Tell SwiftUI to update rotation for every degree to alert onChange
    var rotation: CGFloat
    var animatableData: CGFloat {
        get { rotation }
        set { rotation = newValue }
    }

    @Binding var liveRotation: Double

    private var scannerTailColor: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: [color.opacity(0), color.opacity(1)]),
            center: .center
        )
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.375)
                .stroke(lineWidth: scannerSize / 2)
                .fill(scannerTailColor)
                .frame(width: scannerSize / 2, height: scannerSize / 2)
                .rotationEffect(.degrees(135 + rotation))

            Rectangle()
                .frame(width: 4, height: scannerSize / 2)
                .offset(y: -scannerSize / 4)
                .rotationEffect(.degrees(rotation))
                .foregroundColor(color)
        }
        .frame(width: width, height: height)
        .onChange(of: rotation) { _, newValue in
            liveRotation = Double(newValue)
        }
    }
}

// MARK: - Demo Preview
struct RadarDemo: View {
    @State private var rotation: CGFloat = 0
    @State private var model: Double = 0

    var body: some View {
        VStack(spacing: 40) {
            RadarSweep(
                color: .green,
                width: 300,
                height: 300,
                scannerSize: 250,
                rotation: rotation,
                liveRotation: $model
            )

            Text("Live rotation: \(model, specifier: "%.2f")°")
                .monospacedDigit()
        }
        .animation(
            .linear(duration: 3)
                .repeatForever(autoreverses: false),
            value: rotation
        )
        .onAppear {
            rotation = 360
        }
    }
}

#Preview {
    RadarDemo()
}
