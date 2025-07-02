import SwiftUI

struct DeviceConnectedView: View {
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var backgroundOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    let deviceName: String
    let deviceType: String // e.g., "Bluetooth Speaker", "Smart Watch", "Printer"
    
    var body: some View {
        VStack(spacing: 24) {
            // Connected icon with animation 
            ZStack {
                // Background circle
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .opacity(backgroundOpacity)
                
                // Checkmark
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(checkmarkScale)
            }
            
            VStack(spacing: 12) {
                Text("Device Connected!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .opacity(textOpacity)
                
                VStack(spacing: 4) {
                    Text(deviceName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .opacity(textOpacity)
                    
                    Text(deviceType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(textOpacity)
                }
            }
            
            // Status indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                
                Text("Connected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .opacity(textOpacity)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .onAppear {
            playConnectionAnimation()
        }
    }
    
    private func playConnectionAnimation() {
        // Animate background
        withAnimation(.easeOut(duration: 0.3)) {
            backgroundOpacity = 1.0
        }
        
        // Animate checkmark with bounce 
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0).delay(0.1)) {
            checkmarkScale = 1.0
        }
        
        // Animate text
        withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
            textOpacity = 1.0
        }
    }
}

#Preview {
    Group {

        DeviceConnectedView(
            deviceName: "Apple Watch Series 9",
            deviceType: "Smart Watch"
        )
    }
}
