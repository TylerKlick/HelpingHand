import SwiftUI

struct RadarScanner: View {
    
    static let degrees: Double = 90
    static let middlePointSize: CGFloat = 15
    static let scannerSize: CGFloat = 250
    static let blipSize: CGFloat = 10
    static let scannerSpeed: Double = 2.0
    static let color: Color = .green
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            Color.white
            
            Circle()
                .fill(.white)
                .frame(width: RadarScanner.scannerSize, height: RadarScanner.scannerSize)
            
            ForEach(viewModel.blips, id: \.self) { blip in
                BlipView(blip: blip, color: RadarScanner.color, blipSize: RadarScanner.blipSize)
            }
            
            RadarSweep(color: RadarScanner.color, scannerSize: RadarScanner.scannerSize, rotation: viewModel.rotation, liveRotation: $viewModel.currentRotation)
            
            // Scanner middle point
           Circle()
                .frame(width: RadarScanner.middlePointSize, height: RadarScanner.middlePointSize)
               .foregroundColor(RadarScanner.color)
            
            Button("Add Blip") {
                viewModel.addRandomBlip(blipSize: RadarScanner.blipSize, scannerSize: RadarScanner.scannerSize, scannerSpeed: RadarScanner.scannerSpeed)
            }
        }
        .animation(
            .linear(duration: RadarScanner.scannerSpeed)
                .repeatForever(autoreverses: false),
            value: viewModel.rotation
        )
        .onAppear {
            viewModel.rotation = 360
        }
    }
}

#Preview {
    RadarScanner()
}
