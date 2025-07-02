import SwiftUI

struct BluetoothOffView: View {
    @State private var isAnimating = false
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.2

    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Faded ripple to suggest failure of connection
                Circle()
                    .strokeBorder(Color.blue.opacity(0.4), lineWidth: 3)
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
                
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                // Valid SF Symbol
                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .frame(width: 150, height: 150)
            .onAppear {
                animateRipple()
            }
            
            VStack(spacing: 16) {
                Text("Bluetooth is Turned Off")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Enable Bluetooth in your settings to scan and connect to devices.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "gear")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Text("Open Settings")
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
    
    private func animateRipple() {
        withAnimation(
            Animation.easeOut(duration: 1.8)
                .repeatForever(autoreverses: false)
        ) {
            rippleScale = 1.6
            rippleOpacity = 0.05
        }
        
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            isAnimating = true
        }
    }
}

struct BluetoothOffView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothOffView()
            .previewLayout(.sizeThatFits)
    }
}
