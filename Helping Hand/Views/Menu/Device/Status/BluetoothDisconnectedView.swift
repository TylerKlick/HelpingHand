import SwiftUI

struct DeviceNotConnectedView: View {
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.65))
                    .brightness(0.2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseScale)
                    .opacity(opacity)
                
                // Device icon
                Image(systemName: "bluetooth.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
            }
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .onAppear {
                startAnimations()
            }
            
            VStack(spacing: 16) {
                Text("Device Not Connected")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Please connect your device to continue using the app")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button(action: {
                // TODO : Connect to bluetooth controller.
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Text("Try Again")
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .scaleEffect(isAnimating ? 0.95 : 1.0)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .secondary.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
    
    private func startAnimations() {
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.3
            opacity = 0.1
        }
        
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            isAnimating = true
        }
    }
}
struct DeviceNotConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceNotConnectedView()
            .previewLayout(.sizeThatFits)
    }
}
