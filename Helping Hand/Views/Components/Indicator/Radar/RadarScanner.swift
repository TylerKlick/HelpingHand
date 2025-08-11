import SwiftUI
import SwiftUIVisualEffects

@MainActor
struct RadarScanner: View {
    
    static let degrees: Double = 90
    let middlePointSize: CGFloat
    let scannerSize: CGFloat
    let scannerThickness: CGFloat
    let blipSize: CGFloat
    let scannerSpeed: Double
    let color: Color
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            Circle()
                .blurEffectStyle(.systemUltraThinMaterial)
                .frame(width: self.scannerSize, height: self.scannerSize)
            
            ForEach(viewModel.blips, id: \.self) { blip in
                BlipView(blip: blip, color: self.color, blipSize: self.blipSize)
            }
            
            RadarSweep(color: self.color, scannerSize: self.scannerSize, scannerThickness: self.scannerThickness, rotation: viewModel.rotation, liveRotation: $viewModel.currentRotation)
            
            // Scanner middle point
           Circle()
                .frame(width: self.middlePointSize, height: self.middlePointSize)
               .foregroundColor(self.color)
            
            Button("Add Blip") {
                viewModel.addRandomBlip(blipSize: self.blipSize, scannerSize: self.scannerSize, scannerSpeed: self.scannerSpeed)
            }
        }
        .animation(
            .linear(duration: self.scannerSpeed)
                .repeatForever(autoreverses: false),
            value: viewModel.rotation
        )
        .onAppear {
            viewModel.rotation = 360
        }
    }
}

#Preview {
    RadarScanner(middlePointSize: 15, scannerSize: 250, scannerThickness: 2.0, blipSize: 10, scannerSpeed: 2.0, color: .green)
}
